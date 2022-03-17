import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/pages/notification_screen.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';
import 'package:todo/ui/widgets/task_tile.dart';

import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notifyHelper = NotifyHelper();

    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 8),
          _showTask()
        ],
      ),
    );
  }

  AppBar _appBar() => AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => {
            ThemeServices().switchTheme(),
          },
          icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
            size: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('images/karim.png'),
            radius: 21,
          ),
          SizedBox(
            width: 20,
          )
        ],
      );

  _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(_selectedTime),
                style: SubheadingStyle,
              ),
              Text(
                'Today',
                style: headingStyle,
              )
            ],
          ),
          MyButton(
            label: '+ Add Task',
            onTop: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
          )
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 6),
      child: DatePicker(DateTime.now(),
          dayTextStyle: dayTextStyle,
          initialSelectedDate: _selectedTime,
          dateTextStyle: dateTextStyle,
          monthTextStyle: monthTextStyle,
          width: 60,
          height: 100,
          selectedTextColor: Colors.white,
          selectionColor: primaryClr, onDateChange: (newDate) {
        setState(() {
          _selectedTime = newDate;
        });
      }),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTasks();
  }

  _showTask() {
    return Expanded(child: Obx(() {
      if (_taskController.taskList.isEmpty) {
        return _noTaskMSG();
      } else {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            scrollDirection: SizeConfig.orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              var task = _taskController.taskList[index];

              // var hour = task.startTime.toString().split(':')[0];
              // var minutes = task.startTime.toString().split(':')[1];

              var date = DateFormat.jm().parse(task.startTime!);
              var myTime = DateFormat(' HH: mm').format(date);
              notifyHelper.scheduledNotification(
                int.parse(myTime.toString().split(':')[0]),
                int.parse(myTime.toString().split(':')[1]),
                task,
              );

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1375),
                child: SlideAnimation(
                  horizontalOffset: 300,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        ShowBottomSheet(context, task);
                      },
                      child: TaskTile(task: task),
                    ),
                  ),
                ),
              );
            },
            itemCount: _taskController.taskList.length,
          ),
        );
      }
    }));
  }

  _noTaskMSG() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 220),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    semanticsLabel: 'Task',
                    color: primaryClr.withOpacity(0.7),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'You don\'t have any tasks yet!',
                      style: SubTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 120)
                      : const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

_buildBottomSheet({
  required String label,
  required Function() onTap,
  required Color clr,
  bool isClose = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 65,
      width: SizeConfig.screenWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: isClose
              ? Get.isDarkMode
                  ? Colors.grey[600]!
                  : Colors.grey[300]!
              : clr,
        ), // Border.all
        borderRadius: BorderRadius.circular(20),
        color: isClose ? Colors.transparent : clr,
      ), // BoxDecoration
      // Container
      child: Center(
          child: Text(
        label,
        style: isClose
            ? TitleStyle
            : TitleStyle.copyWith(
                color: Colors.white,
              ),
      )),
    ),
  );
}

ShowBottomSheet(BuildContext context, Task task) {
  Get.bottomSheet(SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.only(top: 4),
      width: SizeConfig.screenWidth,
      height: (SizeConfig.orientation == Orientation.landscape)
          ? (task.isCompleted == 1
              ? SizeConfig.screenHeight * 0.6
              : SizeConfig.screenHeight * 0.8)
          : (task.isCompleted == 1
              ? SizeConfig.screenHeight * 0.30
              : SizeConfig.screenHeight * 0.39),

      color: Get.isDarkMode ? darkHeaderClr : Colors.white,
      child: Column(
        children: [
          Flexible(
            child: Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 20),
          task.isCompleted == 1
              ? Container()
              : _buildBottomSheet(
                  label: 'Task Completed',
                  onTap: () {
                    Get.back();
                  },
                  clr: primaryClr),
          _buildBottomSheet(
              label: 'Delete Task',
              onTap: () {
                Get.back();
              },
              clr: primaryClr),
          Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
          _buildBottomSheet(
              label: 'Cancel',
              onTap: () {
                Get.back();
              },
              clr: primaryClr),
          const SizedBox(height: 20),
        ],
      ), // Column
    ),
  ));
}

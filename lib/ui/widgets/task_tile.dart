import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(
                SizeConfig.orientation == Orientation.landscape ? 4 : 20)),
        width: SizeConfig.orientation == Orientation.landscape
            ? SizeConfig.screenWidth / 2
            : SizeConfig.screenWidth,
        margin: EdgeInsets.only(bottom: getProportionateScreenWidth(12)),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _getBgClr(task.color)),
          child: Row(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title!,
                      style: task_titleTextSyle,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: Colors.grey[200], size: 18),
                        const SizedBox(width: 12),
                        Text(
                          '${task.startTime} - ${task.endTime} ',
                          style: task_dateTextSyle,
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.note!,
                      style: task_noteTextSyle,
                    )
                  ],
                ),
              )),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 60,
                width: 0.5,
                color: Colors.grey[200]!.withOpacity(0.7),
              ),
              RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    task.isCompleted == 0 ? 'ToDo' : 'Completed',
                    style: isCompletedTextStyle,
                  ))
            ],
          ),
        ));
  }

  _getBgClr(int? color) {
    switch (color) {
      case 0:
        return bluishClr;
      case 1:
        return pinkClr;

      case 2:
        return orangeClr;

      default:
        return bluishClr;
    }
  }
}

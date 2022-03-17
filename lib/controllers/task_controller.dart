import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController extends GetxController {
  final taskList = <Task>[
    Task(
      id: 1,
      title: 'title Example',
      note: 'note Example',
      isCompleted: 0,
      startTime: DateFormat('hh: mm a')
          .format(DateTime.now().add(const Duration(minutes: 1)))
          .toString(),
      color: 1,
    ),
  ].obs;

  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task);
  }

  Future<void> getTasks() async {
    final tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void deleteTasks(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  void markUsCompleted(int id) async {
    await DBHelper.update(id);

    getTasks();
  }
}

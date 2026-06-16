import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskDao {
  static const String tasksKey = 'tasks';

  Future<List<Task>> getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tasksString = prefs.getString(tasksKey);

    if (tasksString == null) {
      return [];
    }

    List<dynamic> tasksJson = jsonDecode(tasksString);

    return tasksJson.map((taskJson) {
      return Task.fromJson(Map<String, dynamic>.from(taskJson));
    }).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> tasksJson = tasks.map((task) {
      return task.toJson();
    }).toList();

    String tasksString = jsonEncode(tasksJson);

    await prefs.setString(tasksKey, tasksString);
  }

  Future<void> addTask(Task task) async {
    List<Task> tasks = await getTasks();

    tasks.add(task);

    await saveTasks(tasks);
  }

  Future<void> updateTask(int index, Task updatedTask) async {
    List<Task> tasks = await getTasks();

    tasks[index] = updatedTask;

    await saveTasks(tasks);
  }

  Future<void> deleteTask(int index) async {
    List<Task> tasks = await getTasks();

    tasks.removeAt(index);

    await saveTasks(tasks);
  }

  Future<void> toggleTaskStatus(int index) async {
    List<Task> tasks = await getTasks();

    tasks[index].isCompleted = !tasks[index].isCompleted;

    await saveTasks(tasks);
  }
}
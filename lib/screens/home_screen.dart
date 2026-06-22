import 'package:flutter/material.dart';

import '../database/task_database.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskDao taskDao = TaskDao();
  final TextEditingController searchController = TextEditingController();

  List<Task> tasks = [];
  String selectedFilter = 'All';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    List<Task> loadedTasks = await taskDao.getTasks();

    setState(() {
      tasks = loadedTasks;
    });
  }

  List<Task> getFilteredTasks() {
    List<Task> filteredTasks = tasks;

    if (selectedFilter == 'Completed') {
      filteredTasks = filteredTasks.where((task) {
        return task.isCompleted;
      }).toList();
    } else if (selectedFilter == 'Pending') {
      filteredTasks = filteredTasks.where((task) {
        return !task.isCompleted;
      }).toList();
    }

    if (searchText.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(searchText.toLowerCase()) ||
            task.description.toLowerCase().contains(searchText.toLowerCase()) ||
            task.date.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }

    return filteredTasks;
  }

  Future<void> openAddTaskScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );

    if (result == true) {
      await loadTasks();
    }
  }

  Future<void> openEditTaskScreen(Task task, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(
          task: task,
          taskIndex: index,
        ),
      ),
    );

    if (result == true) {
      await loadTasks();
    }
  }

  Future<void> deleteTask(int index) async {
    await taskDao.deleteTask(index);
    await loadTasks();
  }

  Future<void> toggleTaskStatus(int index) async {
    await taskDao.toggleTaskStatus(index);
    await loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getFilteredTasks();

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xff4A6FA5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xff4A6FA5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organize your tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Add, complete, search, and filter your daily tasks',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Task',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedFilter,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xff4A6FA5),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('All Tasks'),
                  ),
                  DropdownMenuItem(
                    value: 'Pending',
                    child: Text('Pending Tasks'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed Tasks'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
              ),
            ),
          ),

          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.task_alt,
                          size: 70,
                          color: Color(0xffB0BEC5),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No Tasks Found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap + to add your first task',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final originalIndex = tasks.indexOf(task);

                      return TaskCard(
                        task: task,
                        onToggle: () {
                          toggleTaskStatus(originalIndex);
                        },
                        onEdit: () {
                          openEditTaskScreen(task, originalIndex);
                        },
                        onDelete: () {
                          deleteTask(originalIndex);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff4A6FA5),
        foregroundColor: Colors.white,
        onPressed: openAddTaskScreen,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
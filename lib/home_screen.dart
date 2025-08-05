import 'package:flutter/material.dart';
import 'package:mini_project_03/task_detail_screen.dart';
import 'task.dart';
import 'database_service.dart';
import 'add_task_dialog.dart';
import 'task_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTasks();
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _fetchTasks() async {
    final tasks = await _dbService.getTasks();
    setState(() {
      _allTasks = tasks;
      _filterTasks();
    });
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        return task.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddTaskDialog({Task? taskToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          taskToEdit: taskToEdit,
          onSave: (title, description) {
            if (taskToEdit == null) {
              _dbService.insertTask(Task(
                title: title,
                description: description,
                creationDate: DateTime.now(),
              ));
            } else {
              final updatedTask = taskToEdit.copyWith(
                title: title,
                description: description,
              );
              _dbService.updateTask(updatedTask);
            }
            _fetchTasks();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _deleteTask(int taskId) async {
    await _dbService.deleteTask(taskId);
    _fetchTasks();
  }
  
  void _toggleTaskStatus(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _dbService.updateTask(updatedTask);
    _fetchTasks();
  }

  // New method to handle task updates from TaskDetailScreen
  void _onTaskUpdated(Task updatedTask) async {
    await _dbService.updateTask(updatedTask);
    _fetchTasks(); // Refresh the task list
  }

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = _filteredTasks.where((task) => !task.isCompleted).toList();
    final completedTasks = _filteredTasks.where((task) => task.isCompleted).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TODO App',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Incomplete'),
                  Tab(text: 'Completed'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(incompleteTasks),
          _buildTaskList(completedTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return tasks.isEmpty
        ? const Center(child: Text('No tasks found.', style: TextStyle(fontSize: 16)))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskListItem(
                  task: task,
                  onToggleStatus: () => _toggleTaskStatus(task),
                  onDelete: () => _deleteTask(task.id!),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(
                          task: task,
                          onTaskUpdated: _onTaskUpdated,
                        ),
                      ),
                    );
                    _fetchTasks(); // Refresh list when returning from detail screen
                  },
                );
              },
            ),
          );
  }
}
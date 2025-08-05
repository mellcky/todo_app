import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task.dart';
import 'add_task_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          _task.title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditTaskDialog(context, _task);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _task.description,
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildCreationDateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        Icon(_task.isCompleted ? Icons.check_circle : Icons.cancel),
        const SizedBox(width: 8),
        Text(
          'Status: ${_task.isCompleted ? 'Completed' : 'Incomplete'}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _task.isCompleted ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildCreationDateSection() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Created: ${DateFormat('yyyy-MM-dd – hh:mm a').format(_task.creationDate)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  void _showEditTaskDialog(BuildContext context, Task taskToEdit) {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          taskToEdit: taskToEdit,
          onSave: (title, description) {
            final updatedTask = taskToEdit.copyWith(
              title: title,
              description: description,
            );
            widget.onTaskUpdated(updatedTask);
            
            // Update the local state to rebuild the screen with the new data
            setState(() {
              _task = updatedTask;
            });
            
            Navigator.pop(context); // Close the dialog, but stay on the screen
          },
        );
      },
    );
  }
}
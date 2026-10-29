import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../utils/api_service.dart';
import '../home/widgets/custom_warning_aleart_dialog.dart';
import '../home/widgets/success_alert_dialog.dart';
import 'add_edit_task_view.dart';

class TaskDetailView extends StatefulWidget {
  final TaskModel task;
  final int userId;
  final Future<bool> Function(int taskId)? onDeleteTask;

  const TaskDetailView({
    super.key,
    required this.task,
    required this.userId,
    this.onDeleteTask,
  });

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  bool _isDeleting = false;

  static const Color green = Color(0xFF80C900);
  static const Color background = Color(0xFFF8FAF8);
  static const Color muted = Color(0xFF667085);
  static const Color dividerColor = Color(0xFFE6EEDC);
  static const Color darkText = Color(0xFF30352E);

  Future<void> _deleteTask() async {
    final confirmed = await CustomAlertDialog.show(
      context: context,
      title: 'Warning',
      description: 'Are you sure you want to delete this task?',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFFB000),
      confirmText: 'Confirm',
      confirmColor: AppColors.primary,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final success = widget.onDeleteTask != null
          ? await widget.onDeleteTask!(widget.task.id)
          : await ApiService.deleteTask(
              widget.task.id,
              widget.userId,
            );

      if (!mounted) return;

      setState(() => _isDeleting = false);

      if (success) {
        SuccessAlertDialog.show(
          context: context,
          title: 'Success',
          description: 'The task has been permanently removed.',
          onPressed: () {
            Navigator.pop(context, true);
          },
        );
      } else {
        _showMessage('Failed to delete task');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);
      _showMessage('Could not delete task. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _editTask() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskView(
          userId: widget.userId,
          task: widget.task,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Widget _detailsRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5FCEC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value.isEmpty ? 'Not specified' : value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5FCEC),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Tasks Details',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailsRow(
                    icon: Icons.assignment_outlined,
                    label: 'Task Title',
                    value: widget.task.title,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: dividerColor, height: 1),
                  ),
                  _detailsRow(
                    icon: Icons.description_outlined,
                    label: 'Task Description',
                    value: widget.task.description.isEmpty
                        ? 'No description provided.'
                        : widget.task.description,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting ? null : _deleteTask,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          label: const Text(
                            'Delete Task',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            backgroundColor: const Color(0xFFFFEBEE).withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _editTask,
                          icon: const Icon(Icons.edit_outlined, size: 18, color: green),
                          label: const Text(
                            'Edit Task',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD4E8B0)),
                            backgroundColor: const Color(0xFFF5FCEC),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

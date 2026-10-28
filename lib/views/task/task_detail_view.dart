
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../utils/api_service.dart';
import 'add_edit_task_view.dart';

class TaskDetailView extends StatefulWidget {
  final TaskModel task;
  final int userId;

  const TaskDetailView({
    super.key,
    required this.task,
    required this.userId,
  });

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  bool _isDeleting = false;

  static const Color _green = Color(0xFF80C900);
  static const Color _background = Color(0xFFF8FAF8);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE6EEDC);
  static const Color _darkText = Color(0xFF30352E);

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Task?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this task? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final success = await ApiService.deleteTask(
        widget.task.id,
        widget.userId,
      );

      if (!mounted) return;

      setState(() => _isDeleting = false);

      if (success) {
        Navigator.pop(context, true);
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: _green,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value.isEmpty ? 'No description provided.' : value,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color color = _green,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 9),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    return OutlinedButton.icon(
      onPressed: _isDeleting ? null : onPressed,
      icon: Icon(icon, size: 15, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: filled
            ? color.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.80),
        foregroundColor: color,
        side: BorderSide(
          color: color.withValues(alpha: 0.65),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_outlined,
              label: 'Home',
              index: 0,
              active: true,
            ),
            _navItem(
              icon: Icons.add,
              label: 'Add Task',
              index: 1,
              active: false,
              largeIcon: true,
            ),
            _navItem(
              icon: Icons.account_circle_outlined,
              label: 'Profile',
              index: 2,
              active: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required bool active,
    bool largeIcon = false,
  }) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTaskView(
                userId: widget.userId,
              ),
            ),
          );
        } else {
          _showMessage('Open Profile from your main navigation.');
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: active ? 42 : 36,
              height: active ? 42 : 36,
              decoration: BoxDecoration(
                color: active ? _green : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Icon(
                icon,
                size: largeIcon ? 28 : 22,
                color: active ? Colors.white : const Color(0xFF344054),
              ),
            ),
            if (!active) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: _background,

      // App bar
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            top: 5,
            bottom: 5,
          ),
          child: Material(
            color: const Color(0xFFF1FBE8),
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: Colors.black12,
            child: IconButton(
              tooltip: 'Go back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: _green,
              ),
            ),
          ),
        ),
        title: const Text(
          'Tasks Details',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF161B17),
          ),
        ),
      ),

      // Background image and task details
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Same image used in TaskCard, covering the entire body.
          Positioned.fill(
            child: Image.asset(
              'assets/images/taskitem.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Task detail background error: $error');
                return Container(color: _background);
              },
            ),
          ),

          // Keep the image visible while maintaining readable text.
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.48),
            ),
          ),

          // Scrollable details card.
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 17),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _border.withValues(alpha: 0.95),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title
                  _detailsRow(
                    icon: Icons.assignment_outlined,
                    label: 'Task Title',
                    value: task.title,
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: _border, height: 1),
                  const SizedBox(height: 16),

                  // Task description
                  _detailsRow(
                    icon: Icons.notes_outlined,
                    label: 'Task Description',
                    value: task.description,
                  ),

                  const SizedBox(height: 17),
                  const Divider(color: _border, height: 1),
                  const SizedBox(height: 17),

                  // Task category
                  _infoRow(
                    icon: Icons.folder_outlined,
                    label: 'Category',
                    value: task.category,
                  ),

                  // Task priority
                  _infoRow(
                    icon: Icons.flag_outlined,
                    label: 'Priority',
                    value: task.priority,
                    color: task.priority.toLowerCase() == 'high'
                        ? AppColors.highPriority
                        : task.priority.toLowerCase() == 'low'
                        ? _green
                        : AppColors.mediumPriority,
                  ),

                  // Due date
                  _infoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Due Date',
                    value: task.dueDate.isEmpty
                        ? 'Not set'
                        : task.dueDate,
                  ),

                  // Completion status
                  _infoRow(
                    icon: task.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    label: 'Status',
                    value: task.isCompleted ? 'Completed' : 'Pending',
                    color: task.isCompleted ? _green : _muted,
                  ),

                  const SizedBox(height: 2),
                  const Divider(color: _border, height: 1),
                  const SizedBox(height: 16),

                  // Action buttons
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      _actionButton(
                        label: 'Delete Task',
                        icon: Icons.delete_outline,
                        color: Colors.redAccent,
                        onPressed: _deleteTask,
                      ),
                      _actionButton(
                        label: 'Edit Task',
                        icon: Icons.edit_outlined,
                        color: _green,
                        filled: true,
                        onPressed: _editTask,
                      ),
                    ],
                  ),

                  if (_isDeleting) ...[
                    const SizedBox(height: 18),
                    const Center(
                      child: CircularProgressIndicator(
                        color: _green,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Deleting task...',
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _bottomNavigation(),
    );
  }
}

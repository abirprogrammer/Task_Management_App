import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_styles.dart';
import '../../models/task_model.dart';
import '../../utils/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/widgets/custom_warning_aleart_dialog.dart';
import '../home/widgets/success_alert_dialog.dart';

class AddEditTaskView extends StatefulWidget {
  final int userId;
  final TaskModel? task;
  final bool showDetails;
  final Future<bool> Function(int taskId)? onDeleteTask;
  final ValueChanged<int>? onNavigationSelected;

  const AddEditTaskView({
    super.key,
    required this.userId,
    this.task,
    this.showDetails = false,
    this.onDeleteTask,
    this.onNavigationSelected,
  });

  @override
  State<AddEditTaskView> createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<AddEditTaskView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _dueDateController;

  String _selectedCategory = 'Work';
  String _selectedPriority = 'Medium';
  bool _isLoading = false;

  static const Color green = Color(0xFF80C900);
  static const Color background = Color(0xFFF8FAF8);
  static const Color muted = Color(0xFF667085);
  static const Color dividerColor = Color(0xFFE2F0D3);
  static const Color darkText = Color(0xFF30352E);

  final List<String> _categories = [
    'Work',
    'Personal',
    'Study',
    'Finance',
    'Health',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDateController = TextEditingController(
      text: widget.task?.dueDate ?? '',
    );

    if (widget.task != null) {
      if (_categories.contains(widget.task!.category)) {
        _selectedCategory = widget.task!.category;
      }

      if (_priorities.contains(widget.task!.priority)) {
        _selectedPriority = widget.task!.priority;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    super.dispose();
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

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final dueDate = _dueDateController.text.trim();

    if (title.isEmpty) {
      _showMessage('Task title is required');
      return;
    }

    final isEditing = widget.task != null;
    final actionText = isEditing ? 'Update' : 'Add';

    final confirmed = await CustomAlertDialog.show(
      context: context,
      title: 'Warning',
      description: 'Are you sure you want to $actionText this task?',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFFB000),
      confirmText: 'Confirm',
      confirmColor: AppColors.primary,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      bool success;

      if (!isEditing) {
        success = await ApiService.addTask(
          widget.userId,
          title,
          description,
          _selectedCategory,
          dueDate,
          _selectedPriority,
        );
      } else {
        final updatedTask = TaskModel(
          id: widget.task!.id,
          userId: widget.userId,
          title: title,
          description: description,
          category: _selectedCategory,
          dueDate: dueDate,
          priority: _selectedPriority,
          isCompleted: widget.task!.isCompleted,
        );

        success = await ApiService.updateTask(updatedTask);
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        SuccessAlertDialog.show(
          context: context,
          title: 'Success',
          description: isEditing
              ? 'Your task has been updated successfully.'
              : 'Your task has been added successfully.',
          onPressed: () {
            Navigator.pop(context, true);
          },
        );
      } else {
        _showMessage(isEditing ? 'Failed to update task' : 'Failed to save task');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Something went wrong. Please try again.');
    }
  }

  Future<void> _editTask() async {
    if (widget.task == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskView(
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

  Future<void> _deleteTask() async {
    if (widget.task == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Task?'),
        content: const Text(
          'Are you sure you want to delete this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final success = widget.onDeleteTask != null
          ? await widget.onDeleteTask!(widget.task!.id)
          : await ApiService.deleteTask(widget.task!.id, widget.userId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context, true);
      } else {
        _showMessage('Failed to delete task');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Could not delete task.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showDetails && widget.task != null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Task Details',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: green),
              onPressed: _editTask,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteTask,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.task!.category,
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.task!.priority == 'High'
                                ? Colors.red.withValues(alpha: 0.1)
                                : widget.task!.priority == 'Medium'
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.task!.priority,
                            style: TextStyle(
                              color: widget.task!.priority == 'High'
                                  ? Colors.red
                                  : widget.task!.priority == 'Medium'
                                  ? Colors.orange
                                  : Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.task!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: dividerColor),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: muted),
                        const SizedBox(width: 8),
                        Text(
                          'Due Date: ${widget.task!.dueDate.isEmpty ? 'Not specified' : widget.task!.dueDate}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task!.description.isEmpty
                          ? 'No description provided.'
                          : widget.task!.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.taskTitle, style: AppStyles.heading3),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              hintText: "Enter task title...",
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),
            Text(AppStrings.taskDescription, style: AppStyles.heading3),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descController,
              hintText: "Enter task description...",
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(AppStrings.category, style: AppStyles.heading3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat, style: AppStyles.bodyLarge),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            Text(AppStrings.priority, style: AppStyles.heading3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
              ),
              items: _priorities.map((pri) {
                return DropdownMenuItem(
                  value: pri,
                  child: Text(pri, style: AppStyles.bodyLarge),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
            ),
            const SizedBox(height: 16),
            Text(AppStrings.dueDate, style: AppStyles.heading3),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _dueDateController,
              hintText: "e.g. 2026-12-31",
              prefixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: _isEditing ? AppStrings.update : AppStrings.save,
              onPressed: _saveNewTaskPressed,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _saveNewTaskPressed() {
    _saveTask();
  }
}

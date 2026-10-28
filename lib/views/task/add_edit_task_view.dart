
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_styles.dart';
import '../../models/task_model.dart';
import '../../utils/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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

    setState(() => _isLoading = true);

    try {
      bool success;

      if (widget.task == null) {
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
        Navigator.pop(context, true);
      } else {
        _showMessage('Failed to save task');
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
    );

    if (confirmed != true || !mounted) return;

    if (widget.onDeleteTask == null) {
      _showMessage('Please connect your delete API.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await widget.onDeleteTask!(widget.task!.id);

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
      _showMessage('Could not delete task');
    }
  }

  // ---------------- DETAILS ROW ----------------

  Widget _detailsRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Icon(
            icon,
            size: 11,
            color: green,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF292D29),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value.isEmpty ? 'No description added' : value,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.4,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- ACTION BUTTON ----------------

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 29,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 13, color: color),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(color: color, width: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  // ---------------- BOTTOM NAVIGATION ----------------

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    bool active = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (widget.onNavigationSelected != null) {
            widget.onNavigationSelected!(index);
          } else {
            _showMessage('$label navigation is not connected');
          }
        },
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: active ? 42 : 27,
                height: active ? 42 : 27,
                decoration: BoxDecoration(
                  color: active ? green : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: green.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: index == 1 ? 27 : 20,
                  color: active ? Colors.white : const Color(0xFF18202C),
                ),
              ),
              if (!active)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF344054),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(11),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(
              index: 0,
              icon: Icons.home_outlined,
              label: 'Home',
              active: true,
            ),
            _navItem(
              index: 1,
              icon: Icons.add,
              label: 'Add Task',
            ),
            _navItem(
              index: 2,
              icon: Icons.person_outline,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DETAILS SCREEN ----------------

  Widget _buildDetailsScreen() {
    final task = widget.task!;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 57,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            top: 5,
            bottom: 5,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBEF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: green,
                size: 15,
              ),
            ),
          ),
        ),
        title: const Text(
          'Tasks Details',
          style: TextStyle(
            color: Color(0xFF151815),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(13, 8, 13, 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailsRow(
                icon: Icons.article_outlined,
                label: 'Task Title',
                value: task.title,
              ),
              const SizedBox(height: 11),
              const Divider(
                color: dividerColor,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 11),
              _detailsRow(
                icon: Icons.notes_outlined,
                label: 'Task Description',
                value: task.description,
              ),
              const SizedBox(height: 11),
              const Divider(
                color: dividerColor,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _actionButton(
                    text: 'Delete Task',
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onPressed: _deleteTask,
                  ),
                  _actionButton(
                    text: 'Edit Task',
                    icon: Icons.edit_outlined,
                    color: green,
                    onPressed: _editTask,
                  ),
                ],
              ),
              if (_isLoading) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  // ---------------- FORM DECORATION ----------------

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: green),
      ),
    );
  }

  // ---------------- ADD / EDIT FORM ----------------

  Widget _buildFormScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isEditing ? AppStrings.editTask : AppStrings.addTask,
          style: AppStyles.heading2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: AppStyles.heading3),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              hintText: 'Enter task title...',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 20),

            Text('Description', style: AppStyles.heading3),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descController,
              hintText: 'Enter task description...',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            Text('Category', style: AppStyles.heading3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _fieldDecoration('Select category'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: AppStyles.bodyLarge),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 20),

            Text('Priority', style: AppStyles.heading3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: _fieldDecoration('Select priority'),
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority, style: AppStyles.bodyLarge),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
            const SizedBox(height: 20),

            Text('Due Date', style: AppStyles.heading3),
            const SizedBox(height: 8),
            TextField(
              controller: _dueDateController,
              readOnly: true,
              decoration: _fieldDecoration('Select due date').copyWith(
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: green,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.date_range,
                    color: green,
                  ),
                  onPressed: () async {
                    final now = DateTime.now();

                    final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(
                        _dueDateController.text,
                      ) ??
                          now,
                      firstDate: DateTime(
                        now.year,
                        now.month,
                        now.day,
                      ),
                      lastDate: DateTime(2100),
                    );

                    if (selected != null) {
                      _dueDateController.text =
                      '${selected.year.toString().padLeft(4, '0')}-'
                          '${selected.month.toString().padLeft(2, '0')}-'
                          '${selected.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: _isEditing ? AppStrings.update : AppStrings.save,
              onPressed: _saveTask,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showDetails && widget.task != null) {
      return _buildDetailsScreen();
    }

    return _buildFormScreen();
  }
}

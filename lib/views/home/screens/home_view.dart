import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_styles.dart';
import '../../../models/user_model.dart';
import '../../../models/task_model.dart';
import '../../../utils/api_service.dart';
import '../../../widgets/task_card.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../profile/profile_view.dart';
import '../../task/task_detail_view.dart';
import 'notification_view.dart';

class HomeView extends StatefulWidget {
  final UserModel user;

  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  int _currentIndex = 0;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  late UserModel _currentUser;
  String? _profileImageBase64;

  // Add Task controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String _selectedCategory = 'Work';
  String _selectedPriority = 'Medium';
  bool _isSavingTask = false;

  final List<String> _categories = ['Work', 'Personal', 'Study', 'Finance', 'Health'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    _fetchTasks();
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose();
    _titleController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _fetchTasks() async {
    setState(() => _isLoading = true);
    List<TaskModel> tasks = await ApiService.getTasks(_currentUser.id);
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _toggleTaskCompletion(TaskModel task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    bool success = await ApiService.updateTask(task);
    if (!success) {
      setState(() {
        task.isCompleted = !task.isCompleted;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update task status")),
      );
    }
  }

  void _deleteTask(int taskId) async {
    bool success = await ApiService.deleteTask(taskId, _currentUser.id);
    if (success) {
      setState(() {
        _tasks.removeWhere((t) => t.id == taskId);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete task")),
      );
    }
  }

  void _saveNewTask() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final dueDate = _dueDateController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task title is required")),
      );
      return;
    }

    setState(() => _isSavingTask = true);
    bool success = await ApiService.addTask(
      _currentUser.id,
      title,
      description,
      _selectedCategory,
      dueDate,
      _selectedPriority,
    );
    setState(() => _isSavingTask = false);

    if (success) {
      _titleController.clear();
      _descController.clear();
      _dueDateController.clear();
      setState(() {
        _selectedCategory = 'Work';
        _selectedPriority = 'Medium';
        _currentIndex = 0;
      });
      _motionTabBarController?.index = 0;
      _fetchTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task created successfully!")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create task")),
      );
    }
  }

  Widget _buildTaskDashboard() {
    List<TaskModel> filteredTasks = _tasks.where((task) {
      bool matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Pending') {
        return matchesSearch && !task.isCompleted;
      } else if (_selectedFilter == 'Completed') {
        return matchesSearch && task.isCompleted;
      }
      return matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredTasks.length} Tasks',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: AppStrings.searchTasks,
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: ['All', 'Pending', 'Completed'].map((filter) {
              bool isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.task_outlined, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text("No tasks found", style: AppStyles.heading3.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _fetchTasks(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onCheckboxChanged: (val) => _toggleTaskCompletion(task),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailView(task: task, userId: _currentUser.id),
                                ),
                              );
                              if (result == true) {
                                _fetchTasks();
                              }
                            },
                            onDelete: () => _deleteTask(task.id),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildAddTaskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Task',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text("Title", style: AppStyles.heading3),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _titleController,
            hintText: "Enter task title...",
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 16),
          Text("Description", style: AppStyles.heading3),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _descController,
            hintText: "Enter task description...",
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text("Category", style: AppStyles.heading3),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat, style: AppStyles.bodyLarge));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),
          Text("Priority", style: AppStyles.heading3),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            ),
            items: _priorities.map((pri) {
              return DropdownMenuItem(value: pri, child: Text(pri, style: AppStyles.bodyLarge));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedPriority = val);
            },
          ),
          const SizedBox(height: 16),
          Text("Due Date", style: AppStyles.heading3),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _dueDateController,
            hintText: "e.g. 2026-12-31",
            prefixIcon: Icons.calendar_today,
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: "Save Task",
            onPressed: _saveNewTask,
            isLoading: _isSavingTask,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildTaskDashboard(),
      _buildAddTaskTab(),
      ProfileView(
        user: _currentUser,
        profileImageBase64: _profileImageBase64,
        onUserUpdated: (updatedUser) {
          setState(() {
            _currentUser = updatedUser;
          });
        },
        onImageUpdated: (newImage) {
          setState(() {
            _profileImageBase64 = newImage;
          });
        },
        onMyTasksTap: () {
          setState(() {
            _currentIndex = 0;
          });
          _motionTabBarController?.index = 0;
        },
        onAddTaskTap: () {
          setState(() {
            _currentIndex = 1;
          });
          _motionTabBarController?.index = 1;
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _currentIndex == 0
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: _profileImageBase64 != null
                        ? MemoryImage(base64Decode(_profileImageBase64!))
                        : null,
                    child: _profileImageBase64 == null
                        ? Text(
                            _currentUser.name.isNotEmpty ? _currentUser.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello ${_currentUser.name}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        "Welcome to Task Manager",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                      _motionTabBarController?.index = 0;
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentIndex == 1 ? "Add Task" : "Profile",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
        actions: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationView()),
                  );
                },
              ),
            ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "My Tasks",
        labels: const ["My Tasks", "Add Task", "Profile"],
        icons: const [Icons.home_outlined, Icons.add_rounded, Icons.person_outline_rounded],
        tabSize: 50,
        tabBarColor: AppColors.surface,
        tabIconColor: AppColors.textSecondary,
        tabSelectedColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        onTabItemSelected: (int value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }
}

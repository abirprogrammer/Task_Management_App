import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/task_model.dart';

class CalendarView extends StatelessWidget {
  final List<TaskModel> tasks;

  const CalendarView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Task Calendar", style: AppStyles.heading2),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("October 2026", style: AppStyles.heading3),
                      const Row(
                        children: [
                          Icon(Icons.chevron_left, color: AppColors.textPrimary),
                          SizedBox(width: 16),
                          Icon(Icons.chevron_right, color: AppColors.textPrimary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) => Text(day, style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Simple grid representation for calendar days
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      bool isToday = day == 27;
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$day",
                          style: AppStyles.bodyMedium.copyWith(
                            color: isToday ? Colors.white : AppColors.textPrimary,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Scheduled Tasks", style: AppStyles.heading3),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text("No tasks scheduled.", style: AppStyles.bodyMedium))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event, color: AppColors.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: AppStyles.heading3),
                                    const SizedBox(height: 4),
                                    Text(task.dueDate.isNotEmpty ? task.dueDate : "No due date", style: AppStyles.bodyMedium),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

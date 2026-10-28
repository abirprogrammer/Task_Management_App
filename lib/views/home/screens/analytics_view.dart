import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/task_model.dart';

class AnalyticsView extends StatelessWidget {
  final List<TaskModel> tasks;

  const AnalyticsView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    int total = tasks.length;
    int completed = tasks.where((t) => t.isCompleted).length;
    int pending = total - completed;
    double progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Productivity Analytics", style: AppStyles.heading2),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Overall Progress", style: AppStyles.bodyMedium.copyWith(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text("${(progress * 100).toStringAsFixed(0)}% Completed", style: AppStyles.heading1.copyWith(color: Colors.white)),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Task Statistics", style: AppStyles.heading3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_turned_in, color: AppColors.lowPriority),
                        const SizedBox(height: 12),
                        Text("$completed", style: AppStyles.heading1),
                        const SizedBox(height: 4),
                        Text("Completed", style: AppStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.pending_actions, color: AppColors.mediumPriority),
                        const SizedBox(height: 12),
                        Text("$pending", style: AppStyles.heading1),
                        const SizedBox(height: 4),
                        Text("Pending", style: AppStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {"title": "Task Reminder", "desc": "Project presentation due in 2 hours.", "time": "10m ago"},
      {"title": "Daily Goal Achieved!", "desc": "You completed all your tasks for yesterday.", "time": "1d ago"},
      {"title": "Welcome to TaskMaster Pro", "desc": "Start organizing your daily schedule effortlessly.", "time": "2d ago"},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Notifications", style: AppStyles.heading2),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.notifications, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item["title"]!, style: AppStyles.heading3),
                          Text(item["time"]!, style: AppStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item["desc"]!, style: AppStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
final TaskModel task;
final ValueChanged<bool?> onCheckboxChanged;
final VoidCallback onTap;
final VoidCallback onDelete;

const TaskCard({
super.key,
required this.task,
required this.onCheckboxChanged,
required this.onTap,
required this.onDelete,
});

@override
Widget build(BuildContext context) {
return Container(
margin: const EdgeInsets.symmetric(vertical: 8),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE5F4D3),
width: 1,
),
boxShadow: const [
BoxShadow(
color: Color(0x08000000),
blurRadius: 10,
offset: Offset(0, 4),
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(16),
child: Stack(
children: [
// Full card background image.
Positioned.fill(
child: Image.asset(
'assets/images/taskitem.png',
fit: BoxFit.cover,
alignment: Alignment.center,
errorBuilder: (context, error, stackTrace) {
debugPrint('Task background image error: $error');
return const SizedBox.shrink();
},
),
),

// Task content.
Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Task icon with check badge.
Stack(
clipBehavior: Clip.none,
children: [
Container(
width: 36,
height: 36,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: const Color(0xFFD4E8B0),
),
),
child: const Icon(
Icons.assignment_outlined,
size: 20,
color: AppColors.primary,
),
),
Positioned(
right: -2,
bottom: -2,
child: Container(
width: 14,
height: 14,
decoration: const BoxDecoration(
color: AppColors.primary,
shape: BoxShape.circle,
),
child: const Icon(
Icons.check,
size: 9,
color: Colors.white,
),
),
),
],
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Task title and delete button.
Row(
children: [
Expanded(
child: Text(
task.title,
style: AppStyles.heading3.copyWith(
fontSize: 16,
fontWeight: FontWeight.w700,
decoration: task.isCompleted
? TextDecoration.lineThrough
    : TextDecoration.none,
color: task.isCompleted
? AppColors.textHint
    : AppColors.textPrimary,
),
),
),
IconButton(
tooltip: 'Delete task',
icon: const Icon(
Icons.delete_outline,
size: 18,
color: AppColors.textHint,
),
padding: EdgeInsets.zero,
constraints: const BoxConstraints(
minWidth: 32,
minHeight: 32,
),
onPressed: onDelete,
),
],
),

// Task description.
if (task.description.isNotEmpty) ...[
const SizedBox(height: 6),
Text(
task.description,
style: AppStyles.bodyMedium.copyWith(
color: AppColors.textSecondary,
fontSize: 13,
height: 1.4,
),
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
],

const SizedBox(height: 12),

// Category, due date and checkbox.
Row(
children: [
Flexible(
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 4,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(6),
),
child: Text(
task.category,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: AppStyles.caption.copyWith(
color: AppColors.primary,
fontWeight: FontWeight.w600,
),
),
),
),

if (task.dueDate.isNotEmpty) ...[
const SizedBox(width: 10),
const Icon(
Icons.calendar_today_outlined,
size: 13,
color: AppColors.textSecondary,
),
const SizedBox(width: 4),
Flexible(
child: Text(
task.dueDate,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: AppStyles.caption.copyWith(
color: AppColors.textSecondary,
),
),
),
],

const Spacer(),

Transform.scale(
scale: 0.9,
child: Checkbox(
value: task.isCompleted,
onChanged: onCheckboxChanged,
activeColor: AppColors.primary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(4),
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
),
),
],
),
),
);
}
}

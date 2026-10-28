class TaskModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String category;
  final String dueDate;
  final String priority;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Work',
      dueDate: json['due_date'] ?? '',
      priority: json['priority'] ?? 'Medium',
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true || json['is_completed'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'due_date': dueDate,
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}

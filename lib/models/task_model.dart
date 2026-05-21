class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String imagePath;
  final String priority;
  final DateTime dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.imagePath,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      imagePath: map['imagePath'] ?? '',
      priority: map['priority'] ?? 'Media',
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
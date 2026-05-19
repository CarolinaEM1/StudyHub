class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String imagePath;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.imagePath,
    required this.createdAt,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      imagePath: map['imagePath'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
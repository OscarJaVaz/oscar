class TaskModel {
  final int? id;
  final String title;
  final String description;
  final int completed;
  final String createdAt;

  const TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      completed: map['completed'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'created_at': createdAt,
    };
  }
}

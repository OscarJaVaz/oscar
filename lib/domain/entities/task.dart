class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

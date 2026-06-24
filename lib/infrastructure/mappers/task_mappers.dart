import '../../domain/entities/task.dart';
import '../models/task_model.dart';

class TaskMappers {
  static Task toEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      description: model.description,
      completed: model.completed == 1,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  static TaskModel toModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      completed: entity.completed ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

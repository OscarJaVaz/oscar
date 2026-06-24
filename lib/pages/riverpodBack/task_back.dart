import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../infrastructure/datasources/task_datasource.dart';
import '../../infrastructure/repositories/task_repository_impl.dart';

// null = nueva tarea, distinto de null = editar
final selectedTaskProvider = StateProvider<Task?>((ref) => null);

// Se activa en true justo antes de navegar a '/' tras crear una tarea
final taskJustCreatedProvider = StateProvider<bool>((ref) => false);

final taskDatasourceProvider = Provider<TaskDatasource>(
  (ref) => TaskDatasource(),
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(taskDatasourceProvider));
});

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _repository.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask(String title, String description) async {
    try {
      final task = Task(
        title: title,
        description: description,
        completed: false,
        createdAt: DateTime.now(),
      );
      await _repository.createTask(task);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleCompleted(Task task) async {
    try {
      await _repository.updateTask(task.copyWith(completed: !task.completed));
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

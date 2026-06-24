import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<Task>> getTasks() => _datasource.getTasks();

  @override
  Future<Task> createTask(Task task) => _datasource.createTask(task);

  @override
  Future<Task> updateTask(Task task) => _datasource.updateTask(task);

  @override
  Future<void> deleteTask(int id) => _datasource.deleteTask(id);
}

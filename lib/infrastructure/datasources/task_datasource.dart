import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/task.dart';
import '../mappers/task_mappers.dart';
import '../models/task_model.dart';

class TaskDatasource {
  static final TaskDatasource _instance = TaskDatasource._internal();
  factory TaskDatasource() => _instance;
  TaskDatasource._internal();


  Future<Database>? _dbFuture;

  Future<Database> get database {
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT    NOT NULL,
            description TEXT    NOT NULL,
            completed   INTEGER NOT NULL DEFAULT 0,
            created_at  TEXT    NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'created_at DESC');
    return rows
        .map((row) => TaskMappers.toEntity(TaskModel.fromMap(row)))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    final db = await database;
    final model = TaskMappers.toModel(task);
    final id = await db.insert('tasks', model.toMap());
    return task.copyWith(id: id);
  }

  Future<Task> updateTask(Task task) async {
    final db = await database;
    final model = TaskMappers.toModel(task);
    await db.update(
      'tasks',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await _dbFuture;
    if (db != null) {
      await db.close();
      _dbFuture = null;
    }
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  // singleton pattern
  static LocalDb instance = LocalDb._internal();

  // named constructor
  LocalDb._internal();

  // factory constructor
  factory LocalDb() {
    return instance;
  }

  // vars
  static const _tableName = "Tasks3";
  static const _nameColumn = "name";
  static const _descriptionColumn = "description";
  static const _statusColumn = "status";
  static const _hideItem="isHideItem";

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await initDatabase();
    return _db!;
  }

  // // creation of database tasks
  // Future<void> createTable() async {
  //   final db = await database;
  //   db.execute('''
  //     CREATE TABLE $_tableName (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       $_nameColumn TEXT NOT NULL,
  //       $_statusColumn INTEGER NOT NULL,
  //       $_descriptionColumn TEXT NOT NULL
  //     )
  //   ''');

  //   log("TASKS table created");
  // }

  Future<Database> initDatabase() async {
    final databasePathOS = await getDatabasesPath();
    final dbPath = join(databasePathOS, "tasks2.db");
    final db = await openDatabase(
      version: 4,
      dbPath,
      onCreate: (db, version) {
        db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_nameColumn TEXT NOT NULL,
        $_statusColumn INTEGER NOT NULL,
        $_descriptionColumn TEXT NOT NULL,
        $_hideItem INTEGER NOT NULL
      )
    ''');
      },
    );
    return db;
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;

    return await db.query(_tableName);
  }

  // add task
  Future<void> addTask({
    required String name,
    required String description,
  }) async {
    final db = await database;
    db.insert(_tableName, {
      _nameColumn: name,
      _descriptionColumn: description,
      _statusColumn: 0,
      _hideItem:0,
    });
  }

  // delete task
  Future<bool> deleteTask(int id) async {
    final db = await database;
    try {
      await db.delete(_tableName, where: "id=?", whereArgs: [id]);
      log("$id taks deleted successfully");

      return true;
    } catch (e) {
      log("$id taks deleted unsuccessfully");

      log("$e");
    }
    return false;
  }

  // status update
  Future<void> updateStatus({
    required int id,
    required int newValue,
  }) async {
    final db = await database;
    db.update(
      _tableName,
      {
        _statusColumn: newValue,
      },
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<void> updateHide({
    required int id,
    required int newValue,
  }) async {
    final db = await database;
    db.update(
      _tableName,
      {
        _hideItem: newValue,
      },
      where: "id=?",
      whereArgs: [id],
    );
  }

  // update task
  Future<void> updateTask({
    required String name,
    required String description,
    required int id,

  }) async {
    final db = await database;

    await db.update(
      _tableName,
      {
        _nameColumn: name,
        _descriptionColumn: description,
      },
      where: "id=?",
      whereArgs: [id],
    );
  }
}

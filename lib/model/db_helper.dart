import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer/model/user_setting.dart';

final String TableName = 'userSetting';

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'UserSetting.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $TableName(id INTEGER PRIMARY KEY, hours INTEGER, minutes INTEGER, seconds hours INTEGER)');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  //create
  createData(UserSetting userSetting) async {
    final db = await database;
    var res = await db.rawInsert(
        'INSERT INTO $TableName(hours, minutes, seconds) VALUES(?, ?, ?)',
        [userSetting.hours, userSetting.minutes, userSetting.seconds]);
    return res;
  }

  //read
  readData(int id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $TableName WHERE id = ?', [id]);
    return res.isNotEmpty
        ? UserSetting(
            id: res.first['id'],
            hours: res.first['hours'],
            minutes: res.first['minutes'],
            seconds: res.first['seconds'])
        : Null;
  }

  //readAll
  Future<List<UserSetting>> readAllData() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $TableName');
    List<UserSetting> list = res.isNotEmpty
        ? res
            .map((e) => UserSetting(
                id: e['id'],
                hours: e['hours'],
                minutes: e['minutes'],
                seconds: e['seconds']))
            .toList()
        : [];
    return list;
  }

  //delete
  deleteData(int id) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName WHERE id = ?', [id]);
    return res;
  }

  //delete All
  deleteAllData() async {
    final db = await database;
    db.rawDelete('DELETE FROM $TableName');
  }

  updateData(UserSetting userSetting) async {
    final db = await database;
    var res = db.rawUpdate(
        'UPDATE $TableName SET hours = ? SET minutes = ? SET seconds = ? WHERE = ?',
        [
          userSetting.hours,
          userSetting.minutes,
          userSetting.seconds,
          userSetting.id
        ]);
    return res;
  }
}

// required package imports
import 'dart:async';
import 'package:danny/common/call_dao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'call.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Call])
abstract class AppDatabase extends FloorDatabase {
  CallDao get callDao;
}

import 'package:floor/floor.dart';

import 'call.dart';

@dao
abstract class CallDao {
  @Query('SELECT * FROM Call')
  Future<List<Call>> getCalls();

  @insert
  Future<void> insertCall(Call call);

  @delete
  Future<void> deleteCall(Call call);
}

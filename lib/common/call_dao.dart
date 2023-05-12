import 'package:floor/floor.dart';

import 'call.dart';

@dao
abstract class CallDao {
  @Query('SELECT * FROM Call')
  Future<List<Call>> getCalls();
  
  @Query('SELECT * FROM Call')
  Stream<List<Call>> getCallsAsStream();

  @insert
  Future<void> insertCall(Call call);

  @delete
  Future<void> deleteCall(Call call);
}

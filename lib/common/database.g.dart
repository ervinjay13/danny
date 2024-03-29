// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CallDao? _callDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Call` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `tts` TEXT NOT NULL, `imageBase64` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CallDao get callDao {
    return _callDaoInstance ??= _$CallDao(database, changeListener);
  }
}

class _$CallDao extends CallDao {
  _$CallDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _callInsertionAdapter = InsertionAdapter(
            database,
            'Call',
            (Call item) => <String, Object?>{
                  'id': item.id,
                  'tts': item.tts,
                  'imageBase64': item.imageBase64
                },
            changeListener),
        _callUpdateAdapter = UpdateAdapter(
            database,
            'Call',
            ['id'],
            (Call item) => <String, Object?>{
                  'id': item.id,
                  'tts': item.tts,
                  'imageBase64': item.imageBase64
                },
            changeListener),
        _callDeletionAdapter = DeletionAdapter(
            database,
            'Call',
            ['id'],
            (Call item) => <String, Object?>{
                  'id': item.id,
                  'tts': item.tts,
                  'imageBase64': item.imageBase64
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Call> _callInsertionAdapter;

  final UpdateAdapter<Call> _callUpdateAdapter;

  final DeletionAdapter<Call> _callDeletionAdapter;

  @override
  Future<List<Call>> getCalls() async {
    return _queryAdapter.queryList('SELECT * FROM Call',
        mapper: (Map<String, Object?> row) => Call(row['id'] as int?,
            row['tts'] as String, row['imageBase64'] as String));
  }

  @override
  Stream<List<Call>> getCallsAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM Call',
        mapper: (Map<String, Object?> row) => Call(row['id'] as int?,
            row['tts'] as String, row['imageBase64'] as String),
        queryableName: 'Call',
        isView: false);
  }

  @override
  Future<void> deleteAllCalls() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Call');
  }

  @override
  Future<void> insertCall(Call call) async {
    await _callInsertionAdapter.insert(call, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCall(Call call) async {
    await _callUpdateAdapter.update(call, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCall(Call call) async {
    await _callDeletionAdapter.delete(call);
  }
}

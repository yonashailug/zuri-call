import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'zuri_database.g.dart';

@DataClassName('CallRecordRow')
class CallRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get phone => text()();

  DateTimeColumn get startedAt => dateTime()();

  TextColumn get direction => text()();

  TextColumn get status => text()();

  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}

@DataClassName('CachedContactRow')
class CachedContacts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get phone => text()();

  DateTimeColumn get cachedAt => dateTime()();
}

@DriftDatabase(tables: [CallRecords, CachedContacts])
class ZuriDatabase extends _$ZuriDatabase {
  ZuriDatabase(super.executor);

  factory ZuriDatabase.production() {
    return ZuriDatabase(
      LazyDatabase(() async {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(path.join(directory.path, 'zuri.sqlite'));
        return NativeDatabase.createInBackground(file);
      }),
    );
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(cachedContacts);
        }
      },
    );
  }
}

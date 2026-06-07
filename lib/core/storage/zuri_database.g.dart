// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zuri_database.dart';

// ignore_for_file: type=lint
class $CallRecordsTable extends CallRecords
    with TableInfo<$CallRecordsTable, CallRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, startedAt, direction, status, durationSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_records';
  @override
  VerificationContext validateIntegrity(Insertable<CallRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallRecordRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
    );
  }

  @override
  $CallRecordsTable createAlias(String alias) {
    return $CallRecordsTable(attachedDatabase, alias);
  }
}

class CallRecordRow extends DataClass implements Insertable<CallRecordRow> {
  final int id;
  final String name;
  final String phone;
  final DateTime startedAt;
  final String direction;
  final String status;
  final int durationSeconds;
  const CallRecordRow(
      {required this.id,
      required this.name,
      required this.phone,
      required this.startedAt,
      required this.direction,
      required this.status,
      required this.durationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['direction'] = Variable<String>(direction);
    map['status'] = Variable<String>(status);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  CallRecordsCompanion toCompanion(bool nullToAbsent) {
    return CallRecordsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      startedAt: Value(startedAt),
      direction: Value(direction),
      status: Value(status),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory CallRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallRecordRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String>(json['status']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String>(status),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  CallRecordRow copyWith(
          {int? id,
          String? name,
          String? phone,
          DateTime? startedAt,
          String? direction,
          String? status,
          int? durationSeconds}) =>
      CallRecordRow(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        startedAt: startedAt ?? this.startedAt,
        direction: direction ?? this.direction,
        status: status ?? this.status,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
  CallRecordRow copyWithCompanion(CallRecordsCompanion data) {
    return CallRecordRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallRecordRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('startedAt: $startedAt, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, phone, startedAt, direction, status, durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallRecordRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.startedAt == this.startedAt &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.durationSeconds == this.durationSeconds);
}

class CallRecordsCompanion extends UpdateCompanion<CallRecordRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<DateTime> startedAt;
  final Value<String> direction;
  final Value<String> status;
  final Value<int> durationSeconds;
  const CallRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  });
  CallRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    required DateTime startedAt,
    required String direction,
    required String status,
    this.durationSeconds = const Value.absent(),
  })  : name = Value(name),
        phone = Value(phone),
        startedAt = Value(startedAt),
        direction = Value(direction),
        status = Value(status);
  static Insertable<CallRecordRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<DateTime>? startedAt,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<int>? durationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (startedAt != null) 'started_at': startedAt,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    });
  }

  CallRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<DateTime>? startedAt,
      Value<String>? direction,
      Value<String>? status,
      Value<int>? durationSeconds}) {
    return CallRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      startedAt: startedAt ?? this.startedAt,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('startedAt: $startedAt, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }
}

class $CachedContactsTable extends CachedContacts
    with TableInfo<$CachedContactsTable, CachedContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_contacts';
  @override
  VerificationContext validateIntegrity(Insertable<CachedContactRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedContactRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedContactsTable createAlias(String alias) {
    return $CachedContactsTable(attachedDatabase, alias);
  }
}

class CachedContactRow extends DataClass
    implements Insertable<CachedContactRow> {
  final int id;
  final String name;
  final String phone;
  final DateTime cachedAt;
  const CachedContactRow(
      {required this.id,
      required this.name,
      required this.phone,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedContactsCompanion toCompanion(bool nullToAbsent) {
    return CachedContactsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedContactRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedContactRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedContactRow copyWith(
          {int? id, String? name, String? phone, DateTime? cachedAt}) =>
      CachedContactRow(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedContactRow copyWithCompanion(CachedContactsCompanion data) {
    return CachedContactRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedContactRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedContactRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.cachedAt == this.cachedAt);
}

class CachedContactsCompanion extends UpdateCompanion<CachedContactRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<DateTime> cachedAt;
  const CachedContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    required DateTime cachedAt,
  })  : name = Value(name),
        phone = Value(phone),
        cachedAt = Value(cachedAt);
  static Insertable<CachedContactRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedContactsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<DateTime>? cachedAt}) {
    return CachedContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$ZuriDatabase extends GeneratedDatabase {
  _$ZuriDatabase(QueryExecutor e) : super(e);
  $ZuriDatabaseManager get managers => $ZuriDatabaseManager(this);
  late final $CallRecordsTable callRecords = $CallRecordsTable(this);
  late final $CachedContactsTable cachedContacts = $CachedContactsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [callRecords, cachedContacts];
}

typedef $$CallRecordsTableCreateCompanionBuilder = CallRecordsCompanion
    Function({
  Value<int> id,
  required String name,
  required String phone,
  required DateTime startedAt,
  required String direction,
  required String status,
  Value<int> durationSeconds,
});
typedef $$CallRecordsTableUpdateCompanionBuilder = CallRecordsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<DateTime> startedAt,
  Value<String> direction,
  Value<String> status,
  Value<int> durationSeconds,
});

class $$CallRecordsTableFilterComposer
    extends Composer<_$ZuriDatabase, $CallRecordsTable> {
  $$CallRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));
}

class $$CallRecordsTableOrderingComposer
    extends Composer<_$ZuriDatabase, $CallRecordsTable> {
  $$CallRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));
}

class $$CallRecordsTableAnnotationComposer
    extends Composer<_$ZuriDatabase, $CallRecordsTable> {
  $$CallRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);
}

class $$CallRecordsTableTableManager extends RootTableManager<
    _$ZuriDatabase,
    $CallRecordsTable,
    CallRecordRow,
    $$CallRecordsTableFilterComposer,
    $$CallRecordsTableOrderingComposer,
    $$CallRecordsTableAnnotationComposer,
    $$CallRecordsTableCreateCompanionBuilder,
    $$CallRecordsTableUpdateCompanionBuilder,
    (
      CallRecordRow,
      BaseReferences<_$ZuriDatabase, $CallRecordsTable, CallRecordRow>
    ),
    CallRecordRow,
    PrefetchHooks Function()> {
  $$CallRecordsTableTableManager(_$ZuriDatabase db, $CallRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              CallRecordsCompanion(
            id: id,
            name: name,
            phone: phone,
            startedAt: startedAt,
            direction: direction,
            status: status,
            durationSeconds: durationSeconds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String phone,
            required DateTime startedAt,
            required String direction,
            required String status,
            Value<int> durationSeconds = const Value.absent(),
          }) =>
              CallRecordsCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            startedAt: startedAt,
            direction: direction,
            status: status,
            durationSeconds: durationSeconds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CallRecordsTableProcessedTableManager = ProcessedTableManager<
    _$ZuriDatabase,
    $CallRecordsTable,
    CallRecordRow,
    $$CallRecordsTableFilterComposer,
    $$CallRecordsTableOrderingComposer,
    $$CallRecordsTableAnnotationComposer,
    $$CallRecordsTableCreateCompanionBuilder,
    $$CallRecordsTableUpdateCompanionBuilder,
    (
      CallRecordRow,
      BaseReferences<_$ZuriDatabase, $CallRecordsTable, CallRecordRow>
    ),
    CallRecordRow,
    PrefetchHooks Function()>;
typedef $$CachedContactsTableCreateCompanionBuilder = CachedContactsCompanion
    Function({
  Value<int> id,
  required String name,
  required String phone,
  required DateTime cachedAt,
});
typedef $$CachedContactsTableUpdateCompanionBuilder = CachedContactsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<DateTime> cachedAt,
});

class $$CachedContactsTableFilterComposer
    extends Composer<_$ZuriDatabase, $CachedContactsTable> {
  $$CachedContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedContactsTableOrderingComposer
    extends Composer<_$ZuriDatabase, $CachedContactsTable> {
  $$CachedContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedContactsTableAnnotationComposer
    extends Composer<_$ZuriDatabase, $CachedContactsTable> {
  $$CachedContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedContactsTableTableManager extends RootTableManager<
    _$ZuriDatabase,
    $CachedContactsTable,
    CachedContactRow,
    $$CachedContactsTableFilterComposer,
    $$CachedContactsTableOrderingComposer,
    $$CachedContactsTableAnnotationComposer,
    $$CachedContactsTableCreateCompanionBuilder,
    $$CachedContactsTableUpdateCompanionBuilder,
    (
      CachedContactRow,
      BaseReferences<_$ZuriDatabase, $CachedContactsTable, CachedContactRow>
    ),
    CachedContactRow,
    PrefetchHooks Function()> {
  $$CachedContactsTableTableManager(
      _$ZuriDatabase db, $CachedContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedContactsCompanion(
            id: id,
            name: name,
            phone: phone,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String phone,
            required DateTime cachedAt,
          }) =>
              CachedContactsCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedContactsTableProcessedTableManager = ProcessedTableManager<
    _$ZuriDatabase,
    $CachedContactsTable,
    CachedContactRow,
    $$CachedContactsTableFilterComposer,
    $$CachedContactsTableOrderingComposer,
    $$CachedContactsTableAnnotationComposer,
    $$CachedContactsTableCreateCompanionBuilder,
    $$CachedContactsTableUpdateCompanionBuilder,
    (
      CachedContactRow,
      BaseReferences<_$ZuriDatabase, $CachedContactsTable, CachedContactRow>
    ),
    CachedContactRow,
    PrefetchHooks Function()>;

class $ZuriDatabaseManager {
  final _$ZuriDatabase _db;
  $ZuriDatabaseManager(this._db);
  $$CallRecordsTableTableManager get callRecords =>
      $$CallRecordsTableTableManager(_db, _db.callRecords);
  $$CachedContactsTableTableManager get cachedContacts =>
      $$CachedContactsTableTableManager(_db, _db.cachedContacts);
}

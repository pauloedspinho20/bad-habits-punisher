// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconPathMeta =
      const VerificationMeta('iconPath');
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
      'icon_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sensitivityMeta =
      const VerificationMeta('sensitivity');
  @override
  late final GeneratedColumn<double> sensitivity = GeneratedColumn<double>(
      'sensitivity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.6));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconPath, enabled, sensitivity, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(Insertable<Habit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_path')) {
      context.handle(_iconPathMeta,
          iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta));
    } else if (isInserting) {
      context.missing(_iconPathMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
          _sensitivityMeta,
          sensitivity.isAcceptableOrUnknown(
              data['sensitivity']!, _sensitivityMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_path'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      sensitivity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sensitivity'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String name;
  final String iconPath;
  final bool enabled;
  final double sensitivity;
  final int sortOrder;
  const Habit(
      {required this.id,
      required this.name,
      required this.iconPath,
      required this.enabled,
      required this.sensitivity,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_path'] = Variable<String>(iconPath);
    map['enabled'] = Variable<bool>(enabled);
    map['sensitivity'] = Variable<double>(sensitivity);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      iconPath: Value(iconPath),
      enabled: Value(enabled),
      sensitivity: Value(sensitivity),
      sortOrder: Value(sortOrder),
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconPath: serializer.fromJson<String>(json['iconPath']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      sensitivity: serializer.fromJson<double>(json['sensitivity']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconPath': serializer.toJson<String>(iconPath),
      'enabled': serializer.toJson<bool>(enabled),
      'sensitivity': serializer.toJson<double>(sensitivity),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Habit copyWith(
          {String? id,
          String? name,
          String? iconPath,
          bool? enabled,
          double? sensitivity,
          int? sortOrder}) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        iconPath: iconPath ?? this.iconPath,
        enabled: enabled ?? this.enabled,
        sensitivity: sensitivity ?? this.sensitivity,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      sensitivity:
          data.sensitivity.present ? data.sensitivity.value : this.sensitivity,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconPath: $iconPath, ')
          ..write('enabled: $enabled, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconPath, enabled, sensitivity, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconPath == this.iconPath &&
          other.enabled == this.enabled &&
          other.sensitivity == this.sensitivity &&
          other.sortOrder == this.sortOrder);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconPath;
  final Value<bool> enabled;
  final Value<double> sensitivity;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    required String iconPath,
    this.enabled = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconPath = Value(iconPath);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconPath,
    Expression<bool>? enabled,
    Expression<double>? sensitivity,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconPath != null) 'icon_path': iconPath,
      if (enabled != null) 'enabled': enabled,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? iconPath,
      Value<bool>? enabled,
      Value<double>? sensitivity,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      enabled: enabled ?? this.enabled,
      sensitivity: sensitivity ?? this.sensitivity,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<double>(sensitivity.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconPath: $iconPath, ')
          ..write('enabled: $enabled, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectionEventsTable extends DetectionEvents
    with TableInfo<$DetectionEventsTable, DetectionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, habitId, timestamp, durationMs, confidence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detection_events';
  @override
  VerificationContext validateIntegrity(Insertable<DetectionEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetectionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetectionEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
    );
  }

  @override
  $DetectionEventsTable createAlias(String alias) {
    return $DetectionEventsTable(attachedDatabase, alias);
  }
}

class DetectionEvent extends DataClass implements Insertable<DetectionEvent> {
  final int id;
  final String habitId;
  final DateTime timestamp;
  final int durationMs;
  final double confidence;
  const DetectionEvent(
      {required this.id,
      required this.habitId,
      required this.timestamp,
      required this.durationMs,
      required this.confidence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['duration_ms'] = Variable<int>(durationMs);
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  DetectionEventsCompanion toCompanion(bool nullToAbsent) {
    return DetectionEventsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      timestamp: Value(timestamp),
      durationMs: Value(durationMs),
      confidence: Value(confidence),
    );
  }

  factory DetectionEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetectionEvent(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'durationMs': serializer.toJson<int>(durationMs),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  DetectionEvent copyWith(
          {int? id,
          String? habitId,
          DateTime? timestamp,
          int? durationMs,
          double? confidence}) =>
      DetectionEvent(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        timestamp: timestamp ?? this.timestamp,
        durationMs: durationMs ?? this.durationMs,
        confidence: confidence ?? this.confidence,
      );
  DetectionEvent copyWithCompanion(DetectionEventsCompanion data) {
    return DetectionEvent(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetectionEvent(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('timestamp: $timestamp, ')
          ..write('durationMs: $durationMs, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, timestamp, durationMs, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectionEvent &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.timestamp == this.timestamp &&
          other.durationMs == this.durationMs &&
          other.confidence == this.confidence);
}

class DetectionEventsCompanion extends UpdateCompanion<DetectionEvent> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<DateTime> timestamp;
  final Value<int> durationMs;
  final Value<double> confidence;
  const DetectionEventsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  DetectionEventsCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required DateTime timestamp,
    required int durationMs,
    required double confidence,
  })  : habitId = Value(habitId),
        timestamp = Value(timestamp),
        durationMs = Value(durationMs),
        confidence = Value(confidence);
  static Insertable<DetectionEvent> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<DateTime>? timestamp,
    Expression<int>? durationMs,
    Expression<double>? confidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (timestamp != null) 'timestamp': timestamp,
      if (durationMs != null) 'duration_ms': durationMs,
      if (confidence != null) 'confidence': confidence,
    });
  }

  DetectionEventsCompanion copyWith(
      {Value<int>? id,
      Value<String>? habitId,
      Value<DateTime>? timestamp,
      Value<int>? durationMs,
      Value<double>? confidence}) {
    return DetectionEventsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      timestamp: timestamp ?? this.timestamp,
      durationMs: durationMs ?? this.durationMs,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionEventsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('timestamp: $timestamp, ')
          ..write('durationMs: $durationMs, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalDurationMsMeta =
      const VerificationMeta('totalDurationMs');
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
      'total_duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [date, habitId, count, totalDurationMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(Insertable<DailySummary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
          _totalDurationMsMeta,
          totalDurationMs.isAcceptableOrUnknown(
              data['total_duration_ms']!, _totalDurationMsMeta));
    } else if (isInserting) {
      context.missing(_totalDurationMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, habitId};
  @override
  DailySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummary(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      totalDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_duration_ms'])!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }
}

class DailySummary extends DataClass implements Insertable<DailySummary> {
  final String date;
  final String habitId;
  final int count;
  final int totalDurationMs;
  const DailySummary(
      {required this.date,
      required this.habitId,
      required this.count,
      required this.totalDurationMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['habit_id'] = Variable<String>(habitId);
    map['count'] = Variable<int>(count);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      date: Value(date),
      habitId: Value(habitId),
      count: Value(count),
      totalDurationMs: Value(totalDurationMs),
    );
  }

  factory DailySummary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummary(
      date: serializer.fromJson<String>(json['date']),
      habitId: serializer.fromJson<String>(json['habitId']),
      count: serializer.fromJson<int>(json['count']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'habitId': serializer.toJson<String>(habitId),
      'count': serializer.toJson<int>(count),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
    };
  }

  DailySummary copyWith(
          {String? date, String? habitId, int? count, int? totalDurationMs}) =>
      DailySummary(
        date: date ?? this.date,
        habitId: habitId ?? this.habitId,
        count: count ?? this.count,
        totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      );
  DailySummary copyWithCompanion(DailySummariesCompanion data) {
    return DailySummary(
      date: data.date.present ? data.date.value : this.date,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      count: data.count.present ? data.count.value : this.count,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummary(')
          ..write('date: $date, ')
          ..write('habitId: $habitId, ')
          ..write('count: $count, ')
          ..write('totalDurationMs: $totalDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, habitId, count, totalDurationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummary &&
          other.date == this.date &&
          other.habitId == this.habitId &&
          other.count == this.count &&
          other.totalDurationMs == this.totalDurationMs);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummary> {
  final Value<String> date;
  final Value<String> habitId;
  final Value<int> count;
  final Value<int> totalDurationMs;
  final Value<int> rowid;
  const DailySummariesCompanion({
    this.date = const Value.absent(),
    this.habitId = const Value.absent(),
    this.count = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    required String date,
    required String habitId,
    required int count,
    required int totalDurationMs,
    this.rowid = const Value.absent(),
  })  : date = Value(date),
        habitId = Value(habitId),
        count = Value(count),
        totalDurationMs = Value(totalDurationMs);
  static Insertable<DailySummary> custom({
    Expression<String>? date,
    Expression<String>? habitId,
    Expression<int>? count,
    Expression<int>? totalDurationMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (habitId != null) 'habit_id': habitId,
      if (count != null) 'count': count,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySummariesCompanion copyWith(
      {Value<String>? date,
      Value<String>? habitId,
      Value<int>? count,
      Value<int>? totalDurationMs,
      Value<int>? rowid}) {
    return DailySummariesCompanion(
      date: date ?? this.date,
      habitId: habitId ?? this.habitId,
      count: count ?? this.count,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('date: $date, ')
          ..write('habitId: $habitId, ')
          ..write('count: $count, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreaksTable extends Streaks with TableInfo<$StreaksTable, Streak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _currentLengthMeta =
      const VerificationMeta('currentLength');
  @override
  late final GeneratedColumn<int> currentLength = GeneratedColumn<int>(
      'current_length', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _longestLengthMeta =
      const VerificationMeta('longestLength');
  @override
  late final GeneratedColumn<int> longestLength = GeneratedColumn<int>(
      'longest_length', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, habitId, startDate, currentLength, longestLength];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streaks';
  @override
  VerificationContext validateIntegrity(Insertable<Streak> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('current_length')) {
      context.handle(
          _currentLengthMeta,
          currentLength.isAcceptableOrUnknown(
              data['current_length']!, _currentLengthMeta));
    } else if (isInserting) {
      context.missing(_currentLengthMeta);
    }
    if (data.containsKey('longest_length')) {
      context.handle(
          _longestLengthMeta,
          longestLength.isAcceptableOrUnknown(
              data['longest_length']!, _longestLengthMeta));
    } else if (isInserting) {
      context.missing(_longestLengthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Streak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Streak(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      currentLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_length'])!,
      longestLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_length'])!,
    );
  }

  @override
  $StreaksTable createAlias(String alias) {
    return $StreaksTable(attachedDatabase, alias);
  }
}

class Streak extends DataClass implements Insertable<Streak> {
  final int id;
  final String habitId;
  final DateTime startDate;
  final int currentLength;
  final int longestLength;
  const Streak(
      {required this.id,
      required this.habitId,
      required this.startDate,
      required this.currentLength,
      required this.longestLength});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['start_date'] = Variable<DateTime>(startDate);
    map['current_length'] = Variable<int>(currentLength);
    map['longest_length'] = Variable<int>(longestLength);
    return map;
  }

  StreaksCompanion toCompanion(bool nullToAbsent) {
    return StreaksCompanion(
      id: Value(id),
      habitId: Value(habitId),
      startDate: Value(startDate),
      currentLength: Value(currentLength),
      longestLength: Value(longestLength),
    );
  }

  factory Streak.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Streak(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      currentLength: serializer.fromJson<int>(json['currentLength']),
      longestLength: serializer.fromJson<int>(json['longestLength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<String>(habitId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'currentLength': serializer.toJson<int>(currentLength),
      'longestLength': serializer.toJson<int>(longestLength),
    };
  }

  Streak copyWith(
          {int? id,
          String? habitId,
          DateTime? startDate,
          int? currentLength,
          int? longestLength}) =>
      Streak(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        startDate: startDate ?? this.startDate,
        currentLength: currentLength ?? this.currentLength,
        longestLength: longestLength ?? this.longestLength,
      );
  Streak copyWithCompanion(StreaksCompanion data) {
    return Streak(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      currentLength: data.currentLength.present
          ? data.currentLength.value
          : this.currentLength,
      longestLength: data.longestLength.present
          ? data.longestLength.value
          : this.longestLength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Streak(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('startDate: $startDate, ')
          ..write('currentLength: $currentLength, ')
          ..write('longestLength: $longestLength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, startDate, currentLength, longestLength);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Streak &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.startDate == this.startDate &&
          other.currentLength == this.currentLength &&
          other.longestLength == this.longestLength);
}

class StreaksCompanion extends UpdateCompanion<Streak> {
  final Value<int> id;
  final Value<String> habitId;
  final Value<DateTime> startDate;
  final Value<int> currentLength;
  final Value<int> longestLength;
  const StreaksCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.currentLength = const Value.absent(),
    this.longestLength = const Value.absent(),
  });
  StreaksCompanion.insert({
    this.id = const Value.absent(),
    required String habitId,
    required DateTime startDate,
    required int currentLength,
    required int longestLength,
  })  : habitId = Value(habitId),
        startDate = Value(startDate),
        currentLength = Value(currentLength),
        longestLength = Value(longestLength);
  static Insertable<Streak> custom({
    Expression<int>? id,
    Expression<String>? habitId,
    Expression<DateTime>? startDate,
    Expression<int>? currentLength,
    Expression<int>? longestLength,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (startDate != null) 'start_date': startDate,
      if (currentLength != null) 'current_length': currentLength,
      if (longestLength != null) 'longest_length': longestLength,
    });
  }

  StreaksCompanion copyWith(
      {Value<int>? id,
      Value<String>? habitId,
      Value<DateTime>? startDate,
      Value<int>? currentLength,
      Value<int>? longestLength}) {
    return StreaksCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      startDate: startDate ?? this.startDate,
      currentLength: currentLength ?? this.currentLength,
      longestLength: longestLength ?? this.longestLength,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (currentLength.present) {
      map['current_length'] = Variable<int>(currentLength.value);
    }
    if (longestLength.present) {
      map['longest_length'] = Variable<int>(longestLength.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreaksCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('startDate: $startDate, ')
          ..write('currentLength: $currentLength, ')
          ..write('longestLength: $longestLength')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PunishmentConfigsTable extends PunishmentConfigs
    with TableInfo<$PunishmentConfigsTable, PunishmentConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PunishmentConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta =
      const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
      'habit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vibrationMeta =
      const VerificationMeta('vibration');
  @override
  late final GeneratedColumn<bool> vibration = GeneratedColumn<bool>(
      'vibration', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("vibration" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<bool> sound = GeneratedColumn<bool>(
      'sound', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("sound" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _flashMeta = const VerificationMeta('flash');
  @override
  late final GeneratedColumn<bool> flash = GeneratedColumn<bool>(
      'flash', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("flash" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _intensityMeta =
      const VerificationMeta('intensity');
  @override
  late final GeneratedColumn<double> intensity = GeneratedColumn<double>(
      'intensity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  @override
  List<GeneratedColumn> get $columns =>
      [habitId, vibration, sound, flash, intensity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'punishment_configs';
  @override
  VerificationContext validateIntegrity(Insertable<PunishmentConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta,
          habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('vibration')) {
      context.handle(_vibrationMeta,
          vibration.isAcceptableOrUnknown(data['vibration']!, _vibrationMeta));
    }
    if (data.containsKey('sound')) {
      context.handle(
          _soundMeta, sound.isAcceptableOrUnknown(data['sound']!, _soundMeta));
    }
    if (data.containsKey('flash')) {
      context.handle(
          _flashMeta, flash.isAcceptableOrUnknown(data['flash']!, _flashMeta));
    }
    if (data.containsKey('intensity')) {
      context.handle(_intensityMeta,
          intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId};
  @override
  PunishmentConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PunishmentConfig(
      habitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habit_id'])!,
      vibration: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}vibration'])!,
      sound: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sound'])!,
      flash: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}flash'])!,
      intensity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}intensity'])!,
    );
  }

  @override
  $PunishmentConfigsTable createAlias(String alias) {
    return $PunishmentConfigsTable(attachedDatabase, alias);
  }
}

class PunishmentConfig extends DataClass
    implements Insertable<PunishmentConfig> {
  final String habitId;
  final bool vibration;
  final bool sound;
  final bool flash;
  final double intensity;
  const PunishmentConfig(
      {required this.habitId,
      required this.vibration,
      required this.sound,
      required this.flash,
      required this.intensity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['vibration'] = Variable<bool>(vibration);
    map['sound'] = Variable<bool>(sound);
    map['flash'] = Variable<bool>(flash);
    map['intensity'] = Variable<double>(intensity);
    return map;
  }

  PunishmentConfigsCompanion toCompanion(bool nullToAbsent) {
    return PunishmentConfigsCompanion(
      habitId: Value(habitId),
      vibration: Value(vibration),
      sound: Value(sound),
      flash: Value(flash),
      intensity: Value(intensity),
    );
  }

  factory PunishmentConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PunishmentConfig(
      habitId: serializer.fromJson<String>(json['habitId']),
      vibration: serializer.fromJson<bool>(json['vibration']),
      sound: serializer.fromJson<bool>(json['sound']),
      flash: serializer.fromJson<bool>(json['flash']),
      intensity: serializer.fromJson<double>(json['intensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'vibration': serializer.toJson<bool>(vibration),
      'sound': serializer.toJson<bool>(sound),
      'flash': serializer.toJson<bool>(flash),
      'intensity': serializer.toJson<double>(intensity),
    };
  }

  PunishmentConfig copyWith(
          {String? habitId,
          bool? vibration,
          bool? sound,
          bool? flash,
          double? intensity}) =>
      PunishmentConfig(
        habitId: habitId ?? this.habitId,
        vibration: vibration ?? this.vibration,
        sound: sound ?? this.sound,
        flash: flash ?? this.flash,
        intensity: intensity ?? this.intensity,
      );
  PunishmentConfig copyWithCompanion(PunishmentConfigsCompanion data) {
    return PunishmentConfig(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      vibration: data.vibration.present ? data.vibration.value : this.vibration,
      sound: data.sound.present ? data.sound.value : this.sound,
      flash: data.flash.present ? data.flash.value : this.flash,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PunishmentConfig(')
          ..write('habitId: $habitId, ')
          ..write('vibration: $vibration, ')
          ..write('sound: $sound, ')
          ..write('flash: $flash, ')
          ..write('intensity: $intensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, vibration, sound, flash, intensity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PunishmentConfig &&
          other.habitId == this.habitId &&
          other.vibration == this.vibration &&
          other.sound == this.sound &&
          other.flash == this.flash &&
          other.intensity == this.intensity);
}

class PunishmentConfigsCompanion extends UpdateCompanion<PunishmentConfig> {
  final Value<String> habitId;
  final Value<bool> vibration;
  final Value<bool> sound;
  final Value<bool> flash;
  final Value<double> intensity;
  final Value<int> rowid;
  const PunishmentConfigsCompanion({
    this.habitId = const Value.absent(),
    this.vibration = const Value.absent(),
    this.sound = const Value.absent(),
    this.flash = const Value.absent(),
    this.intensity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PunishmentConfigsCompanion.insert({
    required String habitId,
    this.vibration = const Value.absent(),
    this.sound = const Value.absent(),
    this.flash = const Value.absent(),
    this.intensity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId);
  static Insertable<PunishmentConfig> custom({
    Expression<String>? habitId,
    Expression<bool>? vibration,
    Expression<bool>? sound,
    Expression<bool>? flash,
    Expression<double>? intensity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (vibration != null) 'vibration': vibration,
      if (sound != null) 'sound': sound,
      if (flash != null) 'flash': flash,
      if (intensity != null) 'intensity': intensity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PunishmentConfigsCompanion copyWith(
      {Value<String>? habitId,
      Value<bool>? vibration,
      Value<bool>? sound,
      Value<bool>? flash,
      Value<double>? intensity,
      Value<int>? rowid}) {
    return PunishmentConfigsCompanion(
      habitId: habitId ?? this.habitId,
      vibration: vibration ?? this.vibration,
      sound: sound ?? this.sound,
      flash: flash ?? this.flash,
      intensity: intensity ?? this.intensity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (vibration.present) {
      map['vibration'] = Variable<bool>(vibration.value);
    }
    if (sound.present) {
      map['sound'] = Variable<bool>(sound.value);
    }
    if (flash.present) {
      map['flash'] = Variable<bool>(flash.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<double>(intensity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PunishmentConfigsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('vibration: $vibration, ')
          ..write('sound: $sound, ')
          ..write('flash: $flash, ')
          ..write('intensity: $intensity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $DetectionEventsTable detectionEvents =
      $DetectionEventsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  late final $StreaksTable streaks = $StreaksTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PunishmentConfigsTable punishmentConfigs =
      $PunishmentConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        habits,
        detectionEvents,
        dailySummaries,
        streaks,
        appSettings,
        punishmentConfigs
      ];
}

typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required String id,
  required String name,
  required String iconPath,
  Value<bool> enabled,
  Value<double> sensitivity,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> iconPath,
  Value<bool> enabled,
  Value<double> sensitivity,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconPath => $composableBuilder(
      column: $table.iconPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconPath => $composableBuilder(
      column: $table.iconPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<double> get sensitivity => $composableBuilder(
      column: $table.sensitivity, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$HabitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HabitsTable,
    Habit,
    $$HabitsTableFilterComposer,
    $$HabitsTableOrderingComposer,
    $$HabitsTableAnnotationComposer,
    $$HabitsTableCreateCompanionBuilder,
    $$HabitsTableUpdateCompanionBuilder,
    (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
    Habit,
    PrefetchHooks Function()> {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> iconPath = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<double> sensitivity = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HabitsCompanion(
            id: id,
            name: name,
            iconPath: iconPath,
            enabled: enabled,
            sensitivity: sensitivity,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String iconPath,
            Value<bool> enabled = const Value.absent(),
            Value<double> sensitivity = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HabitsCompanion.insert(
            id: id,
            name: name,
            iconPath: iconPath,
            enabled: enabled,
            sensitivity: sensitivity,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HabitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HabitsTable,
    Habit,
    $$HabitsTableFilterComposer,
    $$HabitsTableOrderingComposer,
    $$HabitsTableAnnotationComposer,
    $$HabitsTableCreateCompanionBuilder,
    $$HabitsTableUpdateCompanionBuilder,
    (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
    Habit,
    PrefetchHooks Function()>;
typedef $$DetectionEventsTableCreateCompanionBuilder = DetectionEventsCompanion
    Function({
  Value<int> id,
  required String habitId,
  required DateTime timestamp,
  required int durationMs,
  required double confidence,
});
typedef $$DetectionEventsTableUpdateCompanionBuilder = DetectionEventsCompanion
    Function({
  Value<int> id,
  Value<String> habitId,
  Value<DateTime> timestamp,
  Value<int> durationMs,
  Value<double> confidence,
});

class $$DetectionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionEventsTable> {
  $$DetectionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));
}

class $$DetectionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionEventsTable> {
  $$DetectionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));
}

class $$DetectionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionEventsTable> {
  $$DetectionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);
}

class $$DetectionEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetectionEventsTable,
    DetectionEvent,
    $$DetectionEventsTableFilterComposer,
    $$DetectionEventsTableOrderingComposer,
    $$DetectionEventsTableAnnotationComposer,
    $$DetectionEventsTableCreateCompanionBuilder,
    $$DetectionEventsTableUpdateCompanionBuilder,
    (
      DetectionEvent,
      BaseReferences<_$AppDatabase, $DetectionEventsTable, DetectionEvent>
    ),
    DetectionEvent,
    PrefetchHooks Function()> {
  $$DetectionEventsTableTableManager(
      _$AppDatabase db, $DetectionEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> habitId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<double> confidence = const Value.absent(),
          }) =>
              DetectionEventsCompanion(
            id: id,
            habitId: habitId,
            timestamp: timestamp,
            durationMs: durationMs,
            confidence: confidence,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String habitId,
            required DateTime timestamp,
            required int durationMs,
            required double confidence,
          }) =>
              DetectionEventsCompanion.insert(
            id: id,
            habitId: habitId,
            timestamp: timestamp,
            durationMs: durationMs,
            confidence: confidence,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetectionEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetectionEventsTable,
    DetectionEvent,
    $$DetectionEventsTableFilterComposer,
    $$DetectionEventsTableOrderingComposer,
    $$DetectionEventsTableAnnotationComposer,
    $$DetectionEventsTableCreateCompanionBuilder,
    $$DetectionEventsTableUpdateCompanionBuilder,
    (
      DetectionEvent,
      BaseReferences<_$AppDatabase, $DetectionEventsTable, DetectionEvent>
    ),
    DetectionEvent,
    PrefetchHooks Function()>;
typedef $$DailySummariesTableCreateCompanionBuilder = DailySummariesCompanion
    Function({
  required String date,
  required String habitId,
  required int count,
  required int totalDurationMs,
  Value<int> rowid,
});
typedef $$DailySummariesTableUpdateCompanionBuilder = DailySummariesCompanion
    Function({
  Value<String> date,
  Value<String> habitId,
  Value<int> count,
  Value<int> totalDurationMs,
  Value<int> rowid,
});

class $$DailySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
      column: $table.totalDurationMs,
      builder: (column) => ColumnFilters(column));
}

class $$DailySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
      column: $table.totalDurationMs,
      builder: (column) => ColumnOrderings(column));
}

class $$DailySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
      column: $table.totalDurationMs, builder: (column) => column);
}

class $$DailySummariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailySummariesTable,
    DailySummary,
    $$DailySummariesTableFilterComposer,
    $$DailySummariesTableOrderingComposer,
    $$DailySummariesTableAnnotationComposer,
    $$DailySummariesTableCreateCompanionBuilder,
    $$DailySummariesTableUpdateCompanionBuilder,
    (
      DailySummary,
      BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>
    ),
    DailySummary,
    PrefetchHooks Function()> {
  $$DailySummariesTableTableManager(
      _$AppDatabase db, $DailySummariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> date = const Value.absent(),
            Value<String> habitId = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<int> totalDurationMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailySummariesCompanion(
            date: date,
            habitId: habitId,
            count: count,
            totalDurationMs: totalDurationMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String date,
            required String habitId,
            required int count,
            required int totalDurationMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailySummariesCompanion.insert(
            date: date,
            habitId: habitId,
            count: count,
            totalDurationMs: totalDurationMs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailySummariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailySummariesTable,
    DailySummary,
    $$DailySummariesTableFilterComposer,
    $$DailySummariesTableOrderingComposer,
    $$DailySummariesTableAnnotationComposer,
    $$DailySummariesTableCreateCompanionBuilder,
    $$DailySummariesTableUpdateCompanionBuilder,
    (
      DailySummary,
      BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>
    ),
    DailySummary,
    PrefetchHooks Function()>;
typedef $$StreaksTableCreateCompanionBuilder = StreaksCompanion Function({
  Value<int> id,
  required String habitId,
  required DateTime startDate,
  required int currentLength,
  required int longestLength,
});
typedef $$StreaksTableUpdateCompanionBuilder = StreaksCompanion Function({
  Value<int> id,
  Value<String> habitId,
  Value<DateTime> startDate,
  Value<int> currentLength,
  Value<int> longestLength,
});

class $$StreaksTableFilterComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentLength => $composableBuilder(
      column: $table.currentLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longestLength => $composableBuilder(
      column: $table.longestLength, builder: (column) => ColumnFilters(column));
}

class $$StreaksTableOrderingComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentLength => $composableBuilder(
      column: $table.currentLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longestLength => $composableBuilder(
      column: $table.longestLength,
      builder: (column) => ColumnOrderings(column));
}

class $$StreaksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get currentLength => $composableBuilder(
      column: $table.currentLength, builder: (column) => column);

  GeneratedColumn<int> get longestLength => $composableBuilder(
      column: $table.longestLength, builder: (column) => column);
}

class $$StreaksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StreaksTable,
    Streak,
    $$StreaksTableFilterComposer,
    $$StreaksTableOrderingComposer,
    $$StreaksTableAnnotationComposer,
    $$StreaksTableCreateCompanionBuilder,
    $$StreaksTableUpdateCompanionBuilder,
    (Streak, BaseReferences<_$AppDatabase, $StreaksTable, Streak>),
    Streak,
    PrefetchHooks Function()> {
  $$StreaksTableTableManager(_$AppDatabase db, $StreaksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> habitId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<int> currentLength = const Value.absent(),
            Value<int> longestLength = const Value.absent(),
          }) =>
              StreaksCompanion(
            id: id,
            habitId: habitId,
            startDate: startDate,
            currentLength: currentLength,
            longestLength: longestLength,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String habitId,
            required DateTime startDate,
            required int currentLength,
            required int longestLength,
          }) =>
              StreaksCompanion.insert(
            id: id,
            habitId: habitId,
            startDate: startDate,
            currentLength: currentLength,
            longestLength: longestLength,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StreaksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StreaksTable,
    Streak,
    $$StreaksTableFilterComposer,
    $$StreaksTableOrderingComposer,
    $$StreaksTableAnnotationComposer,
    $$StreaksTableCreateCompanionBuilder,
    $$StreaksTableUpdateCompanionBuilder,
    (Streak, BaseReferences<_$AppDatabase, $StreaksTable, Streak>),
    Streak,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$PunishmentConfigsTableCreateCompanionBuilder
    = PunishmentConfigsCompanion Function({
  required String habitId,
  Value<bool> vibration,
  Value<bool> sound,
  Value<bool> flash,
  Value<double> intensity,
  Value<int> rowid,
});
typedef $$PunishmentConfigsTableUpdateCompanionBuilder
    = PunishmentConfigsCompanion Function({
  Value<String> habitId,
  Value<bool> vibration,
  Value<bool> sound,
  Value<bool> flash,
  Value<double> intensity,
  Value<int> rowid,
});

class $$PunishmentConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $PunishmentConfigsTable> {
  $$PunishmentConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get vibration => $composableBuilder(
      column: $table.vibration, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sound => $composableBuilder(
      column: $table.sound, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get flash => $composableBuilder(
      column: $table.flash, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnFilters(column));
}

class $$PunishmentConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $PunishmentConfigsTable> {
  $$PunishmentConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
      column: $table.habitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get vibration => $composableBuilder(
      column: $table.vibration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sound => $composableBuilder(
      column: $table.sound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get flash => $composableBuilder(
      column: $table.flash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnOrderings(column));
}

class $$PunishmentConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PunishmentConfigsTable> {
  $$PunishmentConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<bool> get vibration =>
      $composableBuilder(column: $table.vibration, builder: (column) => column);

  GeneratedColumn<bool> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<bool> get flash =>
      $composableBuilder(column: $table.flash, builder: (column) => column);

  GeneratedColumn<double> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);
}

class $$PunishmentConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PunishmentConfigsTable,
    PunishmentConfig,
    $$PunishmentConfigsTableFilterComposer,
    $$PunishmentConfigsTableOrderingComposer,
    $$PunishmentConfigsTableAnnotationComposer,
    $$PunishmentConfigsTableCreateCompanionBuilder,
    $$PunishmentConfigsTableUpdateCompanionBuilder,
    (
      PunishmentConfig,
      BaseReferences<_$AppDatabase, $PunishmentConfigsTable, PunishmentConfig>
    ),
    PunishmentConfig,
    PrefetchHooks Function()> {
  $$PunishmentConfigsTableTableManager(
      _$AppDatabase db, $PunishmentConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PunishmentConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PunishmentConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PunishmentConfigsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> habitId = const Value.absent(),
            Value<bool> vibration = const Value.absent(),
            Value<bool> sound = const Value.absent(),
            Value<bool> flash = const Value.absent(),
            Value<double> intensity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PunishmentConfigsCompanion(
            habitId: habitId,
            vibration: vibration,
            sound: sound,
            flash: flash,
            intensity: intensity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String habitId,
            Value<bool> vibration = const Value.absent(),
            Value<bool> sound = const Value.absent(),
            Value<bool> flash = const Value.absent(),
            Value<double> intensity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PunishmentConfigsCompanion.insert(
            habitId: habitId,
            vibration: vibration,
            sound: sound,
            flash: flash,
            intensity: intensity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PunishmentConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PunishmentConfigsTable,
    PunishmentConfig,
    $$PunishmentConfigsTableFilterComposer,
    $$PunishmentConfigsTableOrderingComposer,
    $$PunishmentConfigsTableAnnotationComposer,
    $$PunishmentConfigsTableCreateCompanionBuilder,
    $$PunishmentConfigsTableUpdateCompanionBuilder,
    (
      PunishmentConfig,
      BaseReferences<_$AppDatabase, $PunishmentConfigsTable, PunishmentConfig>
    ),
    PunishmentConfig,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$DetectionEventsTableTableManager get detectionEvents =>
      $$DetectionEventsTableTableManager(_db, _db.detectionEvents);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
  $$StreaksTableTableManager get streaks =>
      $$StreaksTableTableManager(_db, _db.streaks);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PunishmentConfigsTableTableManager get punishmentConfigs =>
      $$PunishmentConfigsTableTableManager(_db, _db.punishmentConfigs);
}

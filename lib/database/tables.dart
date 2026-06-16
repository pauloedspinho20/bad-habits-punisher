import 'package:drift/drift.dart';

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconPath => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  RealColumn get sensitivity =>
      real().withDefault(const Constant(0.6))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class DetectionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get durationMs => integer()();
  RealColumn get confidence => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailySummaries extends Table {
  TextColumn get date => text()();
  TextColumn get habitId => text()();
  IntColumn get count => integer()();
  IntColumn get totalDurationMs => integer()();

  @override
  Set<Column> get primaryKey => {date, habitId};
}

class Streaks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId => text()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get currentLength => integer()();
  IntColumn get longestLength => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

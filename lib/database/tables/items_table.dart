import 'package:drift/drift.dart';
import 'workspaces_table.dart';
import 'workspace_sections_table.dart';

/// Unified Items Table (Alarms & Reminders [Generic / Task / Event])
/// AURA v2 Canonical Data Model
@DataClassName('Item')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().nullable().references(Workspaces, #id)();
  TextColumn get sectionId => text().nullable().references(WorkspaceSections, #id)();

  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get parentId => text().nullable()(); // Self-reference for subtasks

  // Category Hierarchy: 'alarm' | 'reminder'
  TextColumn get category => text()();
  // Kind Hierarchy: 'generic' | 'task' | 'event'
  TextColumn get kind => text()();

  // Timing & Schedules (Epoch ms)
  IntColumn get fireAt => integer().nullable()();      // For alarms / reminders
  IntColumn get deadline => integer().nullable()();    // For tasks
  IntColumn get startTime => integer().nullable()();   // For events
  IntColumn get endTime => integer().nullable()();     // For events
  TextColumn get location => text().nullable()();      // For events

  // Properties & Status
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // 'high' | 'medium' | 'low'
  TextColumn get status => text().withDefault(const Constant('pending'))();  // 'pending' | 'completed' | 'cancelled'
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()(); // 'daily', 'weekly', etc.

  // Alarm sound — URI of the selected ringtone (null = system default)
  TextColumn get soundUri => text().nullable()();

  // Metadata & AI Context
  TextColumn get orbSourceApp => text().nullable()();
  TextColumn get aiTranscript => text().nullable()();
  RealColumn get confidence => real().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

import '../../../../database/app_database.dart';

/// Aggregated stats and preview for a Workspace Card on the Workspace List screen.
class WorkspaceWithStats {
  final Workspace workspace;
  final int activeTaskCount;
  final int eventCount;
  final int overdueCount;
  final String? previewText;

  const WorkspaceWithStats({
    required this.workspace,
    required this.activeTaskCount,
    required this.eventCount,
    required this.overdueCount,
    this.previewText,
  });
}

/// Summary stats for the Workspace Detail Bento Header Row (80dp height).
class WorkspaceStats {
  final int activeTasks;
  final int overdueTasks;
  final int totalEvents;
  final int totalSections;

  const WorkspaceStats({
    required this.activeTasks,
    required this.overdueTasks,
    required this.totalEvents,
    required this.totalSections,
  });
}

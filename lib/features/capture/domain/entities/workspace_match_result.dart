import '../../../../database/app_database.dart';

enum WorkspaceMatchType { exact, keyword, fuzzy, newWorkspace, none }

/// Result of local workspace routing algorithm (Agent 2).
class WorkspaceMatchResult {
  final WorkspaceMatchType type;
  final Workspace? matchedWorkspace;
  final String? suggestedWorkspaceName;
  final double matchScore; // 0.0 – 1.0

  const WorkspaceMatchResult({
    required this.type,
    this.matchedWorkspace,
    this.suggestedWorkspaceName,
    required this.matchScore,
  });

  factory WorkspaceMatchResult.exact(Workspace workspace) {
    return WorkspaceMatchResult(
      type: WorkspaceMatchType.exact,
      matchedWorkspace: workspace,
      matchScore: 1.0,
    );
  }

  factory WorkspaceMatchResult.keyword(Workspace workspace, double score) {
    return WorkspaceMatchResult(
      type: WorkspaceMatchType.keyword,
      matchedWorkspace: workspace,
      matchScore: score,
    );
  }

  factory WorkspaceMatchResult.fuzzy(Workspace workspace, double score) {
    return WorkspaceMatchResult(
      type: WorkspaceMatchType.fuzzy,
      matchedWorkspace: workspace,
      matchScore: score,
    );
  }

  factory WorkspaceMatchResult.newWorkspace(String name) {
    return WorkspaceMatchResult(
      type: WorkspaceMatchType.newWorkspace,
      suggestedWorkspaceName: name,
      matchScore: 0.7,
    );
  }

  factory WorkspaceMatchResult.none() {
    return const WorkspaceMatchResult(
      type: WorkspaceMatchType.none,
      matchScore: 0.0,
    );
  }
}

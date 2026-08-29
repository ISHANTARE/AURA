import '../../../database/app_database.dart';

/// Result of matching a workspace hint against the user's workspaces.
class WorkspaceMatchResult {
  final Workspace? workspace;
  final String? suggestedNewWorkspaceName;
  final double matchConfidence;
  final bool isNewWorkspaceSuggestion;

  const WorkspaceMatchResult.matched(this.workspace, this.matchConfidence)
      : suggestedNewWorkspaceName = null,
        isNewWorkspaceSuggestion = false;

  const WorkspaceMatchResult.newWorkspace(this.suggestedNewWorkspaceName)
      : workspace = null,
        matchConfidence = 0.5,
        isNewWorkspaceSuggestion = true;

  const WorkspaceMatchResult.none()
      : workspace = null,
        suggestedNewWorkspaceName = null,
        matchConfidence = 0.0,
        isNewWorkspaceSuggestion = false;
}

/// 4-tier workspace taxonomy engine routing hints to user workspaces.
class WorkspaceRouterUseCase {
  static const _stopWords = {'the', 'and', 'for', 'my', 'of', 'in', 'to', 'a', 'an'};

  static const Map<String, List<String>> _taxonomy = {
    'work': ['work', 'office', 'standup', 'sprint', 'deploy', 'client', 'meeting', 'project', 'deadline', 'report', 'code', 'dev'],
    'personal': ['personal', 'home', 'family', 'hobby', 'errand', 'shopping', 'groceries'],
    'health': ['gym', 'exercise', 'medicine', 'doctor', 'workout', 'fitness', 'run', 'health'],
    'finance': ['finance', 'budget', 'bank', 'tax', 'invoice', 'payment', 'rent', 'money'],
    'learning': ['study', 'learn', 'course', 'exam', 'assignment', 'class', 'school', 'college', 'university', 'reading', 'iit', 'vit', 'academic'],
  };

  /// Routes a [workspaceHint] or transcript keywords against the user's [workspaces].
  static WorkspaceMatchResult route({
    required String? workspaceHint,
    required List<Workspace> workspaces,
    String? transcript,
  }) {
    if (workspaces.isEmpty) {
      if (workspaceHint != null && workspaceHint.trim().isNotEmpty) {
        return WorkspaceMatchResult.newWorkspace(workspaceHint.trim());
      }
      return const WorkspaceMatchResult.none();
    }

    final hint = workspaceHint?.trim().toLowerCase();

    // ── Tier 1: Exact Name Match (Case-Insensitive) ──────────────────────────
    if (hint != null && hint.isNotEmpty) {
      for (final ws in workspaces) {
        if (ws.name.toLowerCase() == hint) {
          return WorkspaceMatchResult.matched(ws, 1.0);
        }
      }

      // ── Tier 2: Fuzzy Containment & Significant Token Overlap ──────────────
      for (final ws in workspaces) {
        final wsNameLower = ws.name.toLowerCase();
        if (wsNameLower.contains(hint) || hint.contains(wsNameLower)) {
          return WorkspaceMatchResult.matched(ws, 0.85);
        }

        final wsTokens = wsNameLower.split(RegExp(r'\s+')).where((t) => !_stopWords.contains(t)).toSet();
        final hintTokens = hint.split(RegExp(r'\s+')).where((t) => !_stopWords.contains(t)).toSet();
        if (wsTokens.intersection(hintTokens).isNotEmpty) {
          return WorkspaceMatchResult.matched(ws, 0.75);
        }
      }
    }

    // ── Tier 3: Generic Taxonomy Fallback ────────────────────────────────────
    final searchText = '${hint ?? ''} ${transcript ?? ''}'.toLowerCase();
    final searchTokens = searchText
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((t) => t.isNotEmpty && !_stopWords.contains(t))
        .toSet();

    for (final entry in _taxonomy.entries) {
      final category = entry.key;
      final keywords = entry.value;

      final matchesCategory = keywords.any((kw) => searchTokens.contains(kw));
      if (matchesCategory) {
        // Find if user has a workspace whose name aligns with this taxonomy category
        for (final ws in workspaces) {
          final wsTokens = ws.name
              .toLowerCase()
              .split(RegExp(r'[^a-zA-Z0-9]+'))
              .where((t) => t.isNotEmpty)
              .toSet();
          if (wsTokens.contains(category) || keywords.any((kw) => wsTokens.contains(kw))) {
            return WorkspaceMatchResult.matched(ws, 0.70);
          }
        }
      }
    }

    // ── Tier 4: Suggest New Workspace or None ────────────────────────────────
    if (hint != null && hint.isNotEmpty) {
      return WorkspaceMatchResult.newWorkspace(workspaceHint!.trim());
    }

    return const WorkspaceMatchResult.none();
  }
}

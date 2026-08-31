import '../../../../database/app_database.dart';
import '../../../workspaces/domain/workspace_taxonomy.dart';
import '../entities/workspace_match_result.dart';

/// Routes an AI workspace_hint to the user's ACTUAL workspaces.
///
/// Priority:
///   1. Exact name match against the user's workspaces.
///   2. Fuzzy containment match between hint and workspace names.
///   3. Generic-taxonomy keyword fallback (no developer-specific terms).
///   4. Suggest creating a new workspace named after the hint.
/// The confirmation card always lets the user override the choice.
class WorkspaceRouterUseCase {
  static final _keywordIndex = WorkspaceTaxonomy.keywordIndex;

  WorkspaceMatchResult routeWorkspace({
    required String? workspaceHint,
    required List<Workspace> existingWorkspaces,
  }) {
    if (existingWorkspaces.isEmpty) {
      final suggestion = (workspaceHint == null || workspaceHint.trim().isEmpty)
          ? null
          : workspaceHint.trim();
      return suggestion == null
          ? WorkspaceMatchResult.none()
          : WorkspaceMatchResult.newWorkspace(suggestion);
    }

    if (workspaceHint == null || workspaceHint.trim().isEmpty) {
      return WorkspaceMatchResult.none();
    }

    final hintLower = workspaceHint.trim().toLowerCase();

    // Step 1: Exact name match.
    for (final w in existingWorkspaces) {
      if (w.name.toLowerCase() == hintLower) {
        return WorkspaceMatchResult.exact(w);
      }
    }

    // Step 2: Fuzzy containment between hint and real workspace names.
    Workspace? bestFuzzy;
    var bestScore = 0.0;
    for (final w in existingWorkspaces) {
      final nameLower = w.name.toLowerCase();
      double score = 0.0;
      if (nameLower.contains(hintLower) || hintLower.contains(nameLower)) {
        score = nameLower.length >= hintLower.length ? 0.9 : 0.8;
      } else if (_sharesSignificantToken(hintLower, nameLower)) {
        score = 0.75;
      }
      if (score > bestScore) {
        bestScore = score;
        bestFuzzy = w;
      }
    }
    if (bestFuzzy != null) {
      return WorkspaceMatchResult.fuzzy(bestFuzzy, bestScore);
    }

    // Step 3: Generic taxonomy fallback — a workspace whose NAME is a
    // taxonomy category ('work', 'health', …) absorbs matching hints.
    final hintCategory = _categoryForText(hintLower);
    if (hintCategory != null) {
      for (final w in existingWorkspaces) {
        if (_categoryForText(w.name.toLowerCase()) == hintCategory ||
            w.name.toLowerCase() == hintCategory) {
          return WorkspaceMatchResult.keyword(w, 0.7);
        }
      }
    }

    // Step 4: Suggest creating a new workspace.
    return WorkspaceMatchResult.newWorkspace(workspaceHint.trim());
  }

  bool _sharesSignificantToken(String a, String b) {
    const stop = {'the', 'and', 'for', 'my', 'of'};
    final at =
        a.split(RegExp(r'[\s_\-]+')).where((t) => t.length >= 3 && !stop.contains(t));
    final bt = b.split(RegExp(r'[\s_\-]+')).toSet();
    return at.any(bt.contains);
  }

  String? _categoryForText(String text) {
    for (final entry in _keywordIndex.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return null;
  }
}

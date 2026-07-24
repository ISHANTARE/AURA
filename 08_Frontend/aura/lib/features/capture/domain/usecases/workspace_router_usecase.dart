import '../../../../database/app_database.dart';
import '../entities/workspace_match_result.dart';

class WorkspaceRouterUseCase {
  WorkspaceMatchResult routeWorkspace({
    required String? workspaceHint,
    required List<Workspace> existingWorkspaces,
  }) {
    if (workspaceHint == null || workspaceHint.trim().isEmpty) {
      return WorkspaceMatchResult.none();
    }

    final hintLower = workspaceHint.trim().toLowerCase();

    // Step 1: Exact match
    for (final w in existingWorkspaces) {
      if (w.name.toLowerCase() == hintLower) {
        return WorkspaceMatchResult.exact(w);
      }
    }

    // Step 2: Keyword mapping table
    final keywordMap = <String, List<String>>{
      'vit': ['vit', 'college', 'vtop', 'professor', 'assignment', 'lab', 'exam', 'submission', 'academics'],
      'gate': ['gate', 'iit', 'pyq', 'aptitude', 'algo', 'algorithm', 'mock test'],
      'internship': ['internship', 'standup', 'sprint', 'pr', 'deploy', 'client', 'work'],
      'placement': ['placement', 'interview', 'resume', 'oa', 'coding round', 'offer'],
      'personal': ['personal', 'home', 'family', 'hobby'],
      'health': ['gym', 'exercise', 'medicine', 'doctor', 'workout', 'fitness'],
    };

    Workspace? bestMatch;
    double bestScore = 0.0;

    for (final w in existingWorkspaces) {
      final keywords = keywordMap[w.name.toLowerCase()] ?? [w.name.toLowerCase()];
      if (keywords.any((k) => hintLower.contains(k) || k.contains(hintLower))) {
        const score = 0.85;
        if (score > bestScore) {
          bestScore = score;
          bestMatch = w;
        }
      }
    }

    if (bestMatch != null) {
      return WorkspaceMatchResult.keyword(bestMatch, bestScore);
    }

    // Step 3: Default to suggesting new workspace creation
    return WorkspaceMatchResult.newWorkspace(workspaceHint.trim());
  }
}

/// Generic category taxonomy used ONLY as a fallback when the AI's
/// workspace_hint matches none of the user's real workspace names.
///
/// Deliberately contains no developer-specific or institution-specific terms.
abstract final class WorkspaceTaxonomy {
  /// Category → trigger keywords (lowercase).
  static const Map<String, List<String>> categories = {
    'work': [
      'work', 'office', 'standup', 'sprint', 'deploy', 'client',
      'meeting', 'project', 'deadline', 'report',
    ],
    'personal': ['personal', 'home', 'family', 'hobby', 'errand', 'shopping'],
    'health': ['gym', 'exercise', 'medicine', 'doctor', 'workout', 'fitness', 'run'],
    'finance': ['finance', 'budget', 'bank', 'tax', 'invoice', 'payment', 'rent'],
    'learning': [
      'study', 'learn', 'course', 'exam', 'assignment', 'class',
      'school', 'college', 'university', 'reading',
    ],
  };

  /// All keywords flattened, mapped back to their category.
  static Map<String, String> get keywordIndex {
    final index = <String, String>{};
    categories.forEach((category, keywords) {
      for (final k in keywords) {
        index[k] = category;
      }
    });
    return index;
  }
}

/// Time-aware, name-aware greeting used by the home screen and briefing.
///
/// Falls back to "there" for blank names so no placeholder or developer name
/// can ever leak into the UI.
String timeAwareGreeting(int hour, {required String userName}) {
  final trimmed = userName.trim();
  final firstName = trimmed.isEmpty ? 'there' : trimmed.split(' ').first;
  if (hour < 12) return 'Good morning, $firstName.';
  if (hour < 17) return 'Good afternoon, $firstName.';
  return 'Good evening, $firstName.';
}

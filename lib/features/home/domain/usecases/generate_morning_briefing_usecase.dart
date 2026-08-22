import '../../../../database/app_database.dart';

class MorningBriefingData {
  final String greeting;
  final String dateFormatted;
  final String summaryLine;
  final List<Item> urgentItems;
  final List<Item> focusItems;
  final List<Item> upcomingItems;

  MorningBriefingData({
    required this.greeting,
    required this.dateFormatted,
    required this.summaryLine,
    required this.urgentItems,
    required this.focusItems,
    required this.upcomingItems,
  });
}

class GenerateMorningBriefingUseCase {
  final ItemDao _itemDao;

  GenerateMorningBriefingUseCase({required ItemDao itemDao}) : _itemDao = itemDao;

  Future<MorningBriefingData> execute() async {
    final now = DateTime.now();
    final hour = now.hour;
    final String greeting = hour < 12
        ? 'Good morning, Ishant.'
        : (hour < 17 ? 'Good afternoon, Ishant.' : 'Good evening, Ishant.');

    final dateFormatted =
        '${_weekdayName(now.weekday)}, ${_monthName(now.month)} ${now.day}';

    final allActive = await _itemDao.watchAllActive().first;
    final limit48h = now.add(const Duration(hours: 48)).millisecondsSinceEpoch;
    final limit7d = now.add(const Duration(days: 7)).millisecondsSinceEpoch;

    final urgentItems = allActive.where((t) {
      if (t.status == 'completed' || t.deadline == null) return false;
      return t.deadline! <= limit48h;
    }).toList();

    final focusItems = allActive.where((t) {
      return t.status != 'completed' &&
          (t.priority == 'high' || t.priority == 'medium');
    }).take(3).toList();

    final upcomingItems = allActive.where((t) {
      if (t.status == 'completed' || t.deadline == null) return false;
      return t.deadline! > limit48h && t.deadline! <= limit7d;
    }).toList();

    final summaryLine = urgentItems.isNotEmpty
        ? '${urgentItems.length} items need your attention today.'
        : 'Clear day ahead. Great time to build momentum.';

    return MorningBriefingData(
      greeting: greeting,
      dateFormatted: dateFormatted,
      summaryLine: summaryLine,
      urgentItems: urgentItems,
      focusItems: focusItems,
      upcomingItems: upcomingItems,
    );
  }

  String _weekdayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

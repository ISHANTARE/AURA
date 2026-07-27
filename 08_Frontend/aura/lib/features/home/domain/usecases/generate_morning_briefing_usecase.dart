import '../../../../database/app_database.dart';
import '../../../../database/daos/event_dao.dart';
import '../../../../database/daos/notification_dao.dart';
import '../../../../database/daos/reminder_dao.dart';
import '../../../../database/daos/task_dao.dart';

class MorningBriefingData {
  final String greeting;
  final String dateFormatted;
  final String summaryLine;
  final List<Task> urgentTasks;
  final List<Task> focusTasks;
  final List<Task> upcomingTasks;
  final List<Task> habits;
  final List<Reminder> missedDndReminders;

  MorningBriefingData({
    required this.greeting,
    required this.dateFormatted,
    required this.summaryLine,
    required this.urgentTasks,
    required this.focusTasks,
    required this.upcomingTasks,
    required this.habits,
    required this.missedDndReminders,
  });
}

class GenerateMorningBriefingUseCase {
  final TaskDao _taskDao;
  final ReminderDao _reminderDao;

  GenerateMorningBriefingUseCase({
    required TaskDao taskDao,
    required EventDao eventDao,
    required ReminderDao reminderDao,
    required NotificationDao notificationDao,
  })  : _taskDao = taskDao,
        _reminderDao = reminderDao;

  Future<MorningBriefingData> execute() async {
    final now = DateTime.now();
    final hour = now.hour;
    final String greeting = hour < 12
        ? 'Good morning, Ishant.'
        : (hour < 17 ? 'Good afternoon, Ishant.' : 'Good evening, Ishant.');

    final dateFormatted = '${_weekdayName(now.weekday)}, ${_monthName(now.month)} ${now.day}';

    // 1. Urgent tasks (due within 48h)
    final allActive = await _taskDao.getAll();
    final limit48h = now.add(const Duration(hours: 48)).millisecondsSinceEpoch;

    final urgentTasks = allActive.where((t) {
      if (t.status == 'done' || t.deadline == null) return false;
      return t.deadline! <= limit48h;
    }).toList();

    // 2. Focus tasks (top priority/urgent)
    final focusTasks = allActive.where((t) {
      return t.status != 'done' && (t.priority == 'high' || t.priority == 'medium');
    }).take(3).toList();

    // 3. Upcoming tasks (next 7 days)
    final limit7d = now.add(const Duration(days: 7)).millisecondsSinceEpoch;
    final upcomingTasks = allActive.where((t) {
      if (t.status == 'done' || t.deadline == null) return false;
      return t.deadline! > limit48h && t.deadline! <= limit7d;
    }).toList();

    // 4. Habits (recurring)
    final habits = allActive.where((t) => t.isRecurring).toList();

    // 5. Missed DND reminders
    final dndReminders = await _reminderDao.getDndMissedUnreplayed();

    // 6. Summary line generator
    final dueTodayCount = urgentTasks.length;
    final summaryLine = dueTodayCount > 0
        ? '$dueTodayCount tasks need your attention today. Let\'s get after it.'
        : 'Clear day ahead. Great time to build momentum.';

    return MorningBriefingData(
      greeting: greeting,
      dateFormatted: dateFormatted,
      summaryLine: summaryLine,
      urgentTasks: urgentTasks,
      focusTasks: focusTasks,
      upcomingTasks: upcomingTasks,
      habits: habits,
      missedDndReminders: dndReminders,
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

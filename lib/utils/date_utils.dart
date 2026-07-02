String formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String todayKey() => formatDate(DateTime.now());

String nowTime() => formatTime(DateTime.now());

/// Returns the YYYY-MM-DD key for the Monday of the current week.
String startOfWeekKey() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return formatDate(monday);
}

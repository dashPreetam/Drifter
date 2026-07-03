/// The daily cycle rolls over at 4 AM instead of midnight, so a late-night
/// session before you go to sleep still lands on the day you meant.
const _dayCycleOffset = Duration(hours: 4);

String formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

/// The "effective" moment for day-bucketing purposes — real clock time
/// shifted back by the day-cycle offset.
DateTime _effectiveNow() => DateTime.now().subtract(_dayCycleOffset);

String todayKey() => formatDate(_effectiveNow());

String nowTime() => formatTime(DateTime.now());

/// Returns the YYYY-MM-DD key for the Monday of the current (offset) week.
String startOfWeekKey() {
  final effectiveNow = _effectiveNow();
  final monday = effectiveNow.subtract(Duration(days: effectiveNow.weekday - 1));
  return formatDate(monday);
}

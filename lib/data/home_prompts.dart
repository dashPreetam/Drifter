const List<String> homePrompts = [
  'What version of you needs you the most today?',
  'Where are you most likely to drift today?',
  'What is Future You quietly hoping you\'ll remember today?',
  'Who shows up today?',
  'What deserves your attention today?',
  'Where will today\'s effort compound the most?',
  'What evidence do you want today to leave behind?',
  'Which part of your operating system needs care today?',
  'What would make today feel aligned?',
  'What small action would reduce tomorrow\'s friction?',
  'Where are you choosing to invest yourself today?',
  'If today goes well, what probably happened?',
  'What are you choosing not to forget today?',
  'What will Future You thank you for protecting today?',
];

int _dayOfYear(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  return date.difference(startOfYear).inDays + 1;
}

/// Rotates deterministically by calendar day — stable within a day,
/// different the next.
String todaysPrompt() {
  final index = _dayOfYear(DateTime.now()) % homePrompts.length;
  return homePrompts[index];
}

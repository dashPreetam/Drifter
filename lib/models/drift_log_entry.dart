class DriftLogEntry {
  final int? id;
  final String date; // YYYY-MM-DD
  final String timestamp; // HH:mm
  final String text;

  const DriftLogEntry({
    this.id,
    required this.date,
    required this.timestamp,
    required this.text,
  });

  factory DriftLogEntry.fromMap(Map<String, Object?> map) {
    return DriftLogEntry(
      id: map['id'] as int?,
      date: map['date'] as String,
      timestamp: map['timestamp'] as String,
      text: map['text'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'timestamp': timestamp,
      'text': text,
    };
  }
}

import 'identity.dart';

class DailyEntry {
  final String date; // YYYY-MM-DD
  final Identity? identity;
  final int? googleDeepWorkMinutes;
  final String? googleWin;
  final bool? fitnessWorkout;
  final bool? fitnessWalk;
  final double? fitnessWeight;
  final int? fitnessEnergy;
  final String? sleepTime;
  final String? wakeTime;
  final int? sleepQuality;
  final bool? musicOpenedDaw;
  final int? musicMinutes;

  const DailyEntry({
    required this.date,
    this.identity,
    this.googleDeepWorkMinutes,
    this.googleWin,
    this.fitnessWorkout,
    this.fitnessWalk,
    this.fitnessWeight,
    this.fitnessEnergy,
    this.sleepTime,
    this.wakeTime,
    this.sleepQuality,
    this.musicOpenedDaw,
    this.musicMinutes,
  });

  factory DailyEntry.empty(String date) => DailyEntry(date: date);

  factory DailyEntry.fromMap(Map<String, Object?> map) {
    return DailyEntry(
      date: map['date'] as String,
      identity: Identity.fromName(map['identity'] as String?),
      googleDeepWorkMinutes: map['google_deep_work_minutes'] as int?,
      googleWin: map['google_win'] as String?,
      fitnessWorkout: _boolFromInt(map['fitness_workout'] as int?),
      fitnessWalk: _boolFromInt(map['fitness_walk'] as int?),
      fitnessWeight: (map['fitness_weight'] as num?)?.toDouble(),
      fitnessEnergy: map['fitness_energy'] as int?,
      sleepTime: map['sleep_time'] as String?,
      wakeTime: map['wake_time'] as String?,
      sleepQuality: map['sleep_quality'] as int?,
      musicOpenedDaw: _boolFromInt(map['music_opened_daw'] as int?),
      musicMinutes: map['music_minutes'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'date': date,
      'identity': identity?.name,
      'google_deep_work_minutes': googleDeepWorkMinutes,
      'google_win': googleWin,
      'fitness_workout': _intFromBool(fitnessWorkout),
      'fitness_walk': _intFromBool(fitnessWalk),
      'fitness_weight': fitnessWeight,
      'fitness_energy': fitnessEnergy,
      'sleep_time': sleepTime,
      'wake_time': wakeTime,
      'sleep_quality': sleepQuality,
      'music_opened_daw': _intFromBool(musicOpenedDaw),
      'music_minutes': musicMinutes,
    };
  }

  bool get hasGoogle => googleDeepWorkMinutes != null || googleWin != null;
  bool get hasFitness =>
      fitnessWorkout != null ||
      fitnessWalk != null ||
      fitnessWeight != null ||
      fitnessEnergy != null;
  bool get hasSleep =>
      sleepTime != null || wakeTime != null || sleepQuality != null;
  bool get hasMusic => musicOpenedDaw != null || musicMinutes != null;

  DailyEntry copyWith({
    Identity? identity,
    int? googleDeepWorkMinutes,
    String? googleWin,
    bool? fitnessWorkout,
    bool? fitnessWalk,
    double? fitnessWeight,
    int? fitnessEnergy,
    String? sleepTime,
    String? wakeTime,
    int? sleepQuality,
    bool? musicOpenedDaw,
    int? musicMinutes,
  }) {
    return DailyEntry(
      date: date,
      identity: identity ?? this.identity,
      googleDeepWorkMinutes:
          googleDeepWorkMinutes ?? this.googleDeepWorkMinutes,
      googleWin: googleWin ?? this.googleWin,
      fitnessWorkout: fitnessWorkout ?? this.fitnessWorkout,
      fitnessWalk: fitnessWalk ?? this.fitnessWalk,
      fitnessWeight: fitnessWeight ?? this.fitnessWeight,
      fitnessEnergy: fitnessEnergy ?? this.fitnessEnergy,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      musicOpenedDaw: musicOpenedDaw ?? this.musicOpenedDaw,
      musicMinutes: musicMinutes ?? this.musicMinutes,
    );
  }

  static bool? _boolFromInt(int? value) => value == null ? null : value == 1;

  static int? _intFromBool(bool? value) =>
      value == null ? null : (value ? 1 : 0);
}

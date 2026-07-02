import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database_helper.dart';
import '../models/daily_entry.dart';
import '../models/drift_log_entry.dart';
import '../utils/date_utils.dart';

class ExportService {
  Future<void> exportToday() async {
    final today = todayKey();
    final entry = await DatabaseHelper.instance.getEntryForDate(today);
    final log = await DatabaseHelper.instance.getDriftLogForDate(today);
    final markdown = '# Drifter — $today\n\n${_dayMarkdown(entry, log)}';
    await _writeAndShare('drifter-$today.md', markdown);
  }

  Future<void> exportWeek() async {
    final start = startOfWeekKey();
    final end = formatDate(
      DateTime.parse(start).add(const Duration(days: 6)),
    );
    final entries = await DatabaseHelper.instance.getEntriesForRange(
      start,
      end,
    );
    final log = await DatabaseHelper.instance.getDriftLogForRange(
      start,
      end,
    );

    final buffer = StringBuffer('# Drifter — Week of $start\n\n');
    for (var i = 0; i < 7; i++) {
      final date = formatDate(DateTime.parse(start).add(Duration(days: i)));
      final entry = entries.firstWhere(
        (e) => e.date == date,
        orElse: () => DailyEntry.empty(date),
      );
      final dayLog = log.where((e) => e.date == date).toList();
      if (!_hasAnyData(entry, dayLog)) continue;
      buffer.writeln(_dayMarkdown(entry, dayLog));
    }
    await _writeAndShare('drifter-week-$start.md', buffer.toString());
  }

  bool _hasAnyData(DailyEntry entry, List<DriftLogEntry> log) {
    return entry.identity != null ||
        entry.hasGoogle ||
        entry.hasFitness ||
        entry.hasSleep ||
        entry.hasMusic ||
        log.isNotEmpty;
  }

  String _dayMarkdown(DailyEntry entry, List<DriftLogEntry> log) {
    final buffer = StringBuffer();
    buffer.writeln(
      '## ${entry.date}'
      '${entry.identity != null ? ' — ${entry.identity!.label}' : ''}',
    );
    buffer.writeln();

    if (entry.hasGoogle) {
      buffer.writeln('### Google');
      if (entry.googleDeepWorkMinutes != null) {
        buffer.writeln('- Deep Work: ${entry.googleDeepWorkMinutes} min');
      }
      if (entry.googleWin != null) {
        buffer.writeln('- Win: ${entry.googleWin}');
      }
      buffer.writeln();
    }

    if (entry.hasFitness) {
      buffer.writeln('### Fitness');
      if (entry.fitnessWorkout != null) {
        buffer.writeln('- Workout: ${entry.fitnessWorkout! ? 'Yes' : 'No'}');
      }
      if (entry.fitnessWalk != null) {
        buffer.writeln('- Walk: ${entry.fitnessWalk! ? 'Yes' : 'No'}');
      }
      if (entry.fitnessWeight != null) {
        buffer.writeln('- Weight: ${entry.fitnessWeight}');
      }
      if (entry.fitnessEnergy != null) {
        buffer.writeln('- Energy: ${entry.fitnessEnergy}/5');
      }
      buffer.writeln();
    }

    if (entry.hasSleep) {
      buffer.writeln('### Sleep');
      if (entry.sleepTime != null || entry.wakeTime != null) {
        buffer.writeln(
          '- Sleep: ${entry.sleepTime ?? '—'} → Wake: ${entry.wakeTime ?? '—'}',
        );
      }
      if (entry.sleepQuality != null) {
        buffer.writeln('- Quality: ${entry.sleepQuality}/5');
      }
      buffer.writeln();
    }

    if (entry.hasMusic) {
      buffer.writeln('### Music');
      if (entry.musicOpenedDaw != null) {
        buffer.writeln(
          '- Opened DAW: ${entry.musicOpenedDaw! ? 'Yes' : 'No'}',
        );
      }
      if (entry.musicMinutes != null) {
        buffer.writeln('- Minutes: ${entry.musicMinutes}');
      }
      buffer.writeln();
    }

    if (log.isNotEmpty) {
      buffer.writeln('### Drift Log');
      for (final item in log) {
        buffer.writeln('- ${item.timestamp} — ${item.text}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<void> _writeAndShare(String fileName, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: fileName),
    );
  }
}

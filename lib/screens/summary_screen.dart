import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/daily_entry.dart';
import '../models/drift_log_entry.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../widgets/fade_in.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _exportService = ExportService();
  DailyEntry? _entry;
  List<DriftLogEntry> _driftLog = [];
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = todayKey();
    final entry = await DatabaseHelper.instance.getEntryForDate(today);
    final log = await DatabaseHelper.instance.getDriftLogForDate(today);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _driftLog = log;
    });
  }

  Future<void> _export(Future<void> Function() action) async {
    setState(() => _exporting = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Day Wrap-Up')),
      body: ImmersiveBackground(
        child: entry == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: FadeIn(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Row(
                        children: [
                          Icon(
                            entry.identity?.icon ?? Icons.self_improvement,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.identity?.label ??
                                  'No identity set today',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (entry.hasGoogle)
                        _Section(
                          title: 'Google',
                          icon: Icons.terminal,
                          lines: [
                            if (entry.googleDeepWorkMinutes != null)
                              'Deep Work: ${entry.googleDeepWorkMinutes} min',
                            if (entry.googleWin != null)
                              'Win: ${entry.googleWin}',
                          ],
                        ),
                      if (entry.hasFitness)
                        _Section(
                          title: 'Fitness',
                          icon: Icons.fitness_center,
                          lines: [
                            if (entry.fitnessWorkout != null)
                              'Workout: ${entry.fitnessWorkout! ? 'Yes' : 'No'}',
                            if (entry.fitnessWalk != null)
                              'Walk: ${entry.fitnessWalk! ? 'Yes' : 'No'}',
                            if (entry.fitnessWeight != null)
                              'Weight: ${entry.fitnessWeight}',
                            if (entry.fitnessEnergy != null)
                              'Energy: ${entry.fitnessEnergy}/5',
                          ],
                        ),
                      if (entry.hasSleep)
                        _Section(
                          title: 'Sleep',
                          icon: Icons.bedtime,
                          lines: [
                            if (entry.sleepTime != null ||
                                entry.wakeTime != null)
                              'Sleep: ${entry.sleepTime ?? '—'} → Wake: ${entry.wakeTime ?? '—'}',
                            if (entry.sleepQuality != null)
                              'Quality: ${entry.sleepQuality}/5',
                          ],
                        ),
                      if (entry.hasMusic)
                        _Section(
                          title: 'Music',
                          icon: Icons.graphic_eq,
                          lines: [
                            if (entry.musicOpenedDaw != null)
                              'Opened DAW: ${entry.musicOpenedDaw! ? 'Yes' : 'No'}',
                            if (entry.musicMinutes != null)
                              'Minutes: ${entry.musicMinutes}',
                          ],
                        ),
                      if (_driftLog.isNotEmpty)
                        _Section(
                          title: 'Drift Log',
                          icon: Icons.timeline,
                          lines: [
                            for (final item in _driftLog)
                              '${item.timestamp} — ${item.text}',
                          ],
                        ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _exporting
                            ? null
                            : () => _export(_exportService.exportToday),
                        icon: const Icon(Icons.today),
                        label: const Text('Export Today'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _exporting
                            ? null
                            : () => _export(_exportService.exportWeek),
                        icon: const Icon(Icons.date_range),
                        label: const Text('Export This Week'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> lines;

  const _Section({required this.title, required this.icon, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(line),
            ),
        ],
      ),
    );
  }
}

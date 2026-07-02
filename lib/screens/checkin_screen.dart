import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/daily_entry.dart';
import '../models/drift_log_entry.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/page_transitions.dart';
import '../widgets/fade_in.dart';
import '../widgets/rating_selector.dart';
import '../widgets/toggle_field.dart';
import 'summary_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final String _today = todayKey();
  DailyEntry? _entry;
  List<DriftLogEntry> _driftLog = [];
  final _driftController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final entry = await DatabaseHelper.instance.getEntryForDate(_today);
    final log = await DatabaseHelper.instance.getDriftLogForDate(_today);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _driftLog = log;
    });
  }

  Future<void> _saveEntry(DailyEntry updated) async {
    await DatabaseHelper.instance.saveEntry(updated);
    await _reload();
  }

  Future<void> _addDriftLogEntry() async {
    final text = _driftController.text.trim();
    if (text.isEmpty) return;
    await DatabaseHelper.instance.addDriftLogEntry(
      DriftLogEntry(date: _today, timestamp: nowTime(), text: text),
    );
    _driftController.clear();
    await _reload();
  }

  Future<void> _showSheet(WidgetBuilder builder) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: builder,
    );
  }

  void _openGoogleSheet() {
    final entry = _entry!;
    _showSheet((_) => _GoogleSheet(entry: entry, onSave: _saveEntry));
  }

  void _openFitnessSheet() {
    final entry = _entry!;
    _showSheet((_) => _FitnessSheet(entry: entry, onSave: _saveEntry));
  }

  void _openSleepSheet() {
    final entry = _entry!;
    _showSheet((_) => _SleepSheet(entry: entry, onSave: _saveEntry));
  }

  void _openMusicSheet() {
    final entry = _entry!;
    _showSheet((_) => _MusicSheet(entry: entry, onSave: _saveEntry));
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(immersiveRoute(const SummaryScreen()));
            },
            icon: const Icon(Icons.nightlight_round),
            label: const Text('Wrap up'),
          ),
        ],
      ),
      body: ImmersiveBackground(
        child: entry == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: FadeIn(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _Header(entry: entry),
                      const SizedBox(height: 28),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.15,
                        children: [
                          _CategoryButton(
                            label: 'Google',
                            icon: Icons.terminal,
                            done: entry.hasGoogle,
                            onTap: _openGoogleSheet,
                          ),
                          _CategoryButton(
                            label: 'Fitness',
                            icon: Icons.fitness_center,
                            done: entry.hasFitness,
                            onTap: _openFitnessSheet,
                          ),
                          _CategoryButton(
                            label: 'Sleep',
                            icon: Icons.bedtime,
                            done: entry.hasSleep,
                            onTap: _openSleepSheet,
                          ),
                          _CategoryButton(
                            label: 'Music',
                            icon: Icons.graphic_eq,
                            done: entry.hasMusic,
                            onTap: _openMusicSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _DriftLogCard(
                        controller: _driftController,
                        entries: _driftLog,
                        onAdd: _addDriftLogEntry,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DailyEntry entry;

  const _Header({required this.entry});

  @override
  Widget build(BuildContext context) {
    final identity = entry.identity;
    final loggedCount = [
      entry.hasGoogle,
      entry.hasFitness,
      entry.hasSleep,
      entry.hasMusic,
    ].where((done) => done).length;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.royalBlue, AppColors.royalBlueDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.royalBlue.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            identity?.icon ?? Icons.self_improvement,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today: ${identity?.label ?? '—'}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '$loggedCount of 4 logged',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriftLogCard extends StatelessWidget {
  final TextEditingController controller;
  final List<DriftLogEntry> entries;
  final VoidCallback onAdd;

  const _DriftLogCard({
    required this.controller,
    required this.entries,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Icon(Icons.timeline, size: 20, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Drift Log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Where did you drift today?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'e.g. got pulled into Slack for an hour',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: onAdd, icon: const Icon(Icons.add)),
            ],
          ),
          if (entries.isNotEmpty) const SizedBox(height: 14),
          for (final logEntry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logEntry.timestamp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(logEntry.text)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: AppColors.royalBlue.withValues(alpha: 0.24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: done
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.royalBlue, AppColors.royalBlueDeep],
                  )
                : null,
            color: done ? null : AppColors.surfaceHigh.withValues(alpha: 0.7),
            border: Border.all(
              color: done
                  ? Colors.transparent
                  : AppColors.royalBlue.withValues(alpha: 0.18),
            ),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: AppColors.royalBlue.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: done ? Colors.white : AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: AnimatedScale(
                  scale: done ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  const _SheetScaffold({
    required this.title,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              onSave();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _GoogleSheet extends StatefulWidget {
  final DailyEntry entry;
  final ValueChanged<DailyEntry> onSave;

  const _GoogleSheet({required this.entry, required this.onSave});

  @override
  State<_GoogleSheet> createState() => _GoogleSheetState();
}

class _GoogleSheetState extends State<_GoogleSheet> {
  late final _minutesController = TextEditingController(
    text: widget.entry.googleDeepWorkMinutes?.toString() ?? '',
  );
  late final _winController = TextEditingController(
    text: widget.entry.googleWin ?? '',
  );

  @override
  void dispose() {
    _minutesController.dispose();
    _winController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Google',
      onSave: () {
        widget.onSave(
          widget.entry.copyWith(
            googleDeepWorkMinutes: int.tryParse(_minutesController.text),
            googleWin: _winController.text.trim().isEmpty
                ? null
                : _winController.text.trim(),
          ),
        );
      },
      children: [
        TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Deep Work — minutes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _winController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Today's win",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _FitnessSheet extends StatefulWidget {
  final DailyEntry entry;
  final ValueChanged<DailyEntry> onSave;

  const _FitnessSheet({required this.entry, required this.onSave});

  @override
  State<_FitnessSheet> createState() => _FitnessSheetState();
}

class _FitnessSheetState extends State<_FitnessSheet> {
  bool? _workout;
  bool? _walk;
  int? _energy;
  late final _weightController = TextEditingController(
    text: widget.entry.fitnessWeight?.toString() ?? '',
  );

  @override
  void initState() {
    super.initState();
    _workout = widget.entry.fitnessWorkout;
    _walk = widget.entry.fitnessWalk;
    _energy = widget.entry.fitnessEnergy;
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Fitness',
      onSave: () {
        widget.onSave(
          widget.entry.copyWith(
            fitnessWorkout: _workout,
            fitnessWalk: _walk,
            fitnessWeight: double.tryParse(_weightController.text),
            fitnessEnergy: _energy,
          ),
        );
      },
      children: [
        ToggleField(
          label: 'Workout?',
          value: _workout,
          onChanged: (v) => setState(() => _workout = v),
        ),
        const SizedBox(height: 16),
        ToggleField(
          label: 'Walk?',
          value: _walk,
          onChanged: (v) => setState(() => _walk = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        RatingSelector(
          label: 'Energy',
          value: _energy,
          onChanged: (v) => setState(() => _energy = v),
        ),
      ],
    );
  }
}

class _SleepSheet extends StatefulWidget {
  final DailyEntry entry;
  final ValueChanged<DailyEntry> onSave;

  const _SleepSheet({required this.entry, required this.onSave});

  @override
  State<_SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends State<_SleepSheet> {
  String? _sleepTime;
  String? _wakeTime;
  int? _quality;

  @override
  void initState() {
    super.initState();
    _sleepTime = widget.entry.sleepTime;
    _wakeTime = widget.entry.wakeTime;
    _quality = widget.entry.sleepQuality;
  }

  Future<void> _pickTime(bool isSleep) async {
    final initial = _parseTime(isSleep ? _sleepTime : _wakeTime) ??
        TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isSleep) {
        _sleepTime = formatted;
      } else {
        _wakeTime = formatted;
      }
    });
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Sleep',
      onSave: () {
        widget.onSave(
          widget.entry.copyWith(
            sleepTime: _sleepTime,
            wakeTime: _wakeTime,
            sleepQuality: _quality,
          ),
        );
      },
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sleep time'),
          trailing: Text(_sleepTime ?? '—'),
          onTap: () => _pickTime(true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Wake time'),
          trailing: Text(_wakeTime ?? '—'),
          onTap: () => _pickTime(false),
        ),
        const SizedBox(height: 16),
        RatingSelector(
          label: 'Quality',
          value: _quality,
          onChanged: (v) => setState(() => _quality = v),
        ),
      ],
    );
  }
}

class _MusicSheet extends StatefulWidget {
  final DailyEntry entry;
  final ValueChanged<DailyEntry> onSave;

  const _MusicSheet({required this.entry, required this.onSave});

  @override
  State<_MusicSheet> createState() => _MusicSheetState();
}

class _MusicSheetState extends State<_MusicSheet> {
  bool? _openedDaw;
  late final _minutesController = TextEditingController(
    text: widget.entry.musicMinutes?.toString() ?? '',
  );

  @override
  void initState() {
    super.initState();
    _openedDaw = widget.entry.musicOpenedDaw;
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Music',
      onSave: () {
        widget.onSave(
          widget.entry.copyWith(
            musicOpenedDaw: _openedDaw,
            musicMinutes: int.tryParse(_minutesController.text),
          ),
        );
      },
      children: [
        ToggleField(
          label: 'Opened DAW?',
          value: _openedDaw,
          onChanged: (v) => setState(() => _openedDaw = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

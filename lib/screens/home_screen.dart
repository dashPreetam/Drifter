import 'package:flutter/material.dart';

import '../data/home_prompts.dart';
import '../db/database_helper.dart';
import '../models/identity.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/page_transitions.dart';
import '../widgets/fade_in.dart';
import 'checkin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickIdentity(BuildContext context, Identity identity) async {
    final today = todayKey();
    final current = await DatabaseHelper.instance.getEntryForDate(today);
    await DatabaseHelper.instance.saveEntry(
      current.copyWith(identity: identity),
    );
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(immersiveRoute(const CheckInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImmersiveBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: FadeIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todaysPrompt(),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 32),
                  for (final identity in Identity.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _IdentityCard(
                        identity: identity,
                        onTap: () => _pickIdentity(context, identity),
                      ),
                    ),
                  const Spacer(),
                  const _Quote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: quoteTextStyle(
              context,
            ).copyWith(fontSize: 56, height: 0.6, color: AppColors.accent),
          ),
          Text(
            'Today is another chance to become someone '
            'Future Me will trust.',
            style: quoteTextStyle(context),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final Identity identity;
  final VoidCallback onTap;

  const _IdentityCard({required this.identity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: AppColors.royalBlue.withValues(alpha: 0.24),
        highlightColor: AppColors.royalBlue.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.royalBlue.withValues(alpha: 0.18),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Icon(identity.icon, size: 28, color: AppColors.accent),
              const SizedBox(width: 16),
              Text(
                identity.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

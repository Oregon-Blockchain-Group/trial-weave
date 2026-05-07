import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';

/// Persistent 5-item bottom nav. Center "Log" item opens a bottom sheet
/// with the four logging actions instead of navigating directly.
///
/// Embed in every top-level screen (Home, Progress, Cohort, Profile) so
/// the nav is always visible. The currently-active tab is determined by
/// the [currentRoute].
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Tab(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                active: currentRoute == '/home',
                onTap: () => context.go('/home'),
              ),
              _Tab(
                icon: Icons.trending_up,
                activeIcon: Icons.trending_up,
                label: 'Progress',
                active: currentRoute == '/progress',
                onTap: () => context.go('/progress'),
              ),
              _LogTab(onTap: () => _showLogSheet(context)),
              _Tab(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: 'Cohort',
                active: currentRoute.startsWith('/cohort'),
                onTap: () => context.go('/cohort'),
              ),
              _Tab(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'You',
                active: currentRoute.startsWith('/profile'),
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LogSheet(),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.darkTeal : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? activeIcon : icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogTab extends StatelessWidget {
  const _LogTab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle, color: AppColors.darkTeal, size: 24),
              const SizedBox(height: 2),
              const Text(
                'Log',
                style: TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('What do you want to log?', style: AppText.title),
            const SizedBox(height: 12),
            _SheetItem(
              icon: Icons.medical_services_outlined,
              label: 'A dose',
              subtitle: 'Mark your medication as taken',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/log/dose');
              },
            ),
            _SheetItem(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              subtitle: 'Today\'s weigh-in',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/log/weight');
              },
            ),
            _SheetItem(
              icon: Icons.healing_outlined,
              label: 'Side effects',
              subtitle: 'Any symptoms to report?',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/check-in/side-effect');
              },
            ),
            _SheetItem(
              icon: Icons.checklist_outlined,
              label: 'Daily check-in',
              subtitle: 'Rate your well-being today',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/check-in/post-dose');
              },
            ),
            _SheetItem(
              icon: Icons.attach_money,
              label: 'Monthly cost',
              subtitle: 'What you paid this month',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/log/cost');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tealTint,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, color: AppColors.darkTeal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

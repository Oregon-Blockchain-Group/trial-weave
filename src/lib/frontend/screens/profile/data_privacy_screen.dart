import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/auth_state_provider.dart';
import '../../../backend/providers/onboarding_provider.dart' show kConsentVersion;
import '../../../backend/providers/repositories_providers.dart';
import '../../../backend/repositories/auth_repository.dart';
import '../../../core/theme.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../logging/log_success_view.dart';

class _RequiredItem {
  const _RequiredItem({
    required this.key,
    required this.title,
    required this.body,
    required this.link,
  });
  final String key;
  final String title;
  final String body;
  final String link;
}

class _OptionalItem {
  const _OptionalItem({
    required this.key,
    required this.title,
    required this.body,
  });
  final String key;
  final String title;
  final String body;
}

const _required = <_RequiredItem>[
  _RequiredItem(
    key: 'terms',
    title: 'Terms of Service',
    body: 'I agree to the Terms of Service governing my use of Trial Weave.',
    link: 'View terms',
  ),
  _RequiredItem(
    key: 'privacy',
    title: 'Privacy Policy',
    body:
        'I have read the Privacy Policy describing how my data is collected, stored, and used.',
    link: 'View privacy policy',
  ),
  _RequiredItem(
    key: 'hipaa',
    title: 'HIPAA Authorization',
    body:
        'I authorize Lōkahi Therapeutics to collect, store, and process my health information in compliance with HIPAA.',
    link: 'View HIPAA notice',
  ),
];

const _optional = <_OptionalItem>[
  _OptionalItem(
    key: 'research',
    title: 'Contribute de-identified data to research',
    body:
        'Allow your anonymized outcomes to improve cohort comparisons and clinical insights for others.',
  ),
  _OptionalItem(
    key: 'sell',
    title: 'Allow sale of my data to third parties',
    body:
        'Permit Lōkahi to sell or share your personal information with third parties for compensation.',
  ),
  _OptionalItem(
    key: 'marketing',
    title: 'Marketing communications',
    body:
        'Receive product updates, surveys, and educational content by email.',
  ),
];

class DataPrivacyScreen extends ConsumerStatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  ConsumerState<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends ConsumerState<DataPrivacyScreen> {
  final Map<String, bool> _requiredChecked = {
    'terms': true,
    'privacy': true,
    'hipaa': true,
  };
  final Map<String, bool> _optionalOn = {
    'research': false,
    'sell': false,
    'marketing': false,
  };
  Map<String, bool> _originalGrants = const {};
  bool _hydrated = false;
  bool _busySave = false;
  bool _busyExport = false;
  bool _busyDelete = false;
  bool _success = false;
  String? _error;

  void _hydrate(Map<String, dynamic> grants) {
    if (_hydrated) return;
    _hydrated = true;
    setState(() {
      for (final k in _requiredChecked.keys.toList()) {
        _requiredChecked[k] = grants[k] == true;
      }
      for (final k in _optionalOn.keys.toList()) {
        _optionalOn[k] = grants[k] == true;
      }
      _originalGrants = {..._requiredChecked, ..._optionalOn};
    });
  }

  bool get _hasChanges {
    for (final entry in _requiredChecked.entries) {
      if (_originalGrants[entry.key] != entry.value) return true;
    }
    for (final entry in _optionalOn.entries) {
      if (_originalGrants[entry.key] != entry.value) return true;
    }
    return false;
  }

  bool get _canSave =>
      _requiredChecked.values.every((v) => v) && _hasChanges && !_busySave;

  Future<void> _onSave() async {
    setState(() {
      _busySave = true;
      _error = null;
    });
    try {
      await ref
          .read(consentsRepositoryProvider)
          .insert(
            version: kConsentVersion,
            grants: {..._requiredChecked, ..._optionalOn},
          );
      ref.invalidate(latestConsentProvider);
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/profile');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t save consents: $e');
    } finally {
      if (mounted) setState(() => _busySave = false);
    }
  }

  Future<void> _onExport() async {
    setState(() => _busyExport = true);
    try {
      final data = await ref.read(dataPrivacyRepositoryProvider).exportAll();
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Your data'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: SingleChildScrollView(
              child: SelectableText(
                pretty,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: pretty));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                }
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyExport = false);
    }
  }

  Future<void> _onDelete() async {
    final email = ref.read(currentUserProvider)?.email;
    if (email == null) return;

    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your account and every row of your '
              'data — profile, regimens, dose logs, weight, side effects, '
              'check-ins, costs, consents. There is no undo.',
            ),
            const SizedBox(height: 12),
            Text('To confirm, type your email: $email'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'your@email.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().toLowerCase() == email.toLowerCase()) {
                Navigator.of(ctx).pop(true);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Email doesn\'t match.')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyDelete = true);
    try {
      await ref.read(dataPrivacyRepositoryProvider).deleteAccount();
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go('/welcome');
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyDelete = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(eyebrow: 'Saved', title: 'Consents updated'),
        ),
      );
    }
    final consentAsync = ref.watch(latestConsentProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Data & privacy', style: AppText.title),
      ),
      body: SafeArea(
        child: consentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', style: const TextStyle(color: AppColors.danger)),
          ),
          data: (consent) {
            if (consent != null) _hydrate(consent.grants);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _eyebrow('REQUIRED'),
                const SizedBox(height: 8),
                for (final item in _required) ...[
                  _requiredCard(item),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                _eyebrow('OPTIONAL · YOU CONTROL THESE'),
                const SizedBox(height: 8),
                for (final item in _optional) ...[
                  _optionalCard(item),
                  const SizedBox(height: 8),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFB91C1C)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _canSave ? _onSave : null,
                  child: _busySave
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Save consents'),
                ),
                const SizedBox(height: 24),
                _DataCard(
                  title: 'Export your data',
                  body:
                      'Download a JSON snapshot of every row attached to your '
                      'account across all 8 tables.',
                  cta: _busyExport ? 'Exporting…' : 'Export',
                  onTap: _busyExport ? null : _onExport,
                  ctaTone: _CtaTone.normal,
                ),
                const SizedBox(height: 12),
                _DataCard(
                  title: 'Delete account',
                  body:
                      'Permanently removes your account and all your data. '
                      'Cascading deletes clean up every related row. There is '
                      'no undo and no archive.',
                  cta: _busyDelete ? 'Deleting…' : 'Delete account',
                  onTap: _busyDelete ? null : _onDelete,
                  ctaTone: _CtaTone.danger,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _eyebrow(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: OnboardingColors.sub,
    ),
  );

  Widget _requiredCard(_RequiredItem item) {
    final checked = _requiredChecked[item.key]!;
    return GestureDetector(
      onTap: () => setState(() => _requiredChecked[item.key] = !checked),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(
            color: checked ? OnboardingColors.primary : OnboardingColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    color: checked
                        ? OnboardingColors.primary
                        : CupertinoColors.white,
                    border: Border.all(
                      color: checked
                          ? OnboardingColors.primary
                          : OnboardingColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OnboardingColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: OnboardingColors.sub,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 6),
              child: Text(
                item.link,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: OnboardingColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionalCard(_OptionalItem item) {
    final on = _optionalOn[item.key]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: OnboardingColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OnboardingColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: OnboardingColors.sub,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: on,
            activeTrackColor: OnboardingColors.primary,
            onChanged: (v) => setState(() => _optionalOn[item.key] = v),
          ),
        ],
      ),
    );
  }
}

enum _CtaTone { normal, danger }

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
    required this.ctaTone,
  });
  final String title;
  final String body;
  final String cta;
  final VoidCallback? onTap;
  final _CtaTone ctaTone;

  @override
  Widget build(BuildContext context) {
    final isDanger = ctaTone == _CtaTone.danger;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.title),
          const SizedBox(height: 4),
          Text(body, style: AppText.bodyMuted),
          const SizedBox(height: 12),
          isDanger
              ? OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                  ),
                  child: Text(cta),
                )
              : ElevatedButton(onPressed: onTap, child: Text(cta)),
        ],
      ),
    );
  }
}

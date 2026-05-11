import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/auth_state_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../backend/repositories/auth_repository.dart';
import '../../../core/theme.dart';

class DataPrivacyScreen extends ConsumerStatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  ConsumerState<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends ConsumerState<DataPrivacyScreen> {
  bool _busyExport = false;
  bool _busyDelete = false;

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
      // The auth user is now gone; sign out clears the local session.
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _Card(
              title: 'Export your data',
              body:
                  'Download a JSON snapshot of every row attached to your '
                  'account across all 8 tables.',
              cta: _busyExport ? 'Exporting…' : 'Export',
              onTap: _busyExport ? null : _onExport,
              ctaTone: _CtaTone.normal,
            ),
            const SizedBox(height: 12),
            _Card(
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
        ),
      ),
    );
  }
}

enum _CtaTone { normal, danger }

class _Card extends StatelessWidget {
  const _Card({
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

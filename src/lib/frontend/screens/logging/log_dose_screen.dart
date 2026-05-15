import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'log_success_view.dart';

class LogDoseScreen extends ConsumerStatefulWidget {
  const LogDoseScreen({super.key});

  @override
  ConsumerState<LogDoseScreen> createState() => _LogDoseScreenState();
}

class _LogDoseScreenState extends ConsumerState<LogDoseScreen> {
  final _notes = TextEditingController();
  bool _busy = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _logNow() async {
    final regimen = await ref.read(activeRegimenProvider.future);
    if (regimen == null) {
      setState(
        () =>
            _error = 'No active regimen. Add one from Profile → Regimen first.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(doseLogsRepositoryProvider)
          .log(
            regimenId: regimen.id,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/check-in/post-dose');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t log the dose: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(title: 'Dose logged'),
        ),
      );
    }
    final regimenAsync = ref.watch(activeRegimenProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Log a dose', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              regimenAsync.when(
                data: (r) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tealTint,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Text(
                    r != null
                        ? '${r.brand} ${r.dose ?? ''} · ${r.frequency ?? ''}'
                        : 'No active regimen.',
                    style: const TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTeal,
                    ),
                  ),
                ),
                loading: () => const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    Text('$e', style: const TextStyle(color: AppColors.danger)),
              ),
              const SizedBox(height: 24),
              const Text('Notes (optional)', style: AppText.bodyMuted),
              const SizedBox(height: 6),
              TextField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Anything notable about this dose?',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _busy ? null : _logNow,
                child: _busy
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
                    : const Text('I took it now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

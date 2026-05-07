import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/factor.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/sliders/factor_slider.dart';

class PostDoseCheckInScreen extends ConsumerStatefulWidget {
  const PostDoseCheckInScreen({super.key});

  @override
  ConsumerState<PostDoseCheckInScreen> createState() =>
      _PostDoseCheckInScreenState();
}

class _PostDoseCheckInScreenState extends ConsumerState<PostDoseCheckInScreen> {
  late Map<String, int> _ratings;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ratings = {for (final f in kFactorCatalog) f.key: 3};
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(factorLogsRepositoryProvider).insertCheckIn(_ratings);
      if (mounted) context.go('/home');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t save the check-in: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Post-dose check-in', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('How are you doing?', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'Rate each on a 1-5 scale. We compare these against your '
                'baseline and your cohort.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final f in kFactorCatalog) ...[
                        FactorSlider(
                          factor: f,
                          value: _ratings[f.key]!,
                          onChanged: (v) => setState(() => _ratings[f.key] = v),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _save,
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
                    : const Text('Save check-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

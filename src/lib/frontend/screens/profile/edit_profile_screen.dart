import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/profile.dart';
import '../../../backend/providers/auth_state_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/dialogs/reason_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _heightFt = TextEditingController();
  final _heightIn = TextEditingController();
  final _weight = TextEditingController();
  String? _sex;
  String? _race;
  bool _busy = false;
  bool _hydrated = false;
  String? _error;
  Profile? _original;

  @override
  void dispose() {
    _age.dispose();
    _city.dispose();
    _state.dispose();
    _heightFt.dispose();
    _heightIn.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _hydrate(Profile p) {
    if (_hydrated) return;
    _hydrated = true;
    _original = p;
    _age.text = p.age?.toString() ?? '';
    _city.text = p.city ?? '';
    _state.text = p.state ?? '';
    _heightFt.text = p.heightFeet?.toString() ?? '';
    _heightIn.text = p.heightInches?.toString() ?? '';
    _weight.text = p.startingWeightLb?.toString() ?? '';
    _sex = p.sex;
    _race = p.raceEthnicity;
  }

  /// Builds the (column, newValue) list of fields the user actually changed
  /// vs the hydrated profile. Empty strings become null to match the model.
  List<MapEntry<String, Object?>> _diff() {
    final orig = _original;
    if (orig == null) return const [];
    String? trimOrNull(String s) => s.trim().isEmpty ? null : s.trim();
    final next = <String, Object?>{
      'age': int.parse(_age.text),
      'sex': _sex,
      'race_ethnicity': _race,
      'city': trimOrNull(_city.text),
      'state': trimOrNull(_state.text),
      'height_feet': int.parse(_heightFt.text),
      'height_inches': int.parse(_heightIn.text),
      'starting_weight_lb': double.parse(_weight.text),
    };
    final current = <String, Object?>{
      'age': orig.age,
      'sex': orig.sex,
      'race_ethnicity': orig.raceEthnicity,
      'city': orig.city,
      'state': orig.state,
      'height_feet': orig.heightFeet,
      'height_inches': orig.heightInches,
      'starting_weight_lb': orig.startingWeightLb,
    };
    return next.entries.where((e) => e.value != current[e.key]).toList();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_sex == null || _race == null) {
      setState(() => _error = 'Pick a sex and race/ethnicity.');
      return;
    }
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final changes = _diff();
    if (changes.isEmpty) {
      if (mounted) context.go('/profile');
      return;
    }

    final reason = await showReasonDialog(context);
    if (reason == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(profilesRepositoryProvider);
      for (final change in changes) {
        await repo.updateField(
          column: change.key,
          value: change.value,
          reason: reason,
        );
      }
      ref.invalidate(currentProfileProvider);
      if (mounted) context.go('/profile');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t save profile: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Edit profile', style: AppText.title),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', style: const TextStyle(color: AppColors.danger)),
          ),
          data: (profile) {
            if (profile != null) _hydrate(profile);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Label('Age'),
                            TextFormField(
                              controller: _age,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 13 || n > 100) {
                                  return 'Age 13-100';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _Label('Sex'),
                            DropdownButtonFormField<String>(
                              initialValue: _sex,
                              items: const [
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem(
                                  value: 'male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'intersex',
                                  child: Text('Intersex'),
                                ),
                                DropdownMenuItem(
                                  value: 'prefer_not_to_say',
                                  child: Text('Prefer not to say'),
                                ),
                              ],
                              onChanged: (v) => setState(() => _sex = v),
                            ),
                            const SizedBox(height: 16),
                            _Label('Race / ethnicity'),
                            DropdownButtonFormField<String>(
                              initialValue: _race,
                              items: const [
                                DropdownMenuItem(
                                  value: 'asian',
                                  child: Text('Asian'),
                                ),
                                DropdownMenuItem(
                                  value: 'black',
                                  child: Text('Black or African American'),
                                ),
                                DropdownMenuItem(
                                  value: 'hispanic',
                                  child: Text('Hispanic or Latino'),
                                ),
                                DropdownMenuItem(
                                  value: 'native',
                                  child: Text(
                                    'Native American or Alaska Native',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'pacific_islander',
                                  child: Text(
                                    'Native Hawaiian or Pacific Islander',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'white',
                                  child: Text('White'),
                                ),
                                DropdownMenuItem(
                                  value: 'multiple',
                                  child: Text('Two or more'),
                                ),
                                DropdownMenuItem(
                                  value: 'prefer_not_to_say',
                                  child: Text('Prefer not to say'),
                                ),
                              ],
                              onChanged: (v) => setState(() => _race = v),
                            ),
                            const SizedBox(height: 16),
                            _Label('Height'),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightFt,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'ft',
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse(v ?? '');
                                      if (n == null || n < 3 || n > 8) {
                                        return '3-8';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightIn,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'in',
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse(v ?? '');
                                      if (n == null || n < 0 || n > 11) {
                                        return '0-11';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _Label('Starting weight (lb)'),
                            TextFormField(
                              controller: _weight,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Enter a starting weight';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _Label('City (optional)'),
                            TextFormField(controller: _city),
                            const SizedBox(height: 16),
                            _Label('State (optional)'),
                            TextFormField(controller: _state),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.md,
                                  ),
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
                          ],
                        ),
                      ),
                    ),
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
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppText.bodyMuted),
  );
}

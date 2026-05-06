import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'core/supabase.dart';
import 'frontend/app.dart';
import 'frontend/screens/misconfigured_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Config.load();
    await initSupabase();
  } on ConfigError catch (e) {
    runApp(MisconfiguredScreen(missingKeys: e.missingKeys));
    return;
  }
  runApp(const ProviderScope(child: TrialWeaveApp()));
}

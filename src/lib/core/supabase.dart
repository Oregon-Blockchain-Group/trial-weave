import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Initializes the global Supabase client from [Config]. Call once at app
/// startup, after [Config.load] has resolved.
Future<void> initSupabase() async {
  final cfg = Config.instance;
  await Supabase.initialize(url: cfg.supabaseUrl, anonKey: cfg.supabaseAnonKey);
}

/// Convenience accessor — equivalent to `Supabase.instance.client`.
SupabaseClient get supabase => Supabase.instance.client;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to runtime configuration loaded from `.env`.
///
/// Call [Config.load] once at app startup. After that, use [Config.instance]
/// from anywhere. If [Config.load] throws [ConfigError], render
/// `MisconfiguredScreen` with the error's `missingKeys` instead of crashing.
class Config {
  Config._({required this.supabaseUrl, required this.supabaseAnonKey});

  final String supabaseUrl;
  final String supabaseAnonKey;

  static Config? _instance;
  static Config get instance {
    final c = _instance;
    if (c == null) {
      throw StateError('Config.load() must be called before Config.instance');
    }
    return c;
  }

  /// Loads `.env` from the asset bundle and validates required keys.
  /// Throws [ConfigError] with the list of missing keys when invalid.
  static Future<Config> load() async {
    await dotenv.load(fileName: '.env');

    final missing = <String>[];
    final url = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    final key = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
    if (url.isEmpty) missing.add('SUPABASE_URL');
    if (key.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (missing.isNotEmpty) {
      throw ConfigError(missingKeys: missing);
    }

    final c = Config._(supabaseUrl: url, supabaseAnonKey: key);
    _instance = c;
    return c;
  }
}

class ConfigError implements Exception {
  ConfigError({required this.missingKeys});
  final List<String> missingKeys;

  @override
  String toString() => 'ConfigError(missingKeys: $missingKeys)';
}

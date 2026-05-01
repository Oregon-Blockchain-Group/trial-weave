import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // WelcomeScreen uses Material widgets
import 'screens/welcome_screen.dart';
import 'frontend/components/onboarding_2.dart';

class TrialWeaveApp extends StatelessWidget {
  const TrialWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Trial Weave',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF234A67),
        scaffoldBackgroundColor: Color(0xFFFAFAFA),
      ),
      // Material localization + theme so Material widgets inside WelcomeScreen
      // (Scaffold, OutlinedButton, ElevatedButton) resolve correctly.
      builder: (context, child) =>
          Material(type: MaterialType.transparency, child: child),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // TODO: read Supabase session from FlutterSecureStorage / supabase_flutter.
    final token = await _readToken();
    if (!mounted) return;
    setState(() {
      _signedIn = token != null;
      _loading = false;
    });
  }

  Future<String?> _readToken() async => null; // stub

  Future<void> _persistToken(String token) async {
    // TODO: persist via supabase_flutter / FlutterSecureStorage.
    if (!mounted) return;
    setState(() => _signedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (!_signedIn) {
      return WelcomeScreen(
        onSignInWithApple: () async {
          // TODO: SignInWithApple.getAppleIDCredential(...) → Supabase.auth.signInWithIdToken(...)
          await _persistToken('apple_token_stub');
        },
        onSignInWithGoogle: () async {
          // TODO: GoogleSignIn().signIn() → Supabase.auth.signInWithIdToken(...)
          await _persistToken('google_token_stub');
        },
      );
    }
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Trial Weave')),
      child: Center(child: Text('Dashboard goes here')),
    );
  }
}

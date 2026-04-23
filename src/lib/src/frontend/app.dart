import 'package:flutter/cupertino.dart';

import 'home_screen.dart';

class TrialWeaveApp extends StatelessWidget {
  const TrialWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'trial-weave',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemIndigo,
      ),
      home: HomeScreen(),
    );
  }
}
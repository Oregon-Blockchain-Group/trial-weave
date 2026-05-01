import 'package:flutter/cupertino.dart';

class TrialWeaveApp extends StatelessWidget {
  const TrialWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Trial Weave',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Trial Weave')),
        child: Center(child: Text('Hello, Trial Weave')),
      ),
    );
  }
}

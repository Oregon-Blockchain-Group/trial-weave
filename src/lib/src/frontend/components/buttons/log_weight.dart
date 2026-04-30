import 'package:flutter/cupertino.dart';

class LogWeightButton extends StatelessWidget {
  const LogWeightButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.add, size: 18),
          SizedBox(width: 8),
          Text(
            'Log weight',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

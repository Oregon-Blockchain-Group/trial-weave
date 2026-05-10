import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Prompts the user for a reason explaining why they're changing audited
/// data. Returns the trimmed reason on Save, or null if dismissed/cancelled.
/// Save is disabled until at least 3 characters are entered (matches the
/// server-side check in `update_profile_field`).
Future<String?> showReasonDialog(
  BuildContext context, {
  String title = 'Why are you making this change?',
  String hint = 'e.g. entered the wrong value at signup',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ReasonDialog(title: title, hint: hint),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.hint});
  final String title;
  final String hint;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final ok = _controller.text.trim().length >= 3;
      if (ok != _valid) setState(() => _valid = ok);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: AppText.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _valid
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

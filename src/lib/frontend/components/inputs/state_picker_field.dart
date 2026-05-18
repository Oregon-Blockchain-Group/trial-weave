import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

const kUsStates = <String>[
  'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
  'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
  'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
  'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
  'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
  'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
  'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
  'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
  'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
  'West Virginia', 'Wisconsin', 'Wyoming', 'District of Columbia',
];

class StatePickerField extends StatelessWidget {
  const StatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Select a state',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String placeholder;

  Future<void> _open(BuildContext context) async {
    final start = (value == null) ? 0 : kUsStates.indexOf(value!);
    int selected = start < 0 ? 0 : start;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      onChanged(kUsStates[selected]);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selected),
                  itemExtent: 36,
                  onSelectedItemChanged: (i) => selected = i,
                  children: [
                    for (final s in kUsStates) Center(child: Text(s)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return InkWell(
      onTap: () => _open(context),
      child: InputDecorator(
        decoration: const InputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? placeholder : value!,
                style: empty ? AppText.bodyMuted : null,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.inkBlack),
          ],
        ),
      ),
    );
  }
}

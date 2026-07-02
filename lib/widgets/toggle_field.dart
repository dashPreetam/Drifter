import 'package:flutter/material.dart';

class ToggleField extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const ToggleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Yes')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected: value == null ? const {} : {value!},
          emptySelectionAllowed: true,
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) onChanged(selection.first);
          },
        ),
      ],
    );
  }
}

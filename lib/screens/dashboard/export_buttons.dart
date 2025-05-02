// lib/screens/dashboard/export_buttons.dart
import 'package:flutter/material.dart';

class ExportButtons extends StatelessWidget {
  final VoidCallback onCsv;
  final VoidCallback onPdf;

  const ExportButtons({Key? key, required this.onCsv, required this.onPdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: ElevatedButton(onPressed: onCsv, child: const Text('Export CSV'))),
        const SizedBox(width: 16),
        Flexible(child: ElevatedButton(onPressed: onPdf, child: const Text('Export PDF'))),
      ],
    );
  }
}

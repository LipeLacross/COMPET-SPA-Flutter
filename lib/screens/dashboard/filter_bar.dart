// lib/screens/dashboard/filter_bar.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterBar extends StatelessWidget {
  final String? searchText;
  final DateTimeRange? selectedPeriod;
  final bool showOnlyBeneficiaries;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DateTimeRange?> onPeriodChanged;
  final ValueChanged<bool> onBeneficiaryToggle;

  const FilterBar({
    super.key,
    required this.searchText,
    required this.selectedPeriod,
    required this.showOnlyBeneficiaries,
    required this.onSearchChanged,
    required this.onPeriodChanged,
    required this.onBeneficiaryToggle,
  });

  String _formatPeriod(DateTimeRange? pr) {
    if (pr == null) return 'Período';
    final df = DateFormat('dd/MM');
    return '${df.format(pr.start)} – ${df.format(pr.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 1) Busca genérica
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // 2) Botão de período + texto de resumo
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(_formatPeriod(selectedPeriod)),
            onPressed: () async {
              final pr = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: selectedPeriod,
              );
              onPeriodChanged(pr);
            },
          ),

          // 3) Alternar só beneficiários
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Só beneficiários'),
              Switch(
                value: showOnlyBeneficiaries,
                onChanged: onBeneficiaryToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

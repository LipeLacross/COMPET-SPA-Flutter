// lib/screens/dashboard/filter_bar.dart
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String? searchName;
  final String? selectedType;
  final DateTimeRange? selectedPeriod;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<DateTimeRange?> onPeriodChanged;

  const FilterBar({
    super.key,
    required this.searchName,
    required this.selectedType,
    required this.selectedPeriod,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar beneficiário',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          DropdownButton<String>(
            hint: const Text('Tipo'),
            value: selectedType,
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'area', child: Text('Área')),
              DropdownMenuItem(value: 'activity', child: Text('Atividade')),
            ],
            onChanged: onTypeChanged,
          ),
          ElevatedButton(
            child: const Text('Período'),
            onPressed: () async {
              final pr = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              onPeriodChanged(pr);
            },
          ),
        ],
      ),
    );
  }
}

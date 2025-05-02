import 'package:flutter/material.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../services/api_service.dart';
import '../models/beneficiary.dart';
import '../models/report.dart';
import '../utils/date_helper.dart';
import 'dart:convert';  // <-- Adicione esta linha

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _api = ApiService();

  // estados
  List<Beneficiary> _bens = [];
  List<Report>      _reps = [];
  bool _loadingBens = false, _loadingReps = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBeneficiaries();
    _fetchReports();
  }

  Future<void> _fetchBeneficiaries() async {
    setState(() => _loadingBens = true);
    final res = await _api.get('beneficiaries');
    final list = (res.body.isNotEmpty ? List<Map<String, dynamic>>.from(json.decode(res.body)) : []);
    setState(() {
      _bens = list.map((m) => Beneficiary.fromMap(m)).toList();
      _loadingBens = false;
    });
  }

  Future<void> _fetchReports() async {
    setState(() => _loadingReps = true);
    final res = await _api.get('reports');
    final list = (res.body.isNotEmpty ? List<Map<String, dynamic>>.from(json.decode(res.body)) : []);
    setState(() {
      _reps = list.map((m) => Report.fromMap(m)).toList();
      _loadingReps = false;
    });
  }

  Future<void> _deleteBeneficiary(String name) async {
    await _api.delete('beneficiaries/$name');
    _fetchBeneficiaries();
  }

  void _openEditDialog(Beneficiary ben) {
    final nameCtrl   = TextEditingController(text: ben.name);
    final areaCtrl   = TextEditingController(text: ben.areaPreserved.toString());
    final servCtrl   = TextEditingController(text: ben.serviceDescription);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Beneficiário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(label: 'Nome', controller: nameCtrl),
            const SizedBox(height: 8),
            CustomInput(label: 'Área (m²)', controller: areaCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CustomInput(label: 'Serviço', controller: servCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          CustomButton(
            label: 'Salvar',
            onPressed: () async {
              final updated = Beneficiary(
                name: nameCtrl.text.trim(),
                areaPreserved: double.tryParse(areaCtrl.text) ?? ben.areaPreserved,
                serviceDescription: servCtrl.text.trim(),
              );
              await _api.put('beneficiaries/${ben.name}', updated.toMap());
              Navigator.pop(context);
              _fetchBeneficiaries();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Beneficiários'),
            Tab(text: 'Pagamentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === TAB 1: Beneficiários ===
          _loadingBens
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _bens.length,
            itemBuilder: (_, i) {
              final ben = _bens[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(ben.name),
                  subtitle: Text('Área: ${ben.areaPreserved}m²\n${ben.serviceDescription}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _openEditDialog(ben),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBeneficiary(ben.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // === TAB 2: Pagamentos / relatórios ===
          _loadingReps
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _reps.length,
            itemBuilder: (_, i) {
              final r = _reps[i];
              return ListTile(
                leading: const Icon(Icons.payment),
                title: Text(r.title),
                subtitle: Text('${DateHelper.formatDate(r.date)}\nURL: ${r.url}'),
                onTap: () => {/* abrir link ou detalhes */},
              );
            },
          ),
        ],
      ),
    );
  }
}

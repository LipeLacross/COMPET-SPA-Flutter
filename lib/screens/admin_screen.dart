import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';  // para gerar token UUID

import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../screens/beneficiary_edit_screen.dart';  // tela de edição
import '../screens/beneficiary_detail_screen.dart'; // tela de detalhes
import '../screens/report_edit_screen.dart';      // tela de edição/criação de pagamentos
import '../services/api_service.dart';
import '../services/session_manager.dart';  // para gerenciar token de beneficiário
import '../models/beneficiary.dart';
import '../models/report.dart';
import '../utils/date_helper.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _api = ApiService();
  final _sm  = SessionManager();

  List<Beneficiary> _bens = [];
  List<Report>      _reps = [];
  bool _loadingBens = false;
  bool _loadingReps = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBeneficiaries();
    _loadReports();
  }

  Future<void> _loadBeneficiaries() async {
    setState(() => _loadingBens = true);
    final res = await _api.get('beneficiaries');
    final list = res.body.isNotEmpty
        ? List<Map<String, dynamic>>.from(json.decode(res.body))
        : <Map<String, dynamic>>[];
    setState(() {
      _bens = list.map((m) => Beneficiary.fromMap(m)).toList();
      _loadingBens = false;
    });
  }

  Future<void> _loadReports() async {
    setState(() => _loadingReps = true);
    final res = await _api.get('reports');
    final list = res.body.isNotEmpty
        ? List<Map<String, dynamic>>.from(json.decode(res.body))
        : <Map<String, dynamic>>[];
    setState(() {
      _reps = list.map((m) => Report.fromMap(m)).toList();
      _loadingReps = false;
    });
  }

  Future<void> _deleteBeneficiary(String name) async {
    await _api.delete('beneficiaries/$name');
    _loadBeneficiaries();
  }

  Future<void> _deleteReport(String id) async {
    await _api.delete('reports/$id');
    _loadReports();
  }

  Future<void> _grantAccess() async {
    final token = const Uuid().v4();
    await _sm.saveBeneficiaryToken(token);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Acesso concedido! Token: \$token')),
    );
  }

  void _openEditBeneficiary(Beneficiary ben) {
    Navigator.push<Beneficiary>(
      context,
      MaterialPageRoute(builder: (_) => BeneficiaryEditScreen(ben: ben)),
    ).then((updated) {
      if (updated != null) _loadBeneficiaries();
    });
  }

  void _viewBeneficiaryDetails(Beneficiary ben) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BeneficiaryDetailScreen(ben: ben)),
    );
  }

  void _openCreateReport() {
    Navigator.push<Report>(
      context,
      MaterialPageRoute(builder: (_) => ReportEditScreen()),
    ).then((saved) {
      if (saved != null) _loadReports();
    });
  }

  void _openEditReport(Report rep) {
    Navigator.push<Report>(
      context,
      MaterialPageRoute(builder: (_) => ReportEditScreen(report: rep)),
    ).then((updated) {
      if (updated != null) _loadReports();
    });
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
          // === ABA BENEFICIÁRIOS ===
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
                  subtitle: Text(
                    'Área: \${ben.areaPreserved}m²\n\${ben.serviceDescription}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.blue),
                        tooltip: 'Detalhes',
                        onPressed: () => _viewBeneficiaryDetails(ben),
                      ),
                      IconButton(
                        icon: const Icon(Icons.vpn_key, color: Colors.blue),
                        tooltip: 'Conceder Acesso',
                        onPressed: _grantAccess,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        tooltip: 'Editar',
                        onPressed: () => _openEditBeneficiary(ben),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Deletar',
                        onPressed: () => _deleteBeneficiary(ben.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // === ABA PAGAMENTOS ===
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Pagamento'),
                    onPressed: _openCreateReport,
                  ),
                ),
              ),
              Expanded(
                child: _loadingReps
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _reps.length,
                  itemBuilder: (_, i) {
                    final r = _reps[i];
                    return ListTile(
                      leading: const Icon(Icons.payment),
                      title: Text(r.title),
                      subtitle: Text(
                        '\${DateHelper.formatDate(r.date)}\n\${r.url}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _openEditReport(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReport(r.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

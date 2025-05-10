import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart'; // Import para abrir o URL
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../models/report.dart';
import '../utils/date_helper.dart';

/// Modelo temporário de usuário para administração
class User {
  final String id;
  String name;
  String email;
  String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role,
  };
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _api = ApiService();
  final _sm = SessionManager();

  List<User> _users = [];
  List<Report> _reports = [];
  bool _loadingUsers = false;
  bool _loadingReports = false;
  bool _loadingPowerBIData = false;

  final _searchController = TextEditingController();
  List<dynamic> _powerBIData = [];  // Para armazenar os dados do Power BI/GeoNode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);  // Adicionando a nova aba
    _loadUsers();
    _loadReports();
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    final res = await _api.get('users');
    final list = res.body.isNotEmpty
        ? List<Map<String, dynamic>>.from(json.decode(res.body))
        : <Map<String, dynamic>>[];
    setState(() {
      _users = list.map((m) => User.fromMap(m)).toList();
      _loadingUsers = false;
    });
  }

  Future<void> _loadReports() async {
    setState(() => _loadingReports = true);
    final res = await _api.get('reports');
    final list = res.body.isNotEmpty
        ? List<Map<String, dynamic>>.from(json.decode(res.body))
        : <Map<String, dynamic>>[];
    setState(() {
      _reports = list.map((m) => Report.fromMap(m)).toList();
      _loadingReports = false;
    });
  }

  // Função para carregar dados do Power BI ou GeoNode
  Future<void> _loadPowerBIData() async {
    setState(() => _loadingPowerBIData = true);

    try {
      final res = await _api.get('powerbi_data');  // Supondo que você tenha uma rota para o Power BI/GeoNode
      final data = json.decode(res.body);
      setState(() {
        _powerBIData = data;  // Armazenar dados recebidos
        _loadingPowerBIData = false;
      });
    } catch (e) {
      setState(() {
        _loadingPowerBIData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
        actions: [
          // Dashboard
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuários'),
            Tab(text: 'Pagamentos'),
            Tab(text: 'Power BI / GeoNode'), // Nova aba para o Power BI/GeoNode
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === Usuários ===
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Buscar usuários',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: _loadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final user = _users[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Text(user.role),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // === Pagamentos ===
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export CSV'),
                        onPressed: _exportCsv,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        onPressed: _exportPdf,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // === Power BI / GeoNode ===
          Column(
            children: [
              _loadingPowerBIData
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: _powerBIData.length,
                  itemBuilder: (_, i) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text('Data: ${_powerBIData[i]['date']}'),  // Exemplo de dado
                        subtitle: Text('Valor: ${_powerBIData[i]['value']}'),  // Exemplo de dado
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

  Future<void> _logout() async {
    await _sm.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _exportCsv() async {
    final rows = <List<String>>[
      ['Título', 'Data', 'URL']
    ];
    for (var r in _reports) {
      rows.add([r.title, DateHelper.formatDate(r.date), r.url]);
    }
    final csvString = const ListToCsvConverter().convert(rows);
    await Share.share(csvString, subject: 'Relatórios.csv');
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) {
      final headers = ['Título', 'Data', 'URL'];
      final data = _reports
          .map((r) => [r.title, DateHelper.formatDate(r.date), r.url])
          .toList();
      return pw.Column(children: [
        pw.Text('Relatórios', style: const pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(headers: headers, data: data),
      ]);
    }));
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'relatorios.pdf');
  }
}

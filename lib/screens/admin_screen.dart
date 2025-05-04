// lib/screens/admin_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  const AdminScreen({Key? key}) : super(key: key);

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

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> _toggleBeneficiary(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${user.role == 'beneficiary' ? 'Revogar' : 'Conceder'} Beneficiário'),
        content: Text(
            'Tem certeza que deseja ${user.role == 'beneficiary' ? 'revogar' : 'conceder'} o acesso de ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirm != true) return;

    final newRole = user.role == 'beneficiary' ? 'user' : 'beneficiary';
    await _api.changeUserRole(user.id, newRole);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newRole == 'beneficiary'
            ? '${user.name} agora é beneficiário.'
            : 'Beneficiário de ${user.name} revogado.'),
      ),
    );
    _loadUsers();
  }

  Future<void> _openEditUser(User user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-mail')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (result != true) return;
    user.name = nameCtrl.text.trim();
    user.email = emailCtrl.text.trim();
    await _api.put('users/${user.id}', user.toMap());
    _loadUsers();
  }

  Future<void> _exportCsv() async {
    final rows = <List<String>>[ ['Título', 'Data', 'URL'] ];
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
      final data = _reports.map((r) => [r.title, DateHelper.formatDate(r.date), r.url]).toList();
      return pw.Column(children: [
        pw.Text('Relatórios', style: const pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(headers: headers, data: data),
      ]);
    }));
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'relatorios.pdf');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      final q = _searchController.text.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [ Tab(text: 'Usuários'), Tab(text: 'Pagamentos') ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === Usuarios com filtro e edição ===
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
                  itemCount: filteredUsers.length,
                  itemBuilder: (_, i) {
                    final user = filteredUsers[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar usuário',
                              onPressed: () => _openEditUser(user),
                            ),
                            Text(user.role),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                user.role == 'beneficiary'
                                    ? Icons.remove_circle
                                    : Icons.check_circle,
                                color: user.role == 'beneficiary' ? Colors.red : Colors.green,
                              ),
                              tooltip: user.role == 'beneficiary'
                                  ? 'Revogar Beneficiário'
                                  : 'Conceder Beneficiário',
                              onPressed: () => _toggleBeneficiary(user),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // === Pagamentos com exportação ===
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              Expanded(
                child: _loadingReports
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (_, i) {
                    final r = _reports[i];
                    return ListTile(
                      leading: const Icon(Icons.payment),
                      title: Text(r.title),
                      subtitle: Text(
                        '${DateHelper.formatDate(r.date)}\n${r.url}',
                      ),
                      isThreeLine: true,
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

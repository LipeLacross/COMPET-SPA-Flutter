// lib/screens/beneficiary_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import '../components/whatsapp_button.dart';
import '../services/geolocation_service.dart';
import '../services/local_storage_service.dart';
import '../services/report_service.dart';
import '../services/notification_service.dart';
import '../models/offline_record.dart';
import '../models/report.dart';
import '../utils/date_helper.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({Key? key}) : super(key: key);

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Área Coberta controllers
  final _areaTotalController       = TextEditingController();
  final _areaAppController         = TextEditingController();
  final _descriptionAreaController = TextEditingController();
  final _addressController         = TextEditingController();
  final _forestTypeController      = TextEditingController();
  final _animalsController         = TextEditingController();
  final _humanResourcesController  = TextEditingController();
  final _otherResourcesController  = TextEditingController();

  // Atividades controller
  final _descController = TextEditingController();

  // Services
  final _geoService      = GeolocationService();
  final _storageService  = LocalStorageService();
  final _reportService   = ReportService();
  final _notifService    = NotificationService();

  File?     _pickedImage;
  Position? _currentPos;
  List<OfflineRecord> _records  = [];
  List<Report>       _payments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecords();
    _loadPayments();
    _notifService.init();
  }

  Future<void> _loadRecords() async {
    final recs = await _storageService.fetchQueue();
    setState(() => _records = recs);
  }

  Future<void> _loadPayments() async {
    try {
      final reps = await _reportService.fetchReports();
      setState(() => _payments = reps);
    } catch (_) {}
  }

  Future<void> _saveArea() async {
    final rec = OfflineRecord(
      id: DateTime.now().toIso8601String(),
      payload: {
        'type': 'area',
        'areaTotal': double.tryParse(_areaTotalController.text) ?? 0.0,
        'areaApp': double.tryParse(_areaAppController.text) ?? 0.0,
        'description': _descriptionAreaController.text,
        'address': _addressController.text,
        'forestType': _forestTypeController.text,
        'animals': _animalsController.text,
        'humanResources': _humanResourcesController.text,
        'otherResources': _otherResourcesController.text,
        'date': DateHelper.formatDate(DateTime.now()),
      },
      createdAt: DateTime.now(),
    );
    await _storageService.saveRecord(rec);
    _clearAreaInputs();
    _loadRecords();
  }

  Future<void> _showEditAreaDialog(OfflineRecord record) async {
    // pré-preenche campos
    _areaTotalController.text       = record.payload['areaTotal'].toString();
    _areaAppController.text         = record.payload['areaApp'].toString();
    _descriptionAreaController.text = record.payload['description'];
    _addressController.text         = record.payload['address'];
    _forestTypeController.text      = record.payload['forestType'];
    _animalsController.text         = record.payload['animals'];
    _humanResourcesController.text  = record.payload['humanResources'] ?? '';
    _otherResourcesController.text  = record.payload['otherResources'] ?? '';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Área'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              CustomInput(label: 'Área Total (m²)', controller: _areaTotalController),
              const SizedBox(height: 8),
              CustomInput(label: 'Área APP (m²)', controller: _areaAppController),
              const SizedBox(height: 8),
              CustomInput(label: 'Descrição', controller: _descriptionAreaController),
              const SizedBox(height: 8),
              CustomInput(label: 'Endereço', controller: _addressController),
              const SizedBox(height: 8),
              CustomInput(label: 'Tipo de Mata', controller: _forestTypeController),
              const SizedBox(height: 8),
              CustomInput(label: 'Animais na Região', controller: _animalsController),
              const SizedBox(height: 8),
              CustomInput(label: 'Recursos Humanos na Área', controller: _humanResourcesController),
              const SizedBox(height: 8),
              CustomInput(label: 'Outros Recursos (opcional)', controller: _otherResourcesController),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );

    if (ok ?? false) {
      final updated = OfflineRecord(
        id: record.id,
        payload: {
          'type': 'area',
          'areaTotal': double.tryParse(_areaTotalController.text) ?? 0.0,
          'areaApp': double.tryParse(_areaAppController.text) ?? 0.0,
          'description': _descriptionAreaController.text,
          'address': _addressController.text,
          'forestType': _forestTypeController.text,
          'animals': _animalsController.text,
          'humanResources': _humanResourcesController.text,
          'otherResources': _otherResourcesController.text,
          'date': record.payload['date'],
        },
        createdAt: record.createdAt,
      );
      await _storageService.updateRecord(updated);
      _clearAreaInputs();
      _loadRecords();
    }
  }

  void _clearAreaInputs() {
    _areaTotalController.clear();
    _areaAppController.clear();
    _descriptionAreaController.clear();
    _addressController.clear();
    _forestTypeController.clear();
    _animalsController.clear();
    _humanResourcesController.clear();
    _otherResourcesController.clear();
  }

  Future<void> _saveActivity() async {
    if (_descController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Descrição é obrigatória!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ],
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    _pickedImage = File(picked.path);
    _currentPos = await _geoService.getUserLocation();

    final rec = OfflineRecord(
      id: DateTime.now().toIso8601String(),
      payload: {
        'type': 'activity',
        'description': _descController.text,
        'lat': _currentPos!.latitude,
        'lng': _currentPos!.longitude,
        'imagePath': _pickedImage!.path,
        'date': DateHelper.formatDate(DateTime.now()),
      },
      createdAt: DateTime.now(),
    );
    await _storageService.saveRecord(rec);
    _descController.clear();
    _pickedImage = null;
    _currentPos = null;
    _loadRecords();
  }

  int get _weeklyActivitiesCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _records
        .where((r) =>
    r.payload['type'] == 'activity' &&
        DateTime.parse(r.payload['date']).isAfter(weekAgo))
        .length;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _areaTotalController.dispose();
    _areaAppController.dispose();
    _descriptionAreaController.dispose();
    _addressController.dispose();
    _forestTypeController.dispose();
    _animalsController.dispose();
    _humanResourcesController.dispose();
    _otherResourcesController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Beneficiário'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Área Coberta'),
            Tab(text: 'Atividades'),
            Tab(text: 'Pagamentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === Área Coberta ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                CustomInput(label: 'Área Total (m²)', controller: _areaTotalController),
                const SizedBox(height: 12),
                CustomInput(label: 'Área APP (m²)', controller: _areaAppController),
                const SizedBox(height: 12),
                CustomInput(label: 'Descrição (opcional)', controller: _descriptionAreaController),
                const SizedBox(height: 12),
                CustomInput(label: 'Endereço', controller: _addressController),
                const SizedBox(height: 12),
                CustomInput(label: 'Tipo de Mata', controller: _forestTypeController),
                const SizedBox(height: 12),
                CustomInput(label: 'Animais na Região', controller: _animalsController),
                const SizedBox(height: 12),
                CustomInput(label: 'Recursos Humanos na Área', controller: _humanResourcesController),
                const SizedBox(height: 12),
                CustomInput(label: 'Outros Recursos (opcional)', controller: _otherResourcesController),
                const SizedBox(height: 20),
                CustomButton(label: 'Registrar Área', onPressed: _saveArea),
                const Divider(height: 40),
                const Text('Registros de Área:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._records
                    .where((r) => r.payload['type'] == 'area')
                    .map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Total: ${r.payload['areaTotal']} • APP: ${r.payload['areaApp']}'),
                    subtitle: Text('${r.payload['date']} • ${r.payload['address']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showEditAreaDialog(r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _storageService.deleteRecord(r.id);
                            _loadRecords();
                          },
                        ),
                      ],
                    ),
                  ),
                ))
                    .toList(),
                const SizedBox(height: 20),
                WhatsAppButton(
                  phone: '5574981256120',
                  message: 'Olá, preciso de ajuda com o PSA.',
                ),
              ],
            ),
          ),

          // === Atividades ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_weeklyActivitiesCount < 3)
                  Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Você registrou apenas $_weeklyActivitiesCount atividades na última semana. O mínimo exigido é 3.',
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                CustomInput(label: 'Descrição da Atividade *', controller: _descController),
                const SizedBox(height: 12),
                CustomButton(label: 'Tirar Foto e Registrar', onPressed: _saveActivity),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: _records
                        .where((r) => r.payload['type'] == 'activity')
                        .map((r) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Image.file(File(r.payload['imagePath']), width: 50, fit: BoxFit.cover),
                          title: Text(r.payload['description']),
                          subtitle: Text('Em ${r.payload['date']}'),
                          trailing: const Icon(Icons.location_on, color: Colors.green),
                        ),
                      );
                    })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // === Pagamentos ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: _payments.isEmpty
                ? const Center(child: Text('Nenhum pagamento registrado'))
                : ListView(
              children: _payments.map((p) {
                return ListTile(
                  leading: const Icon(Icons.payment_outlined, color: Colors.green),
                  title: Text(p.title),
                  subtitle: Text('${DateHelper.formatDate(p.date)} • Valor: R\$${p.id}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

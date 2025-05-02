// lib/screens/dashboard/dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/offline_record.dart';
import '../../models/report.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import '../../utils/date_helper.dart';

// widgets modulares
import 'filter_bar.dart';
import 'summary_cards.dart';
import 'activity_chart.dart';
import 'map_view.dart';
import 'export_buttons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storageService = LocalStorageService();
  final _reportService  = ReportService();

  List<OfflineRecord> _allRecords      = [];
  List<OfflineRecord> _filteredRecords = [];
  List<Report>       _payments         = [];

  String?        _searchName;
  String?        _selectedType;
  DateTimeRange? _selectedPeriod;

  final _mapController = Completer<GoogleMapController>();
  Set<Marker>   _markers       = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final recs = await _storageService.fetchQueue();
    final pays = await _reportService.fetchReports();
    setState(() {
      _allRecords      = recs;
      _payments        = pays;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredRecords = _allRecords.where((r) {
      final desc = (r.payload['description'] as String?)?.toLowerCase() ?? '';
      if (_searchName != null && _searchName!.isNotEmpty && !desc.contains(_searchName!.toLowerCase())) {
        return false;
      }
      if (_selectedType != null && _selectedType != 'Todos' && r.payload['type'] != _selectedType) {
        return false;
      }
      if (_selectedPeriod != null) {
        final d = DateTime.parse(r.payload['date'] as String);
        if (d.isBefore(_selectedPeriod!.start) || d.isAfter(_selectedPeriod!.end)) {
          return false;
        }
      }
      return true;
    }).toList();

    // atualiza marcadores do mapa
    _markers = _filteredRecords
        .where((r) => r.payload['type'] == 'activity')
        .map((r) => Marker(
      markerId: MarkerId(r.id),
      position: LatLng(
        r.payload['lat']  as double,
        r.payload['lng']  as double,
      ),
      infoWindow: InfoWindow(
        title:   r.payload['description'] as String? ?? '',
        snippet: r.payload['date']        as String? ?? '',
      ),
    ))
        .toSet();

    setState(() {});
  }

  Future<void> _exportCsv() async {
    final rows = <List<dynamic>>[
      ['Tipo', 'Descrição', 'Data', 'Valor']
    ];
    for (var r in _filteredRecords) {
      rows.add([
        r.payload['type'],
        r.payload['description'] ?? '',
        r.payload['date'],
        r.payload['areaPreserved'] ?? '',
      ]);
    }
    final csvString = const ListToCsvConverter().convert(rows);
    await Share.share(csvString, subject: 'dashboard.csv');
  }

  Future<void> _exportPdf() async {
    // prepara mesma tabela para PDF
    final rows = <List<dynamic>>[
      ['Tipo', 'Descrição', 'Data', 'Valor']
    ];
    for (var r in _filteredRecords) {
      rows.add([
        r.payload['type'],
        r.payload['description'] ?? '',
        r.payload['date'],
        r.payload['areaPreserved'] ?? '',
      ]);
    }
    final tableData = rows.skip(1).map((r) => r.map((e) => e.toString()).toList()).toList();

    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Monitoramento', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 12),
          pw.Text('Período: ' +
              (_selectedPeriod != null
                  ? '${DateHelper.formatDate(_selectedPeriod!.start)} – ${DateHelper.formatDate(_selectedPeriod!.end)}'
                  : 'Todos')),
          pw.SizedBox(height: 8),
          pw.Text('Tipo: ${_selectedType ?? 'Todos'}'),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: rows.first.map((h) => h.toString()).toList(),
            data: tableData,
          ),
        ],
      );
    }));
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'dashboard.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          // barra de filtros
          FilterBar(
            searchName:    _searchName,
            selectedType:  _selectedType,
            selectedPeriod:_selectedPeriod,
            onSearchChanged: (v) => setState(() {
              _searchName = v;
              _applyFilters();
            }),
            onTypeChanged: (v) => setState(() {
              _selectedType = v;
              _applyFilters();
            }),
            onPeriodChanged: (v) => setState(() {
              _selectedPeriod = v;
              _applyFilters();
            }),
          ),

          // conteúdo principal
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                SummaryCards(records: _filteredRecords, payments: _payments),
                const SizedBox(height: 16),
                ActivityChart(records: _filteredRecords),
                const SizedBox(height: 16),
                MapView(controller: _mapController, markers: _markers),
                const SizedBox(height: 16),
                ExportButtons(onCsv: _exportCsv, onPdf: _exportPdf),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

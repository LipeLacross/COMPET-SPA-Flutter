// lib/screens/dashboard/dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/offline_record.dart';
import '../../models/report.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import '../../utils/date_helper.dart';
import 'map_view.dart';
import 'filter_bar.dart';
import 'summary_cards.dart';
import 'activity_chart.dart';
import 'export_buttons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storageService = LocalStorageService();
  final _reportService  = ReportService();

  List<OfflineRecord> _allRecords      = [];
  List<OfflineRecord> _filteredRecords = [];
  List<Report>       _payments         = [];
  int                _beneficiaryCount = 0;
  bool               _showOnlyBeneficiaries = false;

  String?        _searchName;
  String?        _selectedType;
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBeneficiaryCount();
  }

  Future<void> _loadData() async {
    try {
      final recs = await _storageService.fetchQueue();
      final pays = await _reportService.fetchReports();
      if (!mounted) return;
      setState(() {
        _allRecords = recs;
        _payments   = pays;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _loadBeneficiaryCount() async {
    try {
      final count = await _reportService.fetchBeneficiaryCount();
      if (!mounted) return;
      setState(() => _beneficiaryCount = count);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter contagem de beneficiários: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredRecords = _allRecords.where((r) {
      final desc = (r.payload['description'] as String?)?.toLowerCase() ?? '';
      if (_searchName != null && _searchName!.isNotEmpty &&
          !desc.contains(_searchName!.toLowerCase())) {
        return false;
      }
      if (_selectedType != null && _selectedType != 'Todos' &&
          r.payload['type'] != _selectedType) {
        return false;
      }
      if (_selectedPeriod != null) {
        final d = DateTime.parse(r.payload['date'] as String);
        if (d.isBefore(_selectedPeriod!.start) ||
            d.isAfter(_selectedPeriod!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Monta as linhas de dados para exportação CSV/PDF.
  List<List<dynamic>> _buildReportRows() {
    return <List<dynamic>>[
      ['Tipo', 'Descrição', 'Data', 'Valor'],
      ..._filteredRecords.map((r) => [
        r.payload['type'],
        r.payload['description'] ?? '',
        r.payload['date'],
        r.payload['areaPreserved'] ?? '',
      ]),
    ];
  }

  Future<void> _exportCsv() async {
    final rows = _buildReportRows();
    final csvString = const ListToCsvConverter().convert(rows);
    await Share.share(csvString, subject: 'dashboard.csv');
  }

  Future<void> _exportPdf() async {
    final rows = _buildReportRows();
    final tableData = rows.skip(1).map((r) => r.map((e) => e.toString()).toList()).toList();

    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Monitoramento', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 12),
          pw.Text(
              _selectedPeriod != null
                  ? 'Período: ${DateHelper.formatDate(_selectedPeriod!.start)} – ${DateHelper.formatDate(_selectedPeriod!.end)}'
                  : 'Período: Todos'
          ),
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
          FilterBar(
            searchName:            _searchName,
            selectedType:          _selectedType,
            selectedPeriod:        _selectedPeriod,
            showOnlyBeneficiaries: _showOnlyBeneficiaries,
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
            onBeneficiaryToggle: (val) => setState(() {
              _showOnlyBeneficiaries = val;
            }),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                SummaryCards(
                  records:          _filteredRecords,
                  payments:         _payments,
                  beneficiaryCount: _beneficiaryCount,
                ),
                const SizedBox(height: 16),
                ActivityChart(records: _filteredRecords),
                const SizedBox(height: 16),
                MapView(showOnlyBeneficiaries: _showOnlyBeneficiaries),
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

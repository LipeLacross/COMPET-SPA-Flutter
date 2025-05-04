// lib/screens/dashboard/dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/offline_record.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import '../../utils/date_helper.dart';
import 'map_view.dart';
import 'filter_bar.dart';
import 'summary_cards.dart';
import 'activity_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storageService = LocalStorageService();
  final _reportService = ReportService();

  List<OfflineRecord> _allRecords = [];
  List<OfflineRecord> _filteredRecords = [];
  int _beneficiaryCount = 0;
  bool _showOnlyBeneficiaries = false;

  String? _searchText;
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  Future<void> _reloadAll() async {
    await Future.wait([_loadData(), _loadBeneficiaryCount()]);
  }

  Future<void> _loadData() async {
    try {
      final recs = await _storageService.fetchQueue();
      if (!mounted) return;
      setState(() {
        _allRecords = recs;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) _showError('Erro ao carregar dados', e);
    }
  }

  Future<void> _loadBeneficiaryCount() async {
    try {
      final count = await _reportService.fetchBeneficiaryCount();
      if (!mounted) return;
      setState(() => _beneficiaryCount = count);
    } catch (e) {
      if (mounted) _showError('Erro ao obter contagem de beneficiários', e);
    }
  }

  void _showError(String title, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $e')),
    );
  }

  void _applyFilters() {
    _filteredRecords = _allRecords.where((r) {
      final desc = (r.payload['description'] as String?)?.toLowerCase() ?? '';
      if (!(_searchText?.isEmpty ?? true) &&
          !desc.contains(_searchText!.toLowerCase())) return false;
      if (_selectedPeriod != null) {
        final d = DateTime.parse(r.payload['date'] as String);
        if (d.isBefore(_selectedPeriod!.start) ||
            d.isAfter(_selectedPeriod!.end)) return false;
      }
      return true;
    }).toList();
  }

  List<List<dynamic>> _buildCsvRows() => [
    ['Tipo', 'Descrição', 'Data', 'Valor'],
    ..._filteredRecords.map((r) => [
      r.payload['type'],
      r.payload['description'] ?? '',
      r.payload['date'],
      r.payload['areaPreserved'] ?? '',
    ]),
  ];

  Future<void> _exportCsv() async {
    final rows = _buildCsvRows();
    final csv = const ListToCsvConverter().convert(rows);
    await Share.share(csv, subject: 'dashboard.csv');
  }

  Future<void> _exportPdf() async {
    final rows = _buildCsvRows();
    final data =
    rows.skip(1).map((r) => r.map((e) => e.toString()).toList()).toList();
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório de Monitoramento',
              style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 8),
          pw.Text(_selectedPeriod != null
              ? 'Período: ${DateHelper.formatDate(_selectedPeriod!.start)} – ${DateHelper.formatDate(_selectedPeriod!.end)}'
              : 'Período: Todos'),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: rows.first.map((h) => h.toString()).toList(),
            data: data,
          ),
        ],
      );
    }));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'dashboard.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadAll,
            tooltip: 'Recarregar',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportCsv,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAll,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FilterBar(
                  searchText: _searchText,
                  selectedPeriod: _selectedPeriod,
                  showOnlyBeneficiaries: _showOnlyBeneficiaries,
                  onSearchChanged: (v) =>
                      setState(() { _searchText = v; _applyFilters(); }),
                  onPeriodChanged: (pr) =>
                      setState(() { _selectedPeriod = pr; _applyFilters(); }),
                  onBeneficiaryToggle: (val) =>
                      setState(() => _showOnlyBeneficiaries = val),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              sliver: SliverToBoxAdapter(
                child: SummaryCards(
                  records: _filteredRecords,
                  beneficiaryCount: _beneficiaryCount,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ActivityChart(records: _filteredRecords),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MapView(showOnlyBeneficiaries: _showOnlyBeneficiaries),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/dashboard/dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/offline_record.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import 'map_view.dart';
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAll,
        child: CustomScrollView(
          slivers: [
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
                child: MapView(showOnlyBeneficiaries: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

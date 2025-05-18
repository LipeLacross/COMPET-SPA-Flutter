import 'package:flutter/material.dart';
import 'summary_cards.dart';
import 'activity_chart.dart';
import '../../models/offline_record.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import 'map_view.dart'; // Importando a tela de mapa

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _storageService = LocalStorageService();
  final _reportService = ReportService();

  List<OfflineRecord> _allRecords = [];
  int _beneficiaryCount = 0;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  Future<void> _reloadAll() async {
    final recs = await _storageService.fetchQueue();
    final count = await _reportService.fetchBeneficiaryCount();
    if (!mounted) return;
    setState(() {
      _allRecords = recs;
      _beneficiaryCount = count;
    });
  }

  // Função que invoca a tela de MapView
  void _navigateToMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapView(),  // Navega para o MapView
      ),
    );
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
          ),
          IconButton(
            icon: const Icon(Icons.map),  // Ícone do mapa
            onPressed: _navigateToMapView,  // Chama a função para abrir o mapa
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAll,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SummaryCards(
                records: _allRecords,
                beneficiaryCount: _beneficiaryCount,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ActivityChart(records: _allRecords),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

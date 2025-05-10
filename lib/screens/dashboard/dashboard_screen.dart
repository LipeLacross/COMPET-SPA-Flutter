import 'package:flutter/material.dart';
import 'embedded_dashboard.dart';
import 'summary_cards.dart';
import 'activity_chart.dart';
import '../../models/offline_record.dart';
import '../../services/local_storage_service.dart';
import '../../services/report_service.dart';
import 'dart:io';
import 'map_view.dart'; // Importando a tela de mapa

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _storageService = LocalStorageService();
  final _reportService  = ReportService();

  List<OfflineRecord> _allRecords = [];
  int _beneficiaryCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Alterado para 3 abas
    _reloadAll();
  }

  Future<void> _reloadAll() async {
    final recs  = await _storageService.fetchQueue();
    final count = await _reportService.fetchBeneficiaryCount();
    if (!mounted) return;
    setState(() {
      _allRecords      = recs;
      _beneficiaryCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo'),  // Resumo
            Tab(text: 'SEMAS-PE'), // Dashboard SEMAS-PE
            Tab(text: 'Mapa'),     // Novo Tab para o Mapa
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reloadAll),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Resumo com cartões e gráfico
          RefreshIndicator(
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

          // Aba 2: Dashboard SEMAS-PE (Power BI, GeoNode, etc)
          const EmbeddedDashboard(
            dashboardUrl: 'https://app.powerbi.com/view?r=seuRelatorioEmbed',
            title: 'Painel SEMAS-PE',
          ),

          // Aba 3: Mapa - Visualização com pontos dos Beneficiários
          const MapView(),  // A aba de Mapa que exibe os beneficiários no mapa
        ],
      ),
    );
  }
}
|-- embedded_dashboard.dart
Content:
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Um widget que recebe a [dashboardUrl] e exibe em WebView.
/// Se precisar de token, ajuste headers ou injete via JS postMessage.
class EmbeddedDashboard extends StatefulWidget {
  final String dashboardUrl;
  final String? title;

  const EmbeddedDashboard({
    super.key,
    required this.dashboardUrl,
    this.title,
  });

  @override
  State<EmbeddedDashboard> createState() => _EmbeddedDashboardState();
}

class _EmbeddedDashboardState extends State<EmbeddedDashboard> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller e configura callbacks se precisar injetar token
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.dashboardUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge,  // Mudança aqui para titleLarge
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}

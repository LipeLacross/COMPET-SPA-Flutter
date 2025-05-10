// lib/screens/beneficiary_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/offline_record.dart';
import '../../services/local_storage_service.dart';

/// Tela de detalhes de registro de área e atividades do beneficiário,
/// com mini-mapa, fotos, e exportação/compartilhamento.
class BeneficiaryDetailScreen extends StatefulWidget {
  final OfflineRecord record;
  const BeneficiaryDetailScreen({super.key, required this.record});

  @override
  State<BeneficiaryDetailScreen> createState() => _BeneficiaryDetailScreenState();
}

class _BeneficiaryDetailScreenState extends State<BeneficiaryDetailScreen> {
  final LocalStorageService _storage = LocalStorageService();
  List<OfflineRecord> _activities = [];
  late final Map<String, String> _items;

  @override
  void initState() {
    super.initState();
    _prepareItems();
    _loadActivities();
  }

  void _prepareItems() {
    final payload = widget.record.payload;
    _items = {
      'Data': payload['date'] as String? ?? '-',
      'Área Total (m²)': (payload['areaTotal'] as num?)?.toDouble().toStringAsFixed(2) ?? '-',
      'Área APP (m²)': (payload['areaApp'] as num?)?.toDouble().toStringAsFixed(2) ?? '-',
      'Descrição': payload['description'] as String? ?? '-',
      'Endereço': payload['address'] as String? ?? '-',
      'Tipo de Mata': payload['forestType'] as String? ?? '-',
      'Animais na Região': payload['animals'] as String? ?? '-',
      'Recursos Humanos': (payload['humanResources'] as int?)?.toString() ?? '0',
      'Outros Recursos': payload['otherResources'] as String? ?? '-',
    };
  }

  Future<void> _loadActivities() async {
    final all = await _storage.fetchQueue();
    setState(() {
      _activities = all.where((r) => r.payload['type'] == 'activity').toList();
    });
  }

  Future<void> _exportPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Detalhes da Área Registrada',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ..._items.entries.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('${e.key}:'), pw.Text(e.value)],
              ),
            )),
            if (_activities.isNotEmpty) pw.SizedBox(height: 12),
            if (_activities.isNotEmpty)
              pw.Text(
                'Fotos e Atividades',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ..._activities.map((act) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child: pw.Text('• ${act.payload['date']} – ${act.payload['description']}'),
            )),
          ],
        ),
      ),
    );
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'detalhes_area_${widget.record.id}.pdf',
    );
  }

  void _shareText() {
    final buffer = StringBuffer();
    buffer.writeln('Detalhes da Área Registrada:');
    _items.forEach((k, v) => buffer.writeln('$k: $v'));
    if (_activities.isNotEmpty) {
      buffer.writeln('\nAtividades:');
      for (var act in _activities) {
        buffer.writeln('- ${act.payload['date']}: ${act.payload['description']}');
      }
    }
    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    LatLng? center;
    if (_activities.isNotEmpty) {
      final lat = (_activities.first.payload['lat'] as num).toDouble();
      final lng = (_activities.first.payload['lng'] as num).toDouble();
      center = LatLng(lat, lng);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Área'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar texto',
            onPressed: _shareText,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (center != null)
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ..._items.entries.map((e) => _buildItem(context, e.key, e.value)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (_activities.isNotEmpty)
            Text(
              'Fotos e Relatos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          ..._activities.map((act) => _buildActivityItem(act)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActivityItem(OfflineRecord act) {
    final desc = act.payload['description'] as String? ?? '-';
    final date = act.payload['date'] as String? ?? '-';
    final imgPath = act.payload['imagePath'] as String?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (imgPath != null)
            Image.file(
              File(imgPath),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 4),
          Text(desc),
        ],
      ),
    );
  }
}
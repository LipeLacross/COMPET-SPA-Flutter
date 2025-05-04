// lib/screens/dashboard/map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/report_service.dart';

/// Exibe OSM + WMS do SICAR e marcadores de atividades/beneficiários
class MapView extends StatefulWidget {
  final bool showOnlyBeneficiaries;
  const MapView({Key? key, this.showOnlyBeneficiaries = false}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _reportService = ReportService();
  List<Marker> _activityMarkers = [];
  List<Marker> _benefMarkers    = [];

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final actGeo = await _reportService.fetchActivitiesGeoJson();
      final benGeo = await _reportService.fetchBeneficiariesGeoJson();
      setState(() {
        _activityMarkers = _parseGeoJson(actGeo, isBeneficiary: false);
        _benefMarkers    = _parseGeoJson(benGeo,    isBeneficiary: true);
      });
    } catch (e) {
      debugPrint('Erro ao carregar GeoJSON: $e');
    }
  }

  List<Marker> _parseGeoJson(Map<String, dynamic> geo, {required bool isBeneficiary}) {
    final features = (geo['features'] as List).cast<Map<String, dynamic>>();
    return features.map((feature) {
      final coords = (feature['geometry']['coordinates'] as List).cast<num>();
      final lat = coords[1].toDouble(), lon = coords[0].toDouble();
      final props = feature['properties'] as Map<String, dynamic>;

      return Marker(
        point: LatLng(lat, lon),
        width: 40,
        height: 40,
        // use child:, não builder:
        child: IconButton(
          icon: Icon(
            Icons.location_on,
            size: 32,
            color: isBeneficiary ? Colors.green : Colors.red,
          ),
          onPressed: () {
            if (isBeneficiary) _showBeneficiaryDetails(props);
            else               _showActivityDetails(props);
          },
        ),
      );
    }).toList();
  }

  void _showActivityDetails(Map<String, dynamic> props) {
    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Atividade: ${props['description'] ?? '—'}'),
    ));
  }

  Future<void> _showBeneficiaryDetails(Map<String, dynamic> props) async {
    final codImovel = props['cod_imovel'].toString();
    final mapUrl = 'https://seu-backend.com/maps/beneficiary/$codImovel';

    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(props['name'] ?? 'Sem nome',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (props['areaPreserved'] != null)
            Text('Área: ${props['areaPreserved']} m²'),
          const SizedBox(height: 12),
          Image.network(
            mapUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, prog) =>
            prog == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (ctx, e, st) =>
            const Center(child: Text('Não foi possível carregar o mapa.')),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.showOnlyBeneficiaries
        ? _benefMarkers
        : [..._activityMarkers, ..._benefMarkers];

    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-8.0476, -34.8770),
          initialZoom: 10.0,
        ),
        children: [
          // 1) Camada base OSM
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          // 2) WMS do SICAR
          TileLayer(
            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'https://geoserver.car.gov.br/geoserver/sicar/wms',
              layers: ['sicar:CAR_areas'],
              format: 'image/png',
              transparent: true,
            ),
          ),
          // 3) Marcadores
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

// lib/screens/dashboard/map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/report_service.dart';

/// Exibe camada WMS do GeoServer SICAR e marcadores de atividades/beneficiários
class MapView extends StatefulWidget {
  final bool showOnlyBeneficiaries;
  const MapView({Key? key, this.showOnlyBeneficiaries = false}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final ReportService _reportService = ReportService();

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
        _activityMarkers = _parseGeoJson(actGeo);
        _benefMarkers    = _parseGeoJson(benGeo);
      });
    } catch (_) {
      // tratar erro de fetch
    }
  }

  List<Marker> _parseGeoJson(Map<String, dynamic> geo) {
    final features = (geo['features'] as List).cast<Map<String, dynamic>>();
    return features.map<Marker>((feature) {
      final coords = (feature['geometry']['coordinates'] as List).cast<num>();
      final lon = coords[0].toDouble(), lat = coords[1].toDouble();
      final props = feature['properties'] as Map<String, dynamic>;

      return Marker(
        point: LatLng(lat, lon),
        width: 40,
        height: 40,
        // NOTE: agora é `child:` em vez de `builder:`
        child: IconButton(
          icon: const Icon(Icons.location_on, size: 32, color: Colors.red),
          onPressed: () => _showFeatureInfo(props),
        ),
      );
    }).toList();
  }

  void _showFeatureInfo(Map<String, dynamic> props) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              props['name'] ?? 'Sem nome',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (props['areaPreserved'] != null)
              Text('Área: ${props['areaPreserved']} m²'),
            if (props['serviceDescription'] != null)
              Text('Serviço: ${props['serviceDescription']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.showOnlyBeneficiaries
        ? _benefMarkers
        : [..._activityMarkers, ..._benefMarkers];

    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          // agora usa initialCenter / initialZoom
          initialCenter: LatLng(-8.0476, -34.8770),
          initialZoom: 10.0,
        ),
        // em vez de `layers: [...]`, usa `children: [...]`
        children: [
          TileLayer(
            // WMSOptions não existe: use WMSTileLayerOptions
            wmsOptions: WMSTileLayerOptions(
              baseUrl: 'https://geoserver.car.gov.br/geoserver/sicar/wms',
              layers: ['sicar:CAR_areas'],
              format: 'image/png',
              transparent: true,
            ),
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

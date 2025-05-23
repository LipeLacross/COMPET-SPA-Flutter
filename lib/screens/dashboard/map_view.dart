import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController mapController = MapController();

  // Lista de beneficiários com dados geoespaciais
  List<Map<String, dynamic>> beneficiaries = [];

  @override
  void initState() {
    super.initState();
    _fetchBeneficiariesData();
  }

  Future<void> _fetchBeneficiariesData() async {
    try {
      final response =
      await http.get(Uri.parse('https://seuservidor.com/api/beneficiaries'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          beneficiaries =
              data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Falha ao carregar dados dos beneficiários');
      }
    } catch (e) {
      print("Erro ao buscar dados dos beneficiários: $e");
    }
  }

  void _onMarkerTapped(Map<String, dynamic> beneficiary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(beneficiary['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                beneficiary['photoUrl'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text("Localização: ${beneficiary['latitude']}, ${beneficiary['longitude']}"),
              Text("Status: ${beneficiary['status']}"),
              Text("Relatório: ${beneficiary['report']}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiários no Mapa'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(-8.0476, -34.8770), // Coordenadas de Recife
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: beneficiaries.map((beneficiary) {
              return Marker(
                point: LatLng(
                  beneficiary['latitude'],
                  beneficiary['longitude'],
                ),
                width: 80.0,
                height: 80.0,
                child: GestureDetector(
                  onTap: () => _onMarkerTapped(beneficiary),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

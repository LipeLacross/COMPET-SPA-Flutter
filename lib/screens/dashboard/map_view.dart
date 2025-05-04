// lib/screens/dashboard/map_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final Completer<GoogleMapController> controller;
  final Set<Marker> markers;

  const MapView({super.key, required this.controller, required this.markers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(-8.05, -34.87), zoom: 10),
        markers: markers,
        myLocationEnabled: true,
        onMapCreated: (c) => controller.complete(c),
      ),
    );
  }
}

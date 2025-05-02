//geolocation_service.dart
import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<Position> getUserLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

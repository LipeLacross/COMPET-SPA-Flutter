// geolocation_service.dart
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart' as exifLib; // Para leitura dos metadados EXIF
import 'package:native_exif/native_exif.dart'; // Dependência adicionada via Git

class GeolocationService {
  // Função para obter a localização do usuário
  Future<Position?> getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permission denied');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Lê os metadados EXIF da imagem utilizando o pacote exif (somente leitura)
  Future<Map<String, exifLib.IfdTag>?> getExifData(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final data = await exifLib.readExifFromBytes(bytes);
    return data;
  }

  /// Obtém as coordenadas GPS a partir dos metadados EXIF
  Future<Map<String, double>?> getGpsCoordinates(File imageFile) async {
    final exifData = await getExifData(imageFile);
    if (exifData == null) return null;

    // Acessa os valores usando as chaves do mapa
    final latitudeTag = exifData['GPSLatitude'];
    final longitudeTag = exifData['GPSLongitude'];

    if (latitudeTag == null || longitudeTag == null) return null;

    // Converte os valores utilizando a propriedade 'printable'
    final latitude = _parseGpsData(latitudeTag.printable);
    final longitude = _parseGpsData(longitudeTag.printable);
    return {'latitude': latitude, 'longitude': longitude};
  }

  /// Converte uma string no formato "graus, minutos, segundos" para um valor double
  double _parseGpsData(String gpsString) {
    final gpsParts = gpsString
        .split(',')
        .map((e) => double.tryParse(e.trim()) ?? 0)
        .toList();
    return gpsParts[0] + gpsParts[1] / 60 + gpsParts[2] / 3600;
  }

  /// Salva a imagem com os dados EXIF atualizados usando o pacote native_exif.
  Future<void> saveImageWithExif(File imageFile) async {
    final currentPos = await getUserLocation();
    if (currentPos == null) return;

    // Abre o arquivo utilizando a API do pacote native_exif.
    // Verifique no README do pacote se a API permanece esta forma de uso.
    final exif = await Exif.fromPath(imageFile.path);

    await exif.writeAttribute("GPSLatitude", currentPos.latitude.toString());
    await exif.writeAttribute("GPSLongitude", currentPos.longitude.toString());
    await exif.writeAttribute(
        "GPSLatitudeRef", currentPos.latitude >= 0 ? "N" : "S");
    await exif.writeAttribute(
        "GPSLongitudeRef", currentPos.longitude >= 0 ? "E" : "W");

    // Fecha o objeto para aplicar as alterações no arquivo
    await exif.close();
  }
}

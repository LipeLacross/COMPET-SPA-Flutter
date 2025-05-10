import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import '../services/session_manager.dart';
import 'api_service.dart';
import 'dart:io';

class ReportService {
  final ApiService _apiService = ApiService();
  final SessionManager _sm = SessionManager();

  /// Busca lista de relatórios a partir da sua API interna.
  Future<List<Report>> fetchReports() async {
    final token = await _sm.getToken();
    final res = await http.get(
      Uri.parse('https://api.exemplo.com/reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List<dynamic>;
      return list.map((m) => Report.fromMap(m as Map<String, dynamic>)).toList();
    }
    throw Exception('Erro ao carregar relatórios');
  }

  /// Cria um novo relatório no backend.
  Future<void> createReport(Map<String, dynamic> reportData) async {
    final token = await _sm.getToken();
    final uri = Uri.parse('https://api.exemplo.com/reports');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(reportData),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar relatório');
    }
  }

  /// Cria um novo relatório no backend com foto e GPS
  Future<void> createReportWithPhoto(Map<String, dynamic> reportData, File imageFile) async {
    final token = await _sm.getToken();
    final path = 'reports/create_with_photo';  // Endpoint de criação de relatório com foto

    // Enviar dados e foto (também incluindo o GPS no payload)
    final response = await _apiService.postWithFile(
      path: path,
      data: reportData,
      file: imageFile,
      latitude: reportData['latitude'],
      longitude: reportData['longitude'],
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao criar relatório com foto');
    }
  }

  /// Atualiza um relatório existente na sua API interna.
  Future<void> updateReport(String id, Map<String, dynamic> reportData) async {
    final token = await _sm.getToken();
    final res = await http.put(
      Uri.parse('https://api.exemplo.com/reports/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(reportData),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao atualizar relatório');
    }
  }

  /// Número total de beneficiários (se você ainda usar esse endpoint FastAPI).
  Future<int> fetchBeneficiaryCount() async {
    final token = await _sm.getToken();
    final res = await http.get(
      Uri.parse('https://api.exemplo.com/beneficiaries/count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return data['count'] as int;
    }
    throw Exception('Erro ao obter contagem de beneficiários');
  }

  /// Helper genérico que chama o WFS e retorna um GeoJSON filtrado por cod_estado=26.
  Future<Map<String, dynamic>> _fetchGeoJson(String typeName) async {
    final uri = Uri.parse('https://suaapi.com/wfs').replace(queryParameters: {
      'service': 'WFS',
      'version': '1.1.0',
      'request': 'GetFeature',
      'typeName': typeName,
      'outputFormat': 'application/json',
      'cql_filter': 'cod_estado=26',
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Erro ao obter GeoJSON de $typeName');
  }

  /// GeoJSON dos **beneficiários** (CAR_areas) em Pernambuco
  Future<Map<String, dynamic>> fetchBeneficiariesGeoJson() {
    return _fetchGeoJson('sicar:CAR_areas');
  }

  /// GeoJSON das **atividades** (substitua pelo nome de camada correto no SICAR)
  Future<Map<String, dynamic>> fetchActivitiesGeoJson() {
    return _fetchGeoJson('sicar:CAR_activities');
  }
}

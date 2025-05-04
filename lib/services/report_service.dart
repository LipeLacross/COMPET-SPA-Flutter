// lib/services/report_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import '../services/session_manager.dart';

class ReportService {
  // URL base do WFS do GeoServer SICAR
  static const String _wfsBase = 'https://geoserver.car.gov.br/geoserver/sicar/wfs';
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
    // Monta a URL com os parâmetros padrão do WFS
    final uri = Uri.parse(_wfsBase).replace(queryParameters: {
      'service':      'WFS',
      'version':      '1.1.0',
      'request':      'GetFeature',
      'typeName':     typeName,
      'outputFormat': 'application/json',   // GeoJSON
      'cql_filter':   'cod_estado=26',       // Pernambuco
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Erro ao obter GeoJSON de $typeName (${res.statusCode})');
  }

  /// GeoJSON dos **beneficiários** (CAR_areas) em Pernambuco
  Future<Map<String, dynamic>> fetchBeneficiariesGeoJson() {
    return _fetchGeoJson('sicar:CAR_areas');
  }

  /// GeoJSON das **atividades** (substitua pelo nome de camada correto no SICAR)
  Future<Map<String, dynamic>> fetchActivitiesGeoJson() {
    return _fetchGeoJson('sicar:CAR_activities');
  }

  /// Cria um novo relatório na sua API interna.
  Future<void> createReport(Map<String, dynamic> reportData) async {
    final token = await _sm.getToken();
    final res = await http.post(
      Uri.parse('https://api.exemplo.com/reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      body: json.encode(reportData),
    );
    if (res.statusCode != 201) {
      throw Exception('Erro ao criar relatório');
    }
  }

  /// Atualiza um relatório existente na sua API interna.
  Future<void> updateReport(String id, Map<String, dynamic> reportData) async {
    final token = await _sm.getToken();
    final res = await http.put(
      Uri.parse('https://api.exemplo.com/reports/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      body: json.encode(reportData),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao atualizar relatório');
    }
  }
}

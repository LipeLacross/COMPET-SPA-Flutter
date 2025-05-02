// report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import '../services/session_manager.dart';

class ReportService {
  final String _baseUrl = 'https://api.exemplo.com/reports';
  final SessionManager _sm = SessionManager();

  /// Busca lista de relatórios a partir da API.
  Future<List<Report>> fetchReports() async {
    final token = await _sm.getToken();
    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      return list.map((m) => Report.fromMap(m)).toList();
    } else {
      throw Exception('Erro ao carregar relatórios');
    }
  }
}


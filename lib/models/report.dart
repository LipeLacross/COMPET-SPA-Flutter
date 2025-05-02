//report.dart
class Report {
  final String id;
  final String title;
  final DateTime date;
  final String url; // link para download ou visualização

  Report({
    required this.id,
    required this.title,
    required this.date,
    required this.url,
  });

  factory Report.fromMap(Map<String, dynamic> m) => Report(
    id: m['id'] as String,
    title: m['title'] as String,
    date: DateTime.parse(m['date'] as String),
    url: m['url'] as String,
  );
}


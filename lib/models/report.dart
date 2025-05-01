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
    id: m['id'],
    title: m['title'],
    date: DateTime.parse(m['date']),
    url: m['url'],
  );
}

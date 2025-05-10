// report.dart
class Report {
  final String id;
  final String title;
  final DateTime date;
  final String url;

  Report({
    required this.id,
    required this.title,
    required this.date,
    required this.url,
  });

  // Método para converter o objeto Report em Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(), // Convertendo para ISO8601
      'url': url,
    };
  }

  // Método para criar um objeto Report a partir de um Map
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']), // Convertendo de volta para DateTime
      url: map['url'] ?? '',
    );
  }
}
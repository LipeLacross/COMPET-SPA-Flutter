class Activity {
  final String type;
  final DateTime date;
  final double areaPreserved;

  Activity({
    required this.type,
    required this.date,
    required this.areaPreserved,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'date': date.toIso8601String(),
      'areaPreserved': areaPreserved,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      type: map['type'],
      date: DateTime.parse(map['date']),
      areaPreserved: map['areaPreserved'],
    );
  }
}
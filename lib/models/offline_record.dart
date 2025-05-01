class OfflineRecord {
  final String id;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  OfflineRecord({
    required this.id,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfflineRecord.fromMap(Map<String, dynamic> m) => OfflineRecord(
    id: m['id'],
    payload: Map<String, dynamic>.from(m['payload']),
    createdAt: DateTime.parse(m['createdAt']),
  );
}

// lib/models/offline_record.dart
class OfflineRecord {
  final String id;
  final Map<String, dynamic> payload;
  DateTime createdAt;  // Now mutable
  String? imagePath;   // Changed from final to allow assignment
  final Map<String, dynamic>? exifData;

  // New properties added for beneficiary data
  final String beneficiaryId;
  final String beneficiaryName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String report;
  final String status;

  // Updated constructor to include beneficiaryId, beneficiaryName, etc.
  OfflineRecord({
    required this.id,
    required this.payload,
    required this.createdAt,
    required this.beneficiaryId,    // Added beneficiaryId
    required this.beneficiaryName,  // Added beneficiaryName
    required this.latitude,         // Added latitude
    required this.longitude,        // Added longitude
    required this.timestamp,        // Added timestamp
    required this.report,           // Added report
    required this.status,           // Added status
    this.imagePath,                 // Image path (optional)
    this.exifData,                  // EXIF metadata (optional)
  });

  // toMap method updated to include new properties
  Map<String, dynamic> toMap() => {
    'id': id,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'beneficiaryId': beneficiaryId,  // Added beneficiaryId
    'beneficiaryName': beneficiaryName,  // Added beneficiaryName
    'latitude': latitude,  // Added latitude
    'longitude': longitude, // Added longitude
    'timestamp': timestamp.toIso8601String(), // Added timestamp
    'report': report,  // Added report
    'status': status,  // Added status
    'imagePath': imagePath, // Includes image path, if present
    'exifData': exifData,   // Includes EXIF data, if present
  };

  // Factory to create instance from a map, now including new properties
  factory OfflineRecord.fromMap(Map<String, dynamic> m) => OfflineRecord(
    id: m['id'] as String,
    payload: Map<String, dynamic>.from(m['payload'] as Map),
    createdAt: DateTime.parse(m['createdAt'] as String),
    beneficiaryId: m['beneficiaryId'] as String, // Now receives beneficiaryId
    beneficiaryName: m['beneficiaryName'] as String, // Now receives beneficiaryName
    latitude: m['latitude'] as double, // Now receives latitude
    longitude: m['longitude'] as double, // Now receives longitude
    timestamp: DateTime.parse(m['timestamp'] as String), // Now receives timestamp
    report: m['report'] as String, // Now receives report
    status: m['status'] as String, // Now receives status
    imagePath: m['imagePath'] as String?, // Receives image path
    exifData: m['exifData'] != null
        ? Map<String, dynamic>.from(m['exifData'] as Map)
        : null, // Receives EXIF data, if present
  );

  // Optionally, you can create a copyWith method for immutability if needed
  OfflineRecord copyWith({
    DateTime? createdAt,
    String? imagePath,
    Map<String, dynamic>? exifData,
    String? beneficiaryId,
    String? beneficiaryName,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? report,
    String? status,
  }) {
    return OfflineRecord(
      id: id,
      payload: payload,
      createdAt: createdAt ?? this.createdAt,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      report: report ?? this.report,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      exifData: exifData ?? this.exifData,
    );
  }
}
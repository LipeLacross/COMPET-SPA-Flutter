class Beneficiary {
  final String name;
  final double areaPreserved;
  final String serviceDescription;

  Beneficiary({
    required this.name,
    required this.areaPreserved,
    required this.serviceDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'areaPreserved': areaPreserved,
      'serviceDescription': serviceDescription,
    };
  }

  factory Beneficiary.fromMap(Map<String, dynamic> map) {
    return Beneficiary(
      name: map['name'],
      areaPreserved: map['areaPreserved'],
      serviceDescription: map['serviceDescription'],
    );
  }
}

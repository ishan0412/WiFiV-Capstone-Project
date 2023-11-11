class Pump {
  final int id;
  final String ipAddress;
  // String drugName; // ? should this be final?
  // double currentRate;
  // double currentVtbi;
  // List<PumpChangeEntry> pumpChangeLog;

  const Pump({required this.id, required this.ipAddress
      // , required this.drugName
      });

  Map<String, dynamic> toMap() {
    return {'id': id, 'ipAddress': ipAddress};
  }

  @override
  String toString() {
    return 'Pump{id: $id, ipAddress: $ipAddress}';
  }

  static Pump fromMap(Map<String, dynamic> pumpAsMap) {
    return Pump(
        id: pumpAsMap['id'] as int,
        ipAddress: pumpAsMap['ipAddress'] as String);
  }
}

// class PumpChangeEntry {
//   final String updatedDrugName;
//   final double updatedRate;
//   final double updatedVtbi;
// }

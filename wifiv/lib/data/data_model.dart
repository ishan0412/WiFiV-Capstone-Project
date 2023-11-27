import 'dart:convert';

class Pump {
  final int id;
  final String ipAddress;
  final String drugName;
  String patientName;
  double currentRate;
  double currentVtbi;
  List<PumpChangeEntry> pumpChangeLog;

  Pump(
      {required this.id,
      required this.ipAddress,
      required this.drugName,
      required this.patientName,
      this.currentRate = 0,
      this.currentVtbi = 0,
      List<PumpChangeEntry>? pumpChangeLog})
      : pumpChangeLog = pumpChangeLog ?? [];

  Pump changeRate(double updatedRate) {
    DateTime timestamp = DateTime.now();
    pumpChangeLog.add(PumpChangeEntry(
        dateOfChange: dateStringFromTimestamp(timestamp),
        timeOfChange: timeStringFromTimestamp(timestamp),
        updatedRate: updatedRate,
        updatedVtbi: currentVtbi));
    return Pump(
        id: id,
        ipAddress: ipAddress,
        drugName: drugName,
        patientName: patientName,
        currentRate: updatedRate,
        currentVtbi: currentVtbi,
        pumpChangeLog: pumpChangeLog);
  }

  Pump changeVtbi(double updatedVtbi) {
    DateTime timestamp = DateTime.now();
    pumpChangeLog.add(PumpChangeEntry(
        dateOfChange: dateStringFromTimestamp(timestamp),
        timeOfChange: timeStringFromTimestamp(timestamp),
        updatedRate: currentRate,
        updatedVtbi: updatedVtbi));
    return Pump(
        id: id,
        ipAddress: ipAddress,
        drugName: drugName,
        patientName: patientName,
        currentRate: currentRate,
        currentVtbi: updatedVtbi,
        pumpChangeLog: pumpChangeLog);
  }

  Pump renamePatientOnPump(String updatedName) {
    return Pump(
        id: id,
        ipAddress: ipAddress,
        drugName: drugName,
        patientName: updatedName,
        currentRate: currentRate,
        currentVtbi: currentVtbi,
        pumpChangeLog: pumpChangeLog);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ipAddress': ipAddress,
      'drugName': drugName,
      'patientName': patientName,
      'currentRate': currentRate,
      'currentVtbi': currentVtbi,
      'pumpChangeLog': jsonEncode(pumpChangeLog.map((e) => e.toJson()).toList())
    };
  }

  static String dateStringFromTimestamp(DateTime timestamp) {
    return '${timestamp.month}-${timestamp.day}-${timestamp.year}';
  }

  static String timeStringFromTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute}';
  }

  @override
  String toString() {
    return 'Pump${toMap()}';
  }

  bool equals(Pump otherPump) {
    return (id == otherPump.id);
  }

  static Pump fromMap(Map<String, dynamic> pumpAsMap) {
    return Pump(
        id: pumpAsMap['id'] as int,
        ipAddress: pumpAsMap['ipAddress'] as String,
        drugName: pumpAsMap['drugName'] as String,
        patientName: pumpAsMap['patientName'] as String,
        currentRate: pumpAsMap['currentRate'] as double,
        currentVtbi: pumpAsMap['currentVtbi'] as double,
        pumpChangeLog: (pumpAsMap['pumpChangeLog'] != null)
            ? [
                for (Map<String, dynamic> e
                    in jsonDecode(pumpAsMap['pumpChangeLog']))
                  PumpChangeEntry.fromJson(e)
              ]
            : []);
  }
}

class PumpChangeEntry {
  final String dateOfChange;
  final String timeOfChange;
  // final String updatedDrugName;
  final double updatedRate;
  final double updatedVtbi;

  PumpChangeEntry(
      {required this.dateOfChange,
      required this.timeOfChange,
      // required this.updatedDrugName,
      required this.updatedRate,
      required this.updatedVtbi});

  @override
  String toString() {
    return 'PumpChange${toJson()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'dateOfChange': dateOfChange,
      'timeOfChange': timeOfChange,
      'updatedRate': updatedRate,
      'updatedVtbi': updatedVtbi
    };
  }

  static PumpChangeEntry fromJson(Map<String, dynamic> entryAsMap) {
    return PumpChangeEntry(
        dateOfChange: entryAsMap['dateOfChange'],
        timeOfChange: entryAsMap['timeOfChange'],
        updatedRate: entryAsMap['updatedRate'],
        updatedVtbi: entryAsMap['updatedVtbi']);
  }
}

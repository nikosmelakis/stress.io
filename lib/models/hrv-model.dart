class HrvModel {
  late List<DateTime?> dateTime;
  late List<double?> hrv;

  HrvModel(
    this.dateTime,
    this.hrv,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'dateTime': dateTime,
      'hrv': hrv,
    };
    return map;
  }

  HrvModel.fromMap(Map<String, dynamic> map) {
    dateTime = List<DateTime?>.from(map['dateTime']);
    hrv = List<double?>.from(map['hrv']);
  }
}

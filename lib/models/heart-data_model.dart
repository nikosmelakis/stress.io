int days = 365;

class HeartModel {
  late List<int?> restingHeartRate;

  HeartModel(
    this.restingHeartRate,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'restingHeartRate': restingHeartRate,
    };
    return map;
  }

  HeartModel.fromMap(Map<String, dynamic> map) {
    restingHeartRate = List<int?>.from(map['restingHeartRate']);
  }
}

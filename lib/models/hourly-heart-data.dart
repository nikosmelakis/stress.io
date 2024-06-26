int minutes = 1440;

class PerMinHeartModel {
  late List<DateTime?> dailyHeartHour;
  late List<double?> dailyHeartRate;

  PerMinHeartModel(
    this.dailyHeartHour,
    this.dailyHeartRate,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'dailyHeartHour': dailyHeartHour,
      'dailyHeartRate': dailyHeartRate,
    };
    return map;
  }

  PerMinHeartModel.fromMap(Map<String, dynamic> map) {
    dailyHeartHour = List<DateTime?>.from(map['dailyHeartHour']);
    dailyHeartRate = List<double?>.from(map['dailyHeartRate']);
  }
}

class ActivityModel {
  late List<DateTime?> dateTime;
  late List<double?> caloriesValue;
  late List<double?> distanceValue;
  late List<double?> floorsValue;
  late List<double?> exerciseValue;
  late List<double?> standValue;
  late List<double?> stepsValue;

  ActivityModel(
    this.dateTime,
    this.caloriesValue,
    this.distanceValue,
    this.floorsValue,
    this.exerciseValue,
    this.standValue,
    this.stepsValue,
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'dateTime': dateTime,
      'caloriesValue': caloriesValue,
      'distanceValue': distanceValue,
      'floorsValue': floorsValue,
      'exerciseValue': exerciseValue,
      'standValue': standValue,
      'stepsValue': stepsValue,
    };
    return map;
  }

  ActivityModel.fromMap(Map<String, dynamic> map) {
    dateTime = List<DateTime?>.from(map['dateTime']);
    caloriesValue = List<double?>.from(map['caloriesValue']);
    distanceValue = List<double?>.from(map['distanceValue']);
    floorsValue = List<double?>.from(map['floorsValue']);
    exerciseValue = List<double?>.from(map['exerciseValue']);
    standValue = List<double?>.from(map['standValue']);
    stepsValue = List<double?>.from(map['stepsValue']);
  }
}

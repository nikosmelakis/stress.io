import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

//!--//
//Acitivy Ring Widget
class ActivityRing extends StatefulWidget {
  const ActivityRing({Key? key}) : super(key: key);

  @override
  State<ActivityRing> createState() => _ActivityRingState();
}

class _ActivityRingState extends State<ActivityRing> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  double calories = 0;
  double exercise = 0;
  double stand = 0;

  @override
  void initState() {
    super.initState();
    getActivityData();
  }

  Future<void> getActivityData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      calories = _activityData.getDouble("caloriesValue_${364}_${0}") ?? 0;
      exercise = _activityData.getDouble("exerciseValue_${364}_${0}") ?? 0;
      stand = _activityData.getDouble("standValue_${364}_${0}") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    int tempCalories = calories.toInt();
    int tempExercise = exercise.toInt();
    int tempStand = stand.toInt();

    double tempC = tempCalories / 50;
    int finalCalories = tempC.toInt();

    double tempE = tempExercise / 2;
    int finalExercise = tempE.toInt();

    double tempS = tempStand / 200;
    int finalStand = tempS.toInt();

    final List<RingData> ringData = [
      RingData('↥', finalStand, kBlueRingColor),
      RingData('⇥', finalExercise, kGreenRingColor),
      RingData('↦', finalCalories, kRedRingColor),
    ];
    return Container(
      width: 90.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: kOtherColor,
        borderRadius: BorderRadius.circular(kDefaultPadding * 2),
      ),
      child: SfCircularChart(
        series: <CircularSeries>[
          // Renders radial bar chart
          RadialBarSeries<RingData, String>(
            animationDelay: 100,
            animationDuration: 2500,
            useSeriesColor: true,
            trackOpacity: 0.5,
            cornerStyle: CornerStyle.bothCurve,
            pointColorMapper: (RingData data, _) => data.color,
            dataSource: ringData,
            xValueMapper: (RingData data, _) => data.x,
            yValueMapper: (RingData data, _) => data.y,
            dataLabelMapper: (RingData data, _) => '${data.x}',
            maximumValue: 8,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                  color: kTextBlackColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}

class RingData {
  RingData(this.x, this.y, this.color);
  final String x;
  final int y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//Move Panel
class MoveNum extends StatelessWidget {
  const MoveNum({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 7.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 28,
                  color: kRedRingColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//!--//
//Weekly Move Chart
class WeeklyMoveChart extends StatefulWidget {
  const WeeklyMoveChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyMoveChart> createState() => _WeeklyMoveChartState();
}

class _WeeklyMoveChartState extends State<WeeklyMoveChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> caloriesValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 weeks of calories
        double? caloriesValue =
            _activityData.getDouble("caloriesValue_${i}_${0}") ?? 0;
        caloriesValues[i] = caloriesValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }

    List<WeeklyMoveData> weeklyMoveData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyMoveData.add(
          WeeklyMoveData(finalDates[i], caloriesValues[index], kRedRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyMoveData, String>(
              name: "KCLA",
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyMoveData,
              xValueMapper: (WeeklyMoveData data, String) => data.x,
              yValueMapper: (WeeklyMoveData data, _) => data.y,
              pointColorMapper: (WeeklyMoveData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyMoveData {
  WeeklyMoveData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//Monthly Move Chart
class MontlhyMoveChart extends StatefulWidget {
  const MontlhyMoveChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MontlhyMoveChart> createState() => _MontlhyMoveChartState();
}

class _MontlhyMoveChartState extends State<MontlhyMoveChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> caloriesValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 month of calories
        double? caloriesValue =
            _activityData.getDouble("caloriesValue_${i}_${0}") ?? 0;
        caloriesValues[i] = caloriesValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }

    List<MontlhyMoveData> montlhyMoveData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      montlhyMoveData.add(MontlhyMoveData(
          finalDates[temp], caloriesValues[index], kRedRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MontlhyMoveData, String>(
              name: 'KCLA',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: montlhyMoveData,
              xValueMapper: (MontlhyMoveData data, String) => data.x,
              yValueMapper: (MontlhyMoveData data, _) => data.y,
              pointColorMapper: (MontlhyMoveData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MontlhyMoveData {
  MontlhyMoveData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//Six Months Move Chart
class SMonthsMoveChart extends StatefulWidget {
  const SMonthsMoveChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsMoveChart> createState() => _SMonthsMoveChartState();
}

class _SMonthsMoveChartState extends State<SMonthsMoveChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> caloriesValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? caloriesValue =
              _activityData.getDouble("caloriesValue_${j}_${0}") ?? 0;

          if (caloriesValue != 0) {
            sum += caloriesValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsMoveData> sMonthsMoveData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsMoveData.add(SMonthsMoveData(
          finalDates[temp], monthlyAverages[index], kRedRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsMoveData, String>(
              name: 'KCLA',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsMoveData,
              xValueMapper: (SMonthsMoveData data, String) => data.x,
              yValueMapper: (SMonthsMoveData data, _) => data.y,
              pointColorMapper: (SMonthsMoveData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsMoveData {
  SMonthsMoveData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//Years Move Chart
class YearsMoveChart extends StatefulWidget {
  const YearsMoveChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearsMoveChart> createState() => _YearsMoveChartState();
}

class _YearsMoveChartState extends State<YearsMoveChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> caloriesValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year heart rates
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? caloriesValue =
              _activityData.getDouble("caloriesValue_${j}_${0}") ?? 0;

          if (caloriesValue != 0) {
            sum += caloriesValue;
            count++;
          }
        }

        double yaverage = count > 0 ? sum : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearsMoveData> yearsMoveData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearsMoveData.add(YearsMoveData(
          finalDates[temp], yearlyAverages[index], kRedRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearsMoveData, String>(
              name: 'KCLA',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearsMoveData,
              xValueMapper: (YearsMoveData data, String) => data.x,
              yValueMapper: (YearsMoveData data, _) => data.y,
              pointColorMapper: (YearsMoveData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearsMoveData {
  YearsMoveData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//!--//
//Exercise Panel
class ExerciseNum extends StatelessWidget {
  const ExerciseNum({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 7.h),
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 28,
                  color: kGreenRingColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//!--//
//Weekly Exercise Chart
class WeeklyExerciseChart extends StatefulWidget {
  const WeeklyExerciseChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyExerciseChart> createState() => _WeeklyExerciseChartState();
}

class _WeeklyExerciseChartState extends State<WeeklyExerciseChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 weeks of exercise time in minutes
        double? exerciseValue =
            _activityData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }

    List<WeeklyExerciseData> weeklyExerciseData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyExerciseData.add(WeeklyExerciseData(
          finalDates[i], exerciseValues[index]?.toInt(), kGreenRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyExerciseData, String>(
              name: 'MINS ',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyExerciseData,
              xValueMapper: (WeeklyExerciseData data, String) => data.x,
              yValueMapper: (WeeklyExerciseData data, _) => data.y,
              pointColorMapper: (WeeklyExerciseData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyExerciseData {
  WeeklyExerciseData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//!--//
//Monthly Exercise Chart
class MonthlyExerciseChart extends StatefulWidget {
  const MonthlyExerciseChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyExerciseChart> createState() => _MonthlyExerciseChartState();
}

class _MonthlyExerciseChartState extends State<MonthlyExerciseChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 month of exercise time in minutes
        double? exerciseValue =
            _activityData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }

    List<MonthlyExerciseData> monthlyExerciseData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      monthlyExerciseData.add(MonthlyExerciseData(
          finalDates[temp], exerciseValues[index]?.toInt(), kGreenRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyExerciseData, String>(
              name: 'MINS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyExerciseData,
              xValueMapper: (MonthlyExerciseData data, String) => data.x,
              yValueMapper: (MonthlyExerciseData data, _) => data.y,
              pointColorMapper: (MonthlyExerciseData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyExerciseData {
  MonthlyExerciseData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//!--//
//SMonths Exercise Chart
class SMonthsExerciseChart extends StatefulWidget {
  const SMonthsExerciseChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsExerciseChart> createState() => _SMonthsExerciseChartState();
}

class _SMonthsExerciseChartState extends State<SMonthsExerciseChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 6 months of exercise time in minutes
        double? exerciseValue =
            _activityData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? exerciseValue =
              _activityData.getDouble("exerciseValue_${j}_${0}") ?? 0;

          if (exerciseValue != 0) {
            sum += exerciseValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsExerciseData> sMonthsExerciseData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsExerciseData.add(SMonthsExerciseData(
          finalDates[temp], monthlyAverages[index]?.toInt(), kGreenRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsExerciseData, String>(
              name: 'MINS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsExerciseData,
              xValueMapper: (SMonthsExerciseData data, String) => data.x,
              yValueMapper: (SMonthsExerciseData data, _) => data.y,
              pointColorMapper: (SMonthsExerciseData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsExerciseData {
  SMonthsExerciseData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//!--//
//Years Exercise Chart
class YearsExerciseChart extends StatefulWidget {
  const YearsExerciseChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearsExerciseChart> createState() => _YearsExerciseChartState();
}

class _YearsExerciseChartState extends State<YearsExerciseChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> exerciseValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year exercise rates
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? exerciseValue =
              _activityData.getDouble("exerciseValue_${j}_${0}") ?? 0;

          if (exerciseValue != 0) {
            sum += exerciseValue;
            count++;
          }
        }

        double yaverage = count > 0 ? sum : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearsExerciseData> yearsExerciseData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearsExerciseData.add(YearsExerciseData(
          finalDates[temp], yearlyAverages[index]?.toInt(), kGreenRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearsExerciseData, String>(
              name: 'MINS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearsExerciseData,
              xValueMapper: (YearsExerciseData data, String) => data.x,
              yValueMapper: (YearsExerciseData data, _) => data.y,
              pointColorMapper: (YearsExerciseData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearsExerciseData {
  YearsExerciseData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//!--//
//Stand Panel
class StandNum extends StatelessWidget {
  const StandNum({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 7.h),
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 28,
                  color: kBlueRingColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//!--//
//Weekly Stand Chart
class WeeklyStandChart extends StatefulWidget {
  const WeeklyStandChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyStandChart> createState() => _WeeklyStandChartState();
}

class _WeeklyStandChartState extends State<WeeklyStandChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> standValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        // Getting 1 week of stand time in minutes
        double? standValue =
            _activityData.getDouble("standValue_${i}_${0}") ?? 0;
        standValues[i] = standValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }
    int? tempStand;
    int? weeklyStand;
    List<WeeklyStandData> weeklyStandData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      tempStand = standValues[index]?.toInt();
      if (standValues[index] != null) {
        weeklyStand = tempStand! ~/ 200;
      } else
        weeklyStand = 0;
      weeklyStandData
          .add(WeeklyStandData(finalDates[i], weeklyStand, kBlueRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyStandData, String>(
              name: 'HRS ',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyStandData,
              xValueMapper: (WeeklyStandData data, String) => data.x,
              yValueMapper: (WeeklyStandData data, _) => data.y,
              pointColorMapper: (WeeklyStandData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyStandData {
  WeeklyStandData(this.x, this.y, this.color);
  final String x;
  final int y;
  final Color color;
}

//!--//
//Monthly Stand Chart
class MonthlyStandChart extends StatefulWidget {
  const MonthlyStandChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyStandChart> createState() => _MonthlyStandChartState();
}

class _MonthlyStandChartState extends State<MonthlyStandChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> standValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        // Getting 1 month of stand time in minutes
        double? standValue =
            _activityData.getDouble("standValue_${i}_${0}") ?? 0;
        standValues[i] = standValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }
    int? tempStand;
    int? weeklyStand;
    List<MonthlyStandData> monthlyStandData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      tempStand = standValues[index]?.toInt();
      if (standValues[index] != null) {
        weeklyStand = tempStand! ~/ 200;
      } else
        weeklyStand = 0;
      monthlyStandData
          .add(MonthlyStandData(finalDates[temp], weeklyStand, kBlueRingColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyStandData, String>(
              name: 'HRS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyStandData,
              xValueMapper: (MonthlyStandData data, String) => data.x,
              yValueMapper: (MonthlyStandData data, _) => data.y,
              pointColorMapper: (MonthlyStandData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyStandData {
  MonthlyStandData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//!--//
//6 Months Stand Chart
class SMonthsStandChart extends StatefulWidget {
  const SMonthsStandChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsStandChart> createState() => _SMonthsStandChartState();
}

class _SMonthsStandChartState extends State<SMonthsStandChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> standValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 6 months of stand time in minutes
        double? standValue =
            _activityData.getDouble("standValue_${i}_${0}") ?? 0;
        standValues[i] = standValue;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? standValue =
              _activityData.getDouble("standValue_${j}_${0}") ?? 0;

          if (standValue != 0) {
            sum += standValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum / 300 : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsStandData> sMonthsStandData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsStandData.add(SMonthsStandData(
          finalDates[temp], monthlyAverages[index]?.toInt(), kBlueRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsStandData, String>(
              name: 'HRS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsStandData,
              xValueMapper: (SMonthsStandData data, String) => data.x,
              yValueMapper: (SMonthsStandData data, _) => data.y,
              pointColorMapper: (SMonthsStandData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsStandData {
  SMonthsStandData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//!--//
// Years Stand Chart
class YearsStandChart extends StatefulWidget {
  const YearsStandChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearsStandChart> createState() => _YearsStandChartState();
}

class _YearsStandChartState extends State<YearsStandChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> standValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year stand values
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? standValue =
              _activityData.getDouble("standValue_${j}_${0}") ?? 0;

          if (standValue != 0) {
            sum += standValue;
            count++;
          }
        }

        double yaverage = count > 0 ? sum / 300 : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearsStandData> yearsStandData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearsStandData.add(YearsStandData(
          finalDates[temp], yearlyAverages[index]?.toInt(), kBlueRingColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearsStandData, String>(
              name: 'HRS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearsStandData,
              xValueMapper: (YearsStandData data, String) => data.x,
              yValueMapper: (YearsStandData data, _) => data.y,
              pointColorMapper: (YearsStandData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearsStandData {
  YearsStandData(this.x, this.y, this.color);
  final String x;
  final int? y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//Steps Panel
class StepsValue extends StatelessWidget {
  const StepsValue({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 7.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 28,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//!--//
//Weekly Steps Chart
class WeeklyStepsChart extends StatefulWidget {
  const WeeklyStepsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyStepsChart> createState() => _WeeklyStepsChartState();
}

class _WeeklyStepsChartState extends State<WeeklyStepsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> stepsValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 weeks of steps
        double? stepsValue =
            _activityData.getDouble("stepsValue_${i}_${0}") ?? 0;
        stepsValues[i] = stepsValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }

    List<WeeklyStepsData> weeklyStepsData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyStepsData.add(
          WeeklyStepsData(finalDates[i], stepsValues[index], kContainerColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyStepsData, String>(
              name: 'STEPS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyStepsData,
              xValueMapper: (WeeklyStepsData data, String) => data.x,
              yValueMapper: (WeeklyStepsData data, _) => data.y,
              pointColorMapper: (WeeklyStepsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyStepsData {
  WeeklyStepsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//Monthly Steps Chart
class MonthlyStepsChart extends StatefulWidget {
  const MonthlyStepsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyStepsChart> createState() => _MonthlyStepsChartState();
}

class _MonthlyStepsChartState extends State<MonthlyStepsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> stepsValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 month of steps
        double? stepsValue =
            _activityData.getDouble("stepsValue_${i}_${0}") ?? 0;
        stepsValues[i] = stepsValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }

    List<MonthlyStepsData> monthlyStepsData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      monthlyStepsData.add(MonthlyStepsData(
          finalDates[temp], stepsValues[index], kContainerColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyStepsData, String>(
              name: 'STEPS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyStepsData,
              xValueMapper: (MonthlyStepsData data, String) => data.x,
              yValueMapper: (MonthlyStepsData data, _) => data.y,
              pointColorMapper: (MonthlyStepsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyStepsData {
  MonthlyStepsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//6 Months Steps Chart
class SMonthsStepsChart extends StatefulWidget {
  const SMonthsStepsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsStepsChart> createState() => _SMonthsStepsChartState();
}

class _SMonthsStepsChartState extends State<SMonthsStepsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> stepsValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? stepsValue =
              _activityData.getDouble("stepsValue_${j}_${0}") ?? 0;

          if (stepsValue != 0) {
            sum += stepsValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsStepsData> sMonthsStepsData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsStepsData.add(SMonthsStepsData(
          finalDates[temp], monthlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsStepsData, String>(
              name: 'STEPS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsStepsData,
              xValueMapper: (SMonthsStepsData data, String) => data.x,
              yValueMapper: (SMonthsStepsData data, _) => data.y,
              pointColorMapper: (SMonthsStepsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsStepsData {
  SMonthsStepsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//1 Year Steps Chart
class YearStepsChart extends StatefulWidget {
  const YearStepsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearStepsChart> createState() => _YearStepsChartState();
}

class _YearStepsChartState extends State<YearStepsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> stepsValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year heart rates
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? stepsValues =
              _activityData.getDouble("stepsValue_${j}_${0}") ?? 0;

          if (stepsValues != 0) {
            sum += stepsValues;
            count++;
          }
        }

        double yaverage = count > 0 ? sum : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearStepsData> yearStepsData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearStepsData.add(YearStepsData(
          finalDates[temp], yearlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearStepsData, String>(
              name: 'STEPS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearStepsData,
              xValueMapper: (YearStepsData data, String) => data.x,
              yValueMapper: (YearStepsData data, _) => data.y,
              pointColorMapper: (YearStepsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearStepsData {
  YearStepsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//!--//
//Distance
class DistanceValue extends StatelessWidget {
  const DistanceValue({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Weekly Distance Chart
class WeeklyDistanceChart extends StatefulWidget {
  const WeeklyDistanceChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyDistanceChart> createState() => _WeeklyDistanceChartState();
}

class _WeeklyDistanceChartState extends State<WeeklyDistanceChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> distanceValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 week of distance values
        double? distanceValue =
            _activityData.getDouble("distanceValue_${i}_${0}") ?? 0;
        distanceValues[i] = distanceValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }

    List<WeeklyDistanceData> weeklyDistanceData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      double? distanceValue = distanceValues[index];
      double roundedDistance = distanceValue != null && distanceValue != 0
          ? double.parse(distanceValue.toStringAsFixed(2))
          : 0.0;
      weeklyDistanceData.add(
          WeeklyDistanceData(finalDates[i], roundedDistance, kContainerColor));
    }

    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyDistanceData, String>(
              name: 'KM ',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyDistanceData,
              xValueMapper: (WeeklyDistanceData data, String) => data.x,
              yValueMapper: (WeeklyDistanceData data, _) => data.y,
              pointColorMapper: (WeeklyDistanceData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyDistanceData {
  WeeklyDistanceData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//Monthly Distance Chart
class MonthlyDistanceChart extends StatefulWidget {
  const MonthlyDistanceChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyDistanceChart> createState() => _MonthlyDistanceChartState();
}

class _MonthlyDistanceChartState extends State<MonthlyDistanceChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> distanceValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 month of distance values
        double? distanceValue =
            _activityData.getDouble("distanceValue_${i}_${0}") ?? 0;
        distanceValues[i] = distanceValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }

    List<MonthlyDistanceData> monthlyDistanceData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      double? distanceValue = distanceValues[index];

      double roundedDistance = distanceValue != null && distanceValue != 0
          ? double.parse(distanceValue.toStringAsFixed(2))
          : 0.0;
      monthlyDistanceData.add(MonthlyDistanceData(
          finalDates[temp], roundedDistance, kContainerColor));
    }

    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyDistanceData, String>(
              name: 'KM',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyDistanceData,
              xValueMapper: (MonthlyDistanceData data, String) => data.x,
              yValueMapper: (MonthlyDistanceData data, _) => data.y,
              pointColorMapper: (MonthlyDistanceData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyDistanceData {
  MonthlyDistanceData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--//
//SMonths Distance Chart
class SMonthsDistanceChart extends StatefulWidget {
  const SMonthsDistanceChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsDistanceChart> createState() => _SMonthsDistanceChartState();
}

class _SMonthsDistanceChartState extends State<SMonthsDistanceChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> distanceValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 6 months of distance values
        double? distanceValue =
            _activityData.getDouble("distanceValue_${i}_${0}") ?? 0;
        distanceValues[i] = distanceValue;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? distanceValue =
              _activityData.getDouble("distanceValue_${j}_${0}") ?? 0;
          if (distanceValue != 0) {
            sum += distanceValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsDistanceData> sMonthsDistanceData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;

      sMonthsDistanceData.add(SMonthsDistanceData(
          finalDates[temp], monthlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsDistanceData, String>(
              name: 'KM',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsDistanceData,
              xValueMapper: (SMonthsDistanceData data, String) => data.x,
              yValueMapper: (SMonthsDistanceData data, _) => data.y,
              pointColorMapper: (SMonthsDistanceData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsDistanceData {
  SMonthsDistanceData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--/
//Years Distance Chart
class YearsDistanceChart extends StatefulWidget {
  const YearsDistanceChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearsDistanceChart> createState() => _YearsDistanceChartState();
}

class _YearsDistanceChartState extends State<YearsDistanceChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> distanceValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year distance values
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? distanceValue =
              _activityData.getDouble("distanceValue_${j}_${0}") ?? 0;

          if (distanceValue != 0) {
            sum += distanceValue;
            count++;
          }
        }

        double yaverage = count > 0 ? sum : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearsDistanceData> yearsDistanceData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearsDistanceData.add(YearsDistanceData(
          finalDates[temp], yearlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 0),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearsDistanceData, String>(
              name: 'KM',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearsDistanceData,
              xValueMapper: (YearsDistanceData data, String) => data.x,
              yValueMapper: (YearsDistanceData data, _) => data.y,
              pointColorMapper: (YearsDistanceData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearsDistanceData {
  YearsDistanceData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//-----------------//
//!-----------------//
//-----------------//

//!--/
//Weekly Floors Chart
class WeeklyFloorsChart extends StatefulWidget {
  const WeeklyFloorsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<WeeklyFloorsChart> createState() => _WeeklyFloorsChartState();
}

class _WeeklyFloorsChartState extends State<WeeklyFloorsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> floorsValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        // Getting 1 week of floors
        double? floorsValue =
            _activityData.getDouble("floorsValue_${i}_${0}") ?? 0;
        floorsValues[i] = floorsValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 358; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 3 ? tempDate.substring(0, 3) : tempDate;
      finalDates.add(finalDate);
    }

    List<WeeklyFloorsData> weeklyFloorsData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyFloorsData.add(WeeklyFloorsData(
          finalDates[i], floorsValues[index], kContainerColor));
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<WeeklyFloorsData, String>(
              name: 'FLOORS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyFloorsData,
              xValueMapper: (WeeklyFloorsData data, String) => data.x,
              yValueMapper: (WeeklyFloorsData data, _) => data.y,
              pointColorMapper: (WeeklyFloorsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyFloorsData {
  WeeklyFloorsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--/
//Monthly Floors Chart
class MonthlyFloorsChart extends StatefulWidget {
  const MonthlyFloorsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyFloorsChart> createState() => _MonthlyFloorsChartState();
}

class _MonthlyFloorsChartState extends State<MonthlyFloorsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> floorsValues = List<double?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;

        //Getting 1 month of floors
        double? floorsValue =
            _activityData.getDouble("floorsValue_${i}_${0}") ?? 0;
        floorsValues[i] = floorsValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 332; i--) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(4, 6) : tempDate;
      finalDates.add(finalDate);
    }

    List<MonthlyFloorsData> monthlyFloorsData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      monthlyFloorsData.add(MonthlyFloorsData(
          finalDates[temp], floorsValues[index], kContainerColor));
    }

    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyFloorsData, String>(
              name: 'FLOORS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyFloorsData,
              xValueMapper: (MonthlyFloorsData data, String) => data.x,
              yValueMapper: (MonthlyFloorsData data, _) => data.y,
              pointColorMapper: (MonthlyFloorsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyFloorsData {
  MonthlyFloorsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--/
//6 Months Floors Chart
class SMonthsFloorsChart extends StatefulWidget {
  const SMonthsFloorsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<SMonthsFloorsChart> createState() => _SMonthsFloorsChartState();
}

class _SMonthsFloorsChartState extends State<SMonthsFloorsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<double?> floorsValues = List<double?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      //Getting 6 months of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? floorsValue =
              _activityData.getDouble("floorsValue_${j}_${0}") ?? 0;

          if (floorsValue != 0) {
            sum += floorsValue;
            count++;
          }
        }

        double maverage = count > 0 ? sum : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsFloorsData> sMonthsFloorsData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsFloorsData.add(SMonthsFloorsData(
          finalDates[temp], monthlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<SMonthsFloorsData, String>(
              name: 'FLOORS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsFloorsData,
              xValueMapper: (SMonthsFloorsData data, String) => data.x,
              yValueMapper: (SMonthsFloorsData data, _) => data.y,
              pointColorMapper: (SMonthsFloorsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SMonthsFloorsData {
  SMonthsFloorsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

//!--/
//1 Year Floors Chart
class YearFloorsChart extends StatefulWidget {
  const YearFloorsChart({
    Key? key,
  }) : super(key: key);

  @override
  State<YearFloorsChart> createState() => _YearFloorsChartState();
}

class _YearFloorsChartState extends State<YearFloorsChart> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> floorsValues = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
        dateTimes[i] = dateTime;
      }

      // Getting 1 year floors
      double sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          double? floorsValues =
              _activityData.getDouble("floorsValue_${j}_${0}") ?? 0;

          if (floorsValues != 0) {
            sum += floorsValues;
            count++;
          }
        }

        double yaverage = count > 0 ? sum : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    int index = 11;
    List<YearFloorsData> yearFloorsData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yearFloorsData.add(YearFloorsData(
          finalDates[temp], yearlyAverages[index], kContainerColor));
      index--;
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(right: 10),
        width: 95.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          trackballBehavior: TrackballBehavior(
            lineWidth: 0,
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings: InteractiveTooltip(
              textStyle: TextStyle(fontSize: 14, color: kTextBlackColor),
              color: Colors.white70,
              canShowMarker: true,
              borderRadius: 10,
              enable: true,
            ),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          ),
          series: <ChartSeries>[
            ColumnSeries<YearFloorsData, String>(
              name: 'FLOORS',
              animationDelay: 100,
              animationDuration: 2000,
              isTrackVisible: false,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearFloorsData,
              xValueMapper: (YearFloorsData data, String) => data.x,
              yValueMapper: (YearFloorsData data, _) => data.y,
              pointColorMapper: (YearFloorsData data, _) => data.color,
              // Width of the columns
              width: 0.2,
              spacing: 0.1,
              // Sets the corner radius
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YearFloorsData {
  YearFloorsData(this.x, this.y, this.color);
  final String x;
  final double? y;
  final Color color;
}

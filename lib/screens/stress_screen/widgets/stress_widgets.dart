import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:temp/screens/stress_screen/widgets/stress_algorithm.dart';
import '../../../constants.dart';

//Stress Num
class StressNum extends StatelessWidget {
  const StressNum({Key? key, required this.title}) : super(key: key);

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
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Weekly Heart Rate
class WeeklyStressChart extends StatefulWidget {
  const WeeklyStressChart({Key? key}) : super(key: key);

  @override
  State<WeeklyStressChart> createState() => _WeeklyStressChartState();
}

class _WeeklyStressChartState extends State<WeeklyStressChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _hrv = SharedPreferences.getInstance();
  StressCalculator stressCalculator = StressCalculator();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<String?> hrvDateTimes = List<String?>.filled(365, null);
  //
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> tempHeartRates = List<double?>.filled(365, null);
  List<double?> hrvValues = List<double?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> stressValues = List<double?>.filled(365, null);
  //
  List<int?> counter = List<int?>.filled(10, null);

  //

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _hrvData = await _hrv;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;

        //
        //Getting 1 week of resting heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
        if (restingHeartRate != 0)
          tempHeartRates[i] = restingHeartRates[i]!.toDouble();
        else
          tempHeartRates[i] = 0;
      }

      for (int i = 0; i < hrvDateTimes.length; i++) {
        String? hrvDateTime = _hrvData.getString("dateTime_${i}_${0}") ?? 'N/A';
        hrvDateTimes[i] = hrvDateTime;
      }

      //Getting 1 year of dates that hrv values were written
      for (int i = 0; i < 365; i++) {
        double? hrvValue = _hrvData.getDouble("hrv_${i}_${0}") ?? 0;
        hrvValues[i] = hrvValue;
      }

      //Getting 1 year of exercise minutes
      for (int i = 0; i < 365; i++) {
        double? exerciseValue =
            _heartData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      //Weekly Stress Levels
      //Fixing an int array so hrvs get in order

      List<int> matchIndices = [];

      //Getting weekly stress levels inserted to the algorithm
      for (int i = 364; i > 357; i--) {
        String? dateTime = dateTimes[i];
        int? matchIndex = hrvDateTimes.indexOf(dateTime);

        if (matchIndex != -1) {
          matchIndices.add(matchIndex);
        } else {}

        if (matchIndex < 100) {
          hrvValues[matchIndex];
        }

        double heartRate = tempHeartRates[i] ?? 0; //Daily heart rate
        double hrv = hrvValues[matchIndex]!
            .toDouble(); //Fiding the heartrate variability during the day
        String activityType =
            'fairly_active_exercise'; //Specify the activity type
        int duration = exerciseValues[i]!.toInt(); // in minutes
        // Calculate stress using StressCalculator Algorith
        double? stress = stressCalculator.calculateStress(
            heartRate, hrv, activityType, duration);
        stressValues[i] = (stress * 100).round() / 100;
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

    List<WeeklyStressData> weeklyStressData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyStressData
          .add(WeeklyStressData(finalDates[i], (stressValues[index])));
    }

    return InkWell(
      child: Container(
        width: 93.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
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
            ColumnSeries<WeeklyStressData, String>(
              name: 'PSS',
              animationDelay: 100,
              animationDuration: 2000,
              color: kSecondaryColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyStressData,
              xValueMapper: (WeeklyStressData data, String) => data.x,
              yValueMapper: (WeeklyStressData data, _) => data.y,
              width: 0.2,
              spacing: 0.1,
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

class WeeklyStressData {
  WeeklyStressData(this.x, this.y);
  final String? x;
  final double? y;
}

//Monthly Stress Levels
class MonthlyStressChart extends StatefulWidget {
  const MonthlyStressChart({Key? key}) : super(key: key);

  @override
  State<MonthlyStressChart> createState() => _MonthlyStressChartState();
}

class _MonthlyStressChartState extends State<MonthlyStressChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _hrv = SharedPreferences.getInstance();
  StressCalculator stressCalculator = StressCalculator();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<String?> hrvDateTimes = List<String?>.filled(365, null);
  //
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> tempHeartRates = List<double?>.filled(365, null);
  List<double?> hrvValues = List<double?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> stressValues = List<double?>.filled(365, null);
  //
  List<int?> counter = List<int?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _hrvData = await _hrv;

    setState(() {
      //Getting 1 month of dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
        //
        //Getting 1 month of resting heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
        if (restingHeartRate != 0)
          tempHeartRates[i] = restingHeartRates[i]!.toDouble();
        else
          tempHeartRates[i] = 0;
      }

      for (int i = 0; i < hrvDateTimes.length; i++) {
        String? hrvDateTime = _hrvData.getString("dateTime_${i}_${0}") ?? 'N/A';
        hrvDateTimes[i] = hrvDateTime;
      }

      //Getting 1 year of dates that hrv values were written
      for (int i = 0; i < 365; i++) {
        double? hrvValue = _hrvData.getDouble("hrv_${i}_${0}") ?? 0;
        hrvValues[i] = hrvValue;
      }

      //Getting 1 year of exercise minutes
      for (int i = 0; i < 365; i++) {
        double? exerciseValue =
            _heartData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      //Monthly Stress Levels
      //Fixing an int array so hrvs get in order

      List<int> matchIndices = [];

      //Getting monthly stress levels inserted to the algorithm
      for (int i = 364; i > 332; i--) {
        String? dateTime = dateTimes[i];
        int? matchIndex = hrvDateTimes.indexOf(dateTime);

        if (matchIndex != -1) {
          matchIndices.add(matchIndex);
        } else {}

        if (matchIndex > 150) {
          hrvValues[matchIndex];
        }

        double heartRate = tempHeartRates[i] ?? 0; //Daily heart rate
        double hrv = hrvValues[matchIndex]!
            .toDouble(); //Fiding the heartrate variability during the day
        String activityType =
            'fairly_active_exercise'; //Specify the activity type
        int duration = exerciseValues[i]!.toInt(); // in minutes
        // Calculate stress using StressCalculator Algorith
        double? stress = stressCalculator.calculateStress(
            heartRate, hrv, activityType, duration);
        stressValues[i] = (stress * 100).round() / 100;
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

    List<MonthlyStressData> monthlyStressData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      monthlyStressData
          .add(MonthlyStressData(finalDates[temp], stressValues[index]));
    }

    return InkWell(
      child: Container(
        width: 93.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
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
            ColumnSeries<MonthlyStressData, String>(
              name: 'PSS',
              animationDelay: 100,
              animationDuration: 2000,
              color: kSecondaryColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyStressData,
              xValueMapper: (MonthlyStressData data, String) => data.x,
              yValueMapper: (MonthlyStressData data, _) => data.y,
              width: 0.2,
              spacing: 0.1,
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

class MonthlyStressData {
  MonthlyStressData(this.x, this.y);
  final String x;
  final double? y;
}

//6 Months Stress Levels
class SMonthStressChart extends StatefulWidget {
  const SMonthStressChart({Key? key}) : super(key: key);

  @override
  State<SMonthStressChart> createState() => _SMonthStressChartState();
}

class _SMonthStressChartState extends State<SMonthStressChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _hrv = SharedPreferences.getInstance();
  StressCalculator stressCalculator = StressCalculator();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<String?> hrvDateTimes = List<String?>.filled(365, null);
  //
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> tempHeartRates = List<double?>.filled(365, null);
  List<double?> hrvValues = List<double?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> stressValues = List<double?>.filled(365, null);
  //
  List<double?> smStressValues = List<double?>.filled(6, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _hrvData = await _hrv;

    setState(() {
      // Getting 6 month dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;

        // Getting 6 month heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
      }

      for (int i = 0; i < 365; i++) {
        String? hrvDateTime = _hrvData.getString("dateTime_${i}_${0}") ?? 'N/A';
        hrvDateTimes[i] = hrvDateTime;
      }

      //Getting 1 year of dates that hrv values were written
      for (int i = 0; i < 365; i++) {
        double? hrvValue = _hrvData.getDouble("hrv_${i}_${0}") ?? 0;
        hrvValues[i] = hrvValue;
      }

      //Getting 1 year of exercise minutes
      for (int i = 0; i < 365; i++) {
        double? exerciseValue =
            _heartData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      //Getting 6 month of dates
      for (int i = 364; i > 183; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
        //
        //Getting 6 month of resting heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
        if (restingHeartRate != 0)
          tempHeartRates[i] = restingHeartRates[i]!.toDouble();
        else
          tempHeartRates[i] = 0;
      }

      //Fixing an int array so hrvs get in order
      List<int> matchIndices = [];
      int loopCount = 0; // Initialize a variable to count the loops
      double? sum = 0;
      int temp = 0;
      //Getting monthly stress levels inserted to the algorithm
      for (int i = 364; i > 183; i--) {
        String? dateTime = dateTimes[i];
        int? matchIndex = hrvDateTimes.indexOf(dateTime);

        if (matchIndex != -1) {
          // Match found
          matchIndices.add(matchIndex);
          if (matchIndex > 150) {
            double heartRate = tempHeartRates[i] ?? 0; // Daily heart rate
            double hrv =
                hrvValues[matchIndex]!.toDouble(); // HRV during the day
            String activityType =
                'fairly_active_exercise'; // Specify the activity type
            int duration = exerciseValues[i]!.toInt(); // Duration in minutes

            // Calculate stress using StressCalculator Algorithm
            double stress = stressCalculator.calculateStress(
                heartRate, hrv, activityType, duration);
            stressValues[i] = (stress * 100).round() / 100;
            sum = (sum! + (stressValues[i]?.toDouble() ?? 0.0));
          }
        }

        loopCount++;

        // Check if we've completed 30 loops
        if (loopCount == 30) {
          // Save or use the 'sum' value here for the current block of 30 loops
          if (sum != null) {
            double average = sum / 30;
            smStressValues[temp] = double.parse(average.toStringAsFixed(2));
          } else
            smStressValues[temp] = 0.00;

          sum = 0.0; // Reset the 'sum' for the next block
          loopCount = 0; // Reset the loop count
          temp++;
        }
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
    List<SMonthsStressData> sMonthsStressData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsStressData
          .add(SMonthsStressData(finalDates[temp], smStressValues[temp]));
    }
    return InkWell(
      child: Container(
        width: 93.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
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
            ColumnSeries<SMonthsStressData, String>(
              name: 'AVG PSS',
              animationDelay: 100,
              animationDuration: 2000,
              color: kSecondaryColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: sMonthsStressData,
              xValueMapper: (SMonthsStressData data, String) => data.x,
              yValueMapper: (SMonthsStressData data, _) => data.y,
              width: 0.2,
              spacing: 0.1,
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

class SMonthsStressData {
  SMonthsStressData(this.x, this.y);
  final String x;
  final double? y;
}

//1 Year Stress Levels
class YStressChart extends StatefulWidget {
  const YStressChart({Key? key}) : super(key: key);

  @override
  State<YStressChart> createState() => _YStressChartState();
}

class _YStressChartState extends State<YStressChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _hrv = SharedPreferences.getInstance();
  StressCalculator stressCalculator = StressCalculator();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<String?> hrvDateTimes = List<String?>.filled(365, null);
  //
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> tempHeartRates = List<double?>.filled(365, null);
  List<double?> hrvValues = List<double?>.filled(365, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> stressValues = List<double?>.filled(365, null);
  //
  List<double?> yStressValues = List<double?>.filled(12, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _hrvData = await _hrv;

    setState(() {
      for (int i = 0; i < 365; i++) {
        String? hrvDateTime = _hrvData.getString("dateTime_${i}_${0}") ?? 'N/A';
        hrvDateTimes[i] = hrvDateTime;
      }

      //Getting 1 year of dates that hrv values were written
      for (int i = 0; i < 365; i++) {
        double? hrvValue = _hrvData.getDouble("hrv_${i}_${0}") ?? 0;
        hrvValues[i] = hrvValue;
      }

      //Getting 1 year of exercise minutes
      for (int i = 0; i < 365; i++) {
        double? exerciseValue =
            _heartData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      //Getting 12 monthns of dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
        //
        //Getting 12 monthns of resting heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
        if (restingHeartRate != 0)
          tempHeartRates[i] = restingHeartRates[i]!.toDouble();
        else
          tempHeartRates[i] = 0;
      }

      //Fixing an int array so hrvs get in order
      List<int> matchIndices = [];
      int loopCount = 0; // Initialize a variable to count the loops
      double? sum = 0;
      int temp = 0;
      //Getting monthly stress levels inserted to the algorithm
      for (int i = 364; i >= 0; i--) {
        String? dateTime = dateTimes[i];
        int? matchIndex = hrvDateTimes.indexOf(dateTime);
        if (matchIndex != -1) {
          // Match found
          matchIndices.add(matchIndex);
          if (matchIndex > 30) {
            double heartRate = tempHeartRates[i] ?? 0; // Daily heart rate
            double hrv =
                hrvValues[matchIndex]!.toDouble(); // HRV during the day
            String activityType =
                'fairly_active_exercise'; // Specify the activity type
            int duration = exerciseValues[i]!.toInt(); // Duration in minutes

            // Calculate stress using StressCalculator Algorithm
            double stress = stressCalculator.calculateStress(
                heartRate, hrv, activityType, duration);
            stressValues[i] = (stress * 100).round() / 100;
            sum = (sum! + (stressValues[i]?.toDouble() ?? 0.0));
          }
        }

        loopCount++;

        // Check if we've completed 30 loops
        if (loopCount == 30) {
          // Save or use the 'sum' value here for the current block of 30 loops
          if (sum != null) {
            double average = sum / 30;
            yStressValues[temp] = double.parse(average.toStringAsFixed(2));
          } else
            yStressValues[temp] = 0.00;

          sum = 0.0; // Reset the 'sum' for the next block
          loopCount = 0; // Reset the loop count
          temp++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i >= 0; i -= 30) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 12;
    List<YearlyStressData> yearlyStressData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;

      yearlyStressData
          .add(YearlyStressData(finalDates[temp], yStressValues[temp]));
    }
    return InkWell(
      child: Container(
        width: 93.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
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
            ColumnSeries<YearlyStressData, String>(
              name: 'AVG PSS',
              animationDelay: 100,
              animationDuration: 2000,
              color: kSecondaryColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yearlyStressData,
              xValueMapper: (YearlyStressData data, String) => data.x,
              yValueMapper: (YearlyStressData data, _) => data.y,
              width: 0.2,
              spacing: 0.1,
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

class YearlyStressData {
  YearlyStressData(this.x, this.y);
  final String x;
  final double? y;
}

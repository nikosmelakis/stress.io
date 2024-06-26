// ignore_for_file: unnecessary_null_comparison

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:temp/screens/home_screen/widgets/app_widgets.dart';
import 'package:temp/screens/stress_screen/widgets/stress_algorithm.dart';
import 'package:temp/screens/stress_screen/widgets/stress_widgets.dart';

bool d = true;
bool w = false;
bool m = false;
bool sm = false;
bool y = false;

class StressScreen extends StatefulWidget {
  const StressScreen({Key? key}) : super(key: key);
  static String routeName = 'StressScreen';

  @override
  _StressScreenState createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _hrv = SharedPreferences.getInstance();
  Future<SharedPreferences> _perMinHeart = SharedPreferences.getInstance();
  StressCalculator stressCalculator = StressCalculator();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<String?> hrvDateTimes = List<String?>.filled(365, null);
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> heartRateVariabilities = List<double?>.filled(365, null);
  //
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);
  List<double?> exerciseValues = List<double?>.filled(365, null);
  List<double?> tempHeartRates = List<double?>.filled(365, null);
  //
  List<double?> hrvValues = List<double?>.filled(365, null);
  //
  List<String?> hourTimes = List<String?>.filled(1440, null);
  List<double?> minHeartRates = List<double?>.filled(1440, null);
  //

  List<double?> tempStressLevels = List<double?>.filled(365, null);
  List<double?> wStressValues = List<double?>.filled(365, null);
  List<double?> mStressValues = List<double?>.filled(365, null);
  List<double?> smStressValues = List<double?>.filled(365, null);
  List<double?> yStressValues = List<double?>.filled(365, null);
  //
  List<double?> smStressSum = List<double?>.filled(365, null);
  List<double?> yStressSum = List<double?>.filled(365, null);
  //
  double sum = 0;
  int count = 0;

  String? dailyLowestValue,
      dailyHighestValue,
      weeksLowestValue,
      weeksHighestValue,
      monthsLowestValue,
      monthsHighestValue,
      smonthsLowestValue,
      smonthsHighestValue,
      yearsLowestValue,
      yearsHighestValue,
      weeksAverage,
      monthsAverage,
      smonthsAverage,
      yearsAverage,
      dailyStress;

  double dailyRadialStress = 0;
  String? finalHour;
  int cnt = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _perMinHeartData = await _perMinHeart;
    final SharedPreferences _hrvData = await _hrv;

    setState(() {
      //Getting 1 year of dates
      for (int i = 0; i < 365; i++) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
      }

      for (int i = 0; i < 365; i++) {
        String? hrvDateTime = _hrvData.getString("dateTime_${i}_${0}") ?? 'N/A';
        hrvDateTimes[i] = hrvDateTime;
      }

      //fiding todays hrv position based on the date
      for (int i = 0; i < hrvDateTimes.length; i++) {
        String? hrvDateTime = hrvDateTimes[i];

        if (hrvDateTime == dateTimes[364]) {
          cnt = i;
          break;
        }
      }
      //
      //Getting 1 year of dates that hrv values were written
      for (int i = 0; i < 365; i++) {
        double? hrvValue = _hrvData.getDouble("hrv_${i}_${0}") ?? 0;
        hrvValues[i] = hrvValue;
      }

      //Getting 1 year of heartrate levels
      for (int i = 0; i < 365; i++) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
      }

      //Getting 1 year of exercise minutes
      for (int i = 0; i < 365; i++) {
        double? exerciseValue =
            _heartData.getDouble("exerciseValue_${i}_${0}") ?? 0;
        exerciseValues[i] = exerciseValue;
      }

      //Getting exact time of heartrates levels in the last 24hrs
      for (int i = 0; i < 1440; i += 5) {
        String? hourTime =
            _perMinHeartData.getString("dailyHeartHour_${i}_${0}") ?? 'N/A';
        hourTimes[i] = hourTime;
        if (hourTime != 'N/A') finalHour = hourTime;
      }

      //Getting daily heartrates per minute in the last 24hrs
      for (int i = 0; i < 1440; i += 5) {
        double? minHeartRate =
            _perMinHeartData.getDouble("dailyHeartRate_${i}_${0}") ?? 0;
        minHeartRates[i] = minHeartRate;
      }

      _activityData.getDouble("exerciseValue_${364}_${0}") ?? 0;

      //-----//
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

        if (matchIndex > 100) {
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
        wStressValues[i] = (stress * 100).round() / 100;
      }

      dailyStress = wStressValues[364].toString();
      dailyRadialStress = wStressValues[364]! / 10;

      //Weekly averages
      double weeksLowest = wStressValues
          .where((value) => value != null)
          .fold(double.infinity, (a, b) => a < b! ? a : b);

      double weeksHighest = wStressValues
          .where((value) => value != null)
          .fold(double.negativeInfinity, (a, b) => a > b! ? a : b);

      double sum = wStressValues
          .where((value) => value != null)
          .fold(0.00, (a, b) => a + (b ?? 0.00));

      double weeksAverageTemp = wStressValues.isEmpty ? 0.00 : sum / 7;

      weeksLowestValue = weeksLowest.toStringAsFixed(2);
      weeksHighestValue = weeksHighest.toStringAsFixed(2);

      weeksAverage = weeksAverageTemp.toStringAsFixed(2);

      //------------//

      //Monthly Stress Levels
      //Getting 1 month of dates

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

      //Monthly Stress Levels
      //Fixing an int array so hrvs get in order

      List<int> mMatchIndices = [];

      //Getting monthly stress levels inserted to the algorithm
      for (int i = 364; i > 332; i--) {
        String? dateTime = dateTimes[i];
        int? mMatchIndex = hrvDateTimes.indexOf(dateTime);

        if (mMatchIndex != -1) {
          mMatchIndices.add(mMatchIndex);
        } else {}

        if (mMatchIndex < 100) {
          hrvValues[mMatchIndex];
        }

        double heartRate = tempHeartRates[i] ?? 0; //Daily heart rate
        double hrv = hrvValues[mMatchIndex]!
            .toDouble(); //Fiding the heartrate variability during the day
        String activityType =
            'fairly_active_exercise'; //Specify the activity type
        int duration = exerciseValues[i]!.toInt(); // in minutes
        // Calculate stress using StressCalculator Algorith
        double? stress = stressCalculator.calculateStress(
            heartRate, hrv, activityType, duration);
        mStressValues[i] = (stress * 100).round() / 100;
      }

      //monthly averages
      double monthsLowest = mStressValues
          .where((value) => value != null)
          .fold(double.infinity, (a, b) => a < b! ? a : b);

      double monthsHighest = mStressValues
          .where((value) => value != null)
          .fold(double.negativeInfinity, (a, b) => a > b! ? a : b);

      double msum = mStressValues
          .where((value) => value != null)
          .fold(0.00, (a, b) => a + (b ?? 0.00));

      double monthsAverageTemp = mStressValues.isEmpty ? 0.00 : msum / 30.5;

      monthsLowestValue = monthsLowest.toStringAsFixed(2);
      monthsHighestValue = monthsHighest.toStringAsFixed(2);

      monthsAverage = monthsAverageTemp.toStringAsFixed(2);

      //Six(6) Months Stress Levels
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

      List<int> smMatchIndices = [];

      List<double> smAverages = [];

      sum = 0;
      int loopCount = 0;

      for (int i = 364; i > 183; i--) {
        String? dateTime = dateTimes[i];
        int? smMatchIndex = hrvDateTimes.indexOf(dateTime);

        if (smMatchIndex != -1) {
          // Match found
          smMatchIndices.add(smMatchIndex);
          if (smMatchIndex > 150) {
            double heartRate = tempHeartRates[i] ?? 0; // Daily heart rate
            double hrv =
                hrvValues[smMatchIndex]!.toDouble(); // HRV during the day
            String activityType =
                'fairly_active_exercise'; // Specify the activity type
            int duration = exerciseValues[i]!.toInt(); // Duration in minutes

            // Calculate stress using StressCalculator Algorithm
            double stress = stressCalculator.calculateStress(
                heartRate, hrv, activityType, duration);
            smStressValues[i] = (stress * 100).round() / 100;
            sum += smStressValues[i] ?? 0.0;
          }
        }

        loopCount++;

        if (loopCount == 30) {
          // Save or use the 'sum' value here for the current block of 30 loops
          if (sum != null) {
            double average = smStressValues.isEmpty ? 0 : sum / 30;
            smAverages.add(average);
          } else {
            smAverages.add(0.00);
          }

          // Reset values for the next block
          sum = 0.0;
          loopCount = 0;
        }
      }

      double? smLowest = smAverages.isEmpty
          ? null
          : smAverages.reduce((a, b) => a < b ? a : b);
      double? smHighest = smAverages.isEmpty
          ? null
          : smAverages.reduce((a, b) => a > b ? a : b);

      smonthsLowestValue =
          smLowest != null ? smLowest.toStringAsFixed(2) : "N/A";
      smonthsHighestValue =
          smHighest != null ? smHighest.toStringAsFixed(2) : "N/A";

      sum = smAverages.fold(0.0, (a, b) => a + (b));

      double average = smAverages.isEmpty ? 0 : sum / 6;

      smonthsAverage = average.toStringAsFixed(2);

      //
      //Twelve(12) Months Stress Levels
      //Calculate one(1) year of heart data exluding zeros
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

      //Getting 12 month of dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
        //
        //Getting 12 month of resting heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
        if (restingHeartRate != 0)
          tempHeartRates[i] = restingHeartRates[i]!.toDouble();
        else
          tempHeartRates[i] = 0;
      }
      //Fixing an int array so hrvs get in order
      List<int> yMatchIndices = [];
      List<double> yAverages = [];
      sum = 0;
      int loopCount2 = 0;

      for (int i = 364; i >= 0; i--) {
        String? dateTime = dateTimes[i];
        int? yMatchIndex = hrvDateTimes.indexOf(dateTime);

        if (yMatchIndex != -1) {
          // Match found
          yMatchIndices.add(yMatchIndex);
          if (yMatchIndex > 30) {
            double heartRate = tempHeartRates[i] ?? 0; // Daily heart rate
            double hrv =
                hrvValues[yMatchIndex]!.toDouble(); // HRV during the day
            String activityType =
                'fairly_active_exercise'; // Specify the activity type
            int duration = exerciseValues[i]!.toInt(); // Duration in minutes

            // Calculate stress using StressCalculator Algorithm
            double stress = stressCalculator.calculateStress(
                heartRate, hrv, activityType, duration);
            yStressValues[i] = (stress * 100).round() / 100;
            sum += yStressValues[i] ?? 0.0;
          }
        }

        loopCount2++;

        if (loopCount2 == 30) {
          // Save or use the 'sum' value here for the current block of 30 loops
          if (sum != null) {
            double average = yStressValues.isEmpty ? 0 : sum / 30;
            yAverages.add(average);
          } else {
            yAverages.add(0.00);
          }
          // Reset values for the next block
          sum = 0.0;
          loopCount2 = 0;
        }
      }
      double? yLowest =
          yAverages.isEmpty ? null : yAverages.reduce((a, b) => a < b ? a : b);
      double? yHighest =
          yAverages.isEmpty ? null : yAverages.reduce((a, b) => a > b ? a : b);

      yearsLowestValue = yLowest != null ? yLowest.toStringAsFixed(2) : "N/A";
      yearsHighestValue =
          yHighest != null ? yHighest.toStringAsFixed(2) : "N/A";

      sum = yAverages.fold(0.0, (a, b) => a + (b));

      double yAverage = yAverages.isEmpty ? 0 : sum / 6;

      yearsAverage = yAverage.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Stress Levels'),
        shape: RoundedRectangleBorder(
          borderRadius: kBottomBorderRadius * 2,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      d = true;
                      w = false;
                      m = false;
                      sm = false;
                      y = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return kSecondaryColor;
                      } else if (d) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || d) {
                        return kOtherColor;
                      } else {
                        return kTextBlackColor;
                      }
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'D',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    setState(() {
                      d = false;
                      w = true;
                      m = false;
                      sm = false;
                      y = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return kSecondaryColor;
                      } else if (w) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || w) {
                        return kOtherColor;
                      } else {
                        return kTextBlackColor;
                      }
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'W',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    setState(() {
                      d = false;
                      w = false;
                      m = true;
                      sm = false;
                      y = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return kSecondaryColor;
                      } else if (m) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || m) {
                        return kOtherColor;
                      } else {
                        return kTextBlackColor;
                      }
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'M',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    setState(() {
                      d = false;
                      w = false;
                      m = false;
                      sm = true;
                      y = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return kSecondaryColor;
                      } else if (sm) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || sm) {
                        return kOtherColor;
                      } else {
                        return kTextBlackColor;
                      }
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    '6M',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    setState(() {
                      d = false;
                      w = false;
                      m = false;
                      sm = false;
                      y = true;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return kSecondaryColor;
                      } else if (y) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || y) {
                        return kOtherColor;
                      } else {
                        return kTextBlackColor;
                      }
                    }),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'Y',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            //Daily Tab
            if (d) ...{
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScreenHeader(title: '${dateTimes[364]}'),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GaugeRadial(
                        radius: 90,
                        strokeWidth: 15,
                        duration: Duration(milliseconds: 1000),
                        value: dailyRadialStress,
                        gradientColors: [
                          Colors.green,
                          Colors.green,
                          Colors.yellow,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                          Colors.red,
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 130,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Titles(
                              title: 'Daily Stress Average',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: StressNum(
                              title: '$dailyStress PSS',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                  )
                ],
              ),
            }
            //Weekly
            else if (w) ...{
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Weekly content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScreenHeader(title: 'Weekly Summary'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Descr(title: '${dateTimes[358]} - ${dateTimes[364]}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyStressChart(),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Average Stress Level',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$weeksAverage PSS',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Lowest',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Highest',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$weeksLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$weeksHighestValue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ],
              ),
            }
            //Monthly
            else if (m) ...{
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Weekly content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScreenHeader(title: 'Monthly Summary'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Descr(title: '${dateTimes[335]} - ${dateTimes[364]}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyStressChart(),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Average Stress Level',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$monthsAverage PSS',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Lowest',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Highest',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$monthsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$monthsHighestValue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ],
              ),
            }
            //Six Months
            else if (sm) ...{
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Weekly content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScreenHeader(title: 'Six Months Summary'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Descr(title: '${dateTimes[181]} - ${dateTimes[364]}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthStressChart(),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Average Stress Level',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$smonthsAverage PSS',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Lowest',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Highest',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$smonthsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$smonthsHighestValue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ],
              ),
            }
            //Year
            else if (y) ...{
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Weekly content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScreenHeader(title: 'Yearly Summary'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Descr(title: '${dateTimes[30]} - ${dateTimes[364]}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YStressChart(),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Average Stress Level',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$yearsAverage PSS',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Lowest',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Titles(
                                  title: 'Highest',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$yearsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: StressNum(
                                  title: '$yearsHighestValue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}

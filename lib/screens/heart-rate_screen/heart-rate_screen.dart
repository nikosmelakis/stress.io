import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:temp/screens/activity_screen/widgets/activity_widgets.dart';
import 'package:temp/screens/heart-rate_screen/widgets/heart-rate_widgets.dart';
import 'package:temp/screens/home_screen/widgets/app_widgets.dart';

bool h = true;
bool d = false;
bool w = false;
bool m = false;
bool sm = false;
bool y = false;

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({Key? key}) : super(key: key);
  static String routeName = 'HeartRateScreen';

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();
  Future<SharedPreferences> _perMinHeart = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  List<String?> hourTimes = List<String?>.filled(1440, null);
  List<double?> minHeartRates = List<double?>.filled(1440, null);

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
      yearsAverage;

  double dailyRadialHeart = 0;

  String? finalHour;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;
    final SharedPreferences _perMinHeartData = await _perMinHeart;

    setState(() {
      //Getting 1 year of dates
      for (int i = 0; i < 365; i++) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
      }

      //Getting 1 year of heart rates
      for (int i = 0; i < 365; i++) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
      }

      //Getting exact time of heartrate
      for (int i = 0; i < 1440; i += 5) {
        String? hourTime =
            _perMinHeartData.getString("dailyHeartHour_${i}_${0}") ?? 'N/A';
        hourTimes[i] = hourTime;
        if (hourTime != 'N/A') finalHour = hourTime;
      }

      //Getting daily heartrates per minute
      for (int i = 0; i < 1440; i += 5) {
        double? minHeartRate =
            _perMinHeartData.getDouble("dailyHeartRate_${i}_${0}") ?? 0;
        minHeartRates[i] = minHeartRate;
      }

      //Finding days lowest and highest values
      double? tempDailyLowest, tempDailyHighest;

      for (int i = 0; i < minHeartRates.length; i++) {
        double? heartRate = minHeartRates[i];

        // Exclude null and zero values
        if (heartRate != null && heartRate != 0) {
          if (tempDailyLowest == null || heartRate < tempDailyLowest) {
            tempDailyLowest = heartRate;
          }
          if (tempDailyHighest == null || heartRate > tempDailyHighest) {
            tempDailyHighest = heartRate;
          }
        }
      }

      // Set the values based on the conditions
      dailyLowestValue = tempDailyLowest?.toStringAsFixed(2) ?? '0.00';
      dailyHighestValue = tempDailyHighest?.toStringAsFixed(2) ?? '0.00';

      //Daily Redsting Heart Rate for Gauge Radial
      double tempDailyRadialHeart = restingHeartRates[364]!.toDouble();
      dailyRadialHeart = tempDailyRadialHeart / 100;

      //Weekly Heart Rate
      // Find the lowest and highest weeks values excluding zeros
      int? tempWeeksLowestValue, tempWeeksHighestValue;

      for (int i = 365; i > 357; i--) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;

        if (restingHeartRate != 0) {
          if (tempWeeksLowestValue == null ||
              restingHeartRate < tempWeeksLowestValue) {
            tempWeeksLowestValue = restingHeartRate;
          }

          if (tempWeeksHighestValue == null ||
              restingHeartRate > tempWeeksHighestValue) {
            tempWeeksHighestValue = restingHeartRate;
          }
        }
      }

      // Set the values based on the conditions
      weeksLowestValue = tempWeeksLowestValue?.toStringAsFixed(2) ?? '0.00';
      weeksHighestValue = tempWeeksHighestValue?.toStringAsFixed(2) ?? '0.00';

      // Calculate the weeks average excluding zeros

      for (int i = 365; i > 357; i--) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;

        if (restingHeartRate != 0) {
          sum += restingHeartRate;
          count++;
        }
      }

      double waverage = count > 0 ? sum / count : 0;
      weeksAverage = waverage.toStringAsFixed(2);

      //Montlhy Heart Rate
      sum = 0;
      count = 0;
      // Find the lowest and highest months values excluding zeros
      int? tempMonthsLowestValue;
      int? tempMonthsHighestValue;

      for (int i = 364; i > 332; i--) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;

        if (restingHeartRate != 0) {
          if (tempMonthsLowestValue == null ||
              restingHeartRate < tempMonthsLowestValue) {
            tempMonthsLowestValue = restingHeartRate;
          }

          if (tempMonthsHighestValue == null ||
              restingHeartRate > tempMonthsHighestValue) {
            tempMonthsHighestValue = restingHeartRate;
          }
        }
      }

      // Set the values based on the conditions
      monthsLowestValue = tempMonthsLowestValue?.toStringAsFixed(2) ?? '0.00';
      monthsHighestValue = tempMonthsHighestValue?.toStringAsFixed(2) ?? '0.00';

      // Calculate the months average excluding zeros

      sum = 0;
      count = 0;
      for (int i = 364; i > 332; i--) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;

        if (restingHeartRate != 0) {
          sum += restingHeartRate;
          count++;
        }
      }

      double maverage = count > 0 ? sum / count : 0;
      monthsAverage = maverage.toStringAsFixed(2);

      //Six(6) Months Heart Rate
      int startIndex = 364;
      int endIndex = 332;

      for (int i = 0; i < 6; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          int? restingHeartRate =
              _heartData.getInt("restingHeartRate_${j}_${0}") ?? 0;

          if (restingHeartRate != 0) {
            sum += restingHeartRate;
            count++;
          }
        }

        double maverage = count > 0 ? sum / count : 0;
        monthlyAverages[i] = double.parse(maverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 31;
      }

      List<double> monthlyFilteredAverages = monthlyAverages
          .where((value) => value != null && value != 0)
          .cast<double>()
          .toList();

      // Check if there are non-zero and non-null values
      if (monthlyFilteredAverages.isNotEmpty) {
        // Lowest 6 months value
        double? tempSmonthsLowestValue =
            monthlyFilteredAverages.reduce((a, b) => a < b ? a : b);
        // Highest 6 months value
        double? tempSmonthsHighestValue =
            monthlyFilteredAverages.reduce((a, b) => a > b ? a : b);
        double? smtemp = monthlyFilteredAverages.reduce((a, b) => a + b) /
            monthlyFilteredAverages.length;

        smonthsLowestValue = tempSmonthsLowestValue.toStringAsFixed(2);
        smonthsHighestValue = tempSmonthsHighestValue.toStringAsFixed(2);
        // Average 6 months value
        smonthsAverage = smtemp.toStringAsFixed(2);
      } else {
        // All values are null or zero, set the values accordingly
        smonthsLowestValue = '0.00';
        smonthsHighestValue = '0.00';
        smonthsAverage = '0.00';
      }

      //Calculate one(1) year of heart data exluding zeros
      // Twelve (12) Months Heart Rate
      startIndex = 364;
      endIndex = 0;

      for (int i = 0; i < 12; i++) {
        for (int j = startIndex; j > endIndex; j--) {
          int? restingHeartRate =
              _heartData.getInt("restingHeartRate_${j}_${0}") ?? 0;

          if (restingHeartRate != 0) {
            sum += restingHeartRate;
            count++;
          }
        }

        double yaverage = count > 0 ? sum / count : 0;
        yearlyAverages[i] = double.parse(yaverage.toStringAsFixed(2));

        sum = 0;
        count = 0;
        startIndex = endIndex;
        endIndex -= 31;
      }

      List<double> yearlyFilteredAverages = monthlyAverages
          .where((value) => value != null && value != 0)
          .cast<double>()
          .toList();

      // Check if there are non-zero and non-null values
      double? tempYearsLowest, tempYearsHighest;
      if (yearlyFilteredAverages.isNotEmpty) {
        // Lowest 12 months value
        tempYearsLowest =
            yearlyFilteredAverages.reduce((a, b) => a < b ? a : b);
        // Highest 12 months value
        tempYearsHighest =
            yearlyFilteredAverages.reduce((a, b) => a > b ? a : b);
        double? ytemp = yearlyFilteredAverages.reduce((a, b) => a + b) /
            yearlyFilteredAverages.length;

        yearsLowestValue = tempYearsLowest.toStringAsFixed(2);
        yearsHighestValue = tempYearsHighest.toStringAsFixed(2);
        // Average 12 months value
        yearsAverage = ytemp.toStringAsFixed(2);
      } else {
        // All values are null or zero, set the values accordingly
        yearsLowestValue = '0.00';
        yearsHighestValue = '0.00';
        yearsAverage = '0.00';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Heart Rate Levels'),
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
                      h = true;
                      d = false;
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
                      } else if (h) {
                        return kSecondaryColor;
                      } else {
                        return kOtherColor;
                      }
                    }),
                    foregroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed) || h) {
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
                    'H',
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    setState(() {
                      h = false;
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
                      h = false;
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
                      h = false;
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
                      h = false;
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
                      h = false;
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
            //Hourly
            if (h) ...{
              Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ScreenHeader(title: '24hr Summary'),
                  ]),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HourlyHeartChart(),
                ],
              ),
              // SizedBox(height: 30),
              // Column(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.arrow_back_ios),
              //         SizedBox(width: 10),
              //         Text(
              //           'Scroll to view more data',
              //           style: TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.normal,
              //               color: kTextBlackColor.withOpacity(0.8)),
              //         ),
              //         SizedBox(width: 10),
              //         Icon(Icons.arrow_forward_ios),
              //       ],
              //     ),
              //   ],
              // )
            } else if (d) ...{
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
                        value: dailyRadialHeart,
                        gradientColors: [
                          kRedRingColor,
                          kRedRingColor,
                          kRedRingColor,
                          kRedRingColor,
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
                              title: 'Resting Heart Rate',
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
                            child: MoveNum(
                              title: '${restingHeartRates[364]} BPM',
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
                            child: MoveNum(
                              title: '${dailyLowestValue}',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: MoveNum(
                              title: '${dailyHighestValue}',
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
                          WeeklyHeartChart(),
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
                                  title: 'Average Heart Rate',
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
                                child: MoveNum(
                                  title: '$weeksAverage BPM',
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
                                child: MoveNum(
                                  title: '$weeksLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: MoveNum(
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
                          MonthlyHeartChart(),
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
                                  title: 'Average Heart Rate',
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
                                child: MoveNum(
                                  title: '$monthsAverage BPM',
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
                                child: MoveNum(
                                  title: '$monthsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: MoveNum(
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
                          SMonthHeartChart(),
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
                                  title: 'Average Heart Rate',
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
                                child: MoveNum(
                                  title: '$smonthsAverage BPM',
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
                                child: MoveNum(
                                  title: '$smonthsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: MoveNum(
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
                          YHeartChart(),
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
                                  title: 'Average Heart Rate',
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
                                child: MoveNum(
                                  title: '$yearsAverage BPM',
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
                                child: MoveNum(
                                  title: '$yearsLowestValue',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: MoveNum(
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

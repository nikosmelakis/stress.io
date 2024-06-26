import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:temp/screens/activity_screen/widgets/activity_widgets.dart';
import 'package:temp/screens/home_screen/widgets/app_widgets.dart';

bool d = true;
bool w = false;
bool m = false;
bool sm = false;
bool y = false;

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);
  static String routeName = 'ActivityScreen';

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);

  double? caloriesValue0 = 0;
  double? exerciseValue0 = 0;
  double? standValue0 = 0;
  double? stepsValue0 = 0;
  double? distanceValue0 = 0;
  double? floorsValue0 = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;

    setState(
      () {
        //Getting 1 year of dates
        for (int i = 0; i < 365; i++) {
          String? dateTime =
              _activityData.getString("dateTime_${i}_${0}") ?? 'NA';
          dateTimes[i] = dateTime;
        }

        //Getting daily activity data
        caloriesValue0 =
            _activityData.getDouble("caloriesValue_${364}_${0}") ?? 0;
        exerciseValue0 =
            _activityData.getDouble("exerciseValue_${364}_${0}") ?? 0;
        standValue0 = _activityData.getDouble("standValue_${364}_${0}") ?? 0;
        stepsValue0 = _activityData.getDouble("stepsValue_${364}_${0}") ?? 0;
        distanceValue0 =
            _activityData.getDouble("distanceValue_${364}_${0}") ?? 0;
        floorsValue0 = _activityData.getDouble("floorsValue_${364}_${0}") ?? 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Making values integers and .2 decimal doubles
    int finalCalories = caloriesValue0!.toInt();
    String finalKm = distanceValue0!.toStringAsFixed(2);
    int finalFloors = floorsValue0!.toInt();
    int finalExercise = exerciseValue0!.toInt();
    int tempStand = standValue0!.toInt();
    int finalSteps = stepsValue0!.toInt();

    // Turning minutes to hours minus avg sleep time
    double temp = (tempStand / 200);
    int finalStand = temp.toInt();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Activity'),
        shape: RoundedRectangleBorder(
          borderRadius: (kBottomBorderRadius * 2),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 5),
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
                      ;
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
                      ;
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
                      ;
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
                      ;
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

            //Daily
            if (d) ...{
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScreenHeader(title: '${dateTimes[364]}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActivityRing(),
                    ],
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Titles(
                              title: 'Move',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Titles(
                              title: 'Steps',
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
                              title: '$finalCalories KCLA',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: StepsValue(
                              title: '$finalSteps',
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
                              title: 'Exercise',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Titles(
                              title: 'Distance',
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
                            child: ExerciseNum(
                              title: '$finalExercise MINS',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: StepsValue(
                              title: '$finalKm KM',
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
                              title: 'Stand',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Titles(
                              title: 'Floors',
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
                            child: StandNum(
                              title: '$finalStand HRS',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: StepsValue(
                              title: '$finalFloors',
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [MoveNum(title: 'Move')],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyMoveChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ExerciseNum(
                            title: 'Exercise',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyExerciseChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StandNum(
                            title: 'Stand',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyStandChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Steps',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyStepsChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Distance',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyDistanceChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Floors',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeeklyFloorsChart(),
                        ],
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
                          Descr(title: '${dateTimes[334]} - ${dateTimes[364]}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [MoveNum(title: 'Move')],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MontlhyMoveChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ExerciseNum(
                            title: 'Exercise',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyExerciseChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StandNum(
                            title: 'Stand',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyStandChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Steps',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyStepsChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Distance',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyDistanceChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Floors',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MonthlyFloorsChart(),
                        ],
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [MoveNum(title: 'Move')],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsMoveChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ExerciseNum(
                            title: 'Exercise',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsExerciseChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StandNum(
                            title: 'Stand',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsStandChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Steps',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsStepsChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Distance',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsDistanceChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Floors',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SMonthsFloorsChart(),
                        ],
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [MoveNum(title: 'Move')],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearsMoveChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ExerciseNum(
                            title: 'Exercise',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearsExerciseChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          StandNum(
                            title: 'Stand',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearsStandChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Steps',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearStepsChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Distance',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearsDistanceChart(),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Titles(
                            title: 'Floors',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          YearFloorsChart(),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ],
              ),
            }
          ],
        ),
      ),
    );
  }
}

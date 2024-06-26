import 'dart:async';
import 'dart:math';
import 'package:fitbitter/fitbitter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/models/activiry-model.dart';
import 'package:temp/models/heart-data_model.dart';
import 'package:temp/models/hourly-heart-data.dart';
import 'package:temp/models/hrv-model.dart';
import 'package:temp/screens/activity_screen/activity_screen.dart';
import 'package:temp/screens/heart-rate_screen/heart-rate_screen.dart';
import 'package:temp/screens/stress_screen/widgets/stress_algorithm.dart';

//Used to check if fitbit is connected
bool _isAuthorized = false;
bool _isSyncing = false;

//For Username on home screen
class Username extends StatelessWidget {
  const Username({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Hello $username', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

//---------------------/

//Question text on home screen
class QuestionText extends StatelessWidget {
  const QuestionText({Key? key, required this.questionText}) : super(key: key);
  final String questionText;
  @override
  Widget build(BuildContext context) {
    return Text(questionText, style: Theme.of(context).textTheme.titleSmall);
  }
}

//---------------------/

//Profile Picture for home screen and profile screens
class UserPicture extends StatelessWidget {
  const UserPicture({
    Key? key,
    required this.imagePath,
    required this.onPress,
  }) : super(key: key);
  final String imagePath;
  final VoidCallback onPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: CircleAvatar(
        radius: SizerUtil.deviceType == DeviceType.tablet ? 12.w : 14.w,
        backgroundColor: kSecondaryColor,
        backgroundImage: AssetImage(imagePath),
      ),
    );
  }
}

//---------------------/
//Fitbit api connection and requests
class FitbitApiClient extends StatefulWidget {
  @override
  _FitbitApiClientState createState() => _FitbitApiClientState();
}

class _FitbitApiClientState extends State<FitbitApiClient> {
  String get _clientId => '23QSMS';
  String get _clientSecret => '004fbc6269161d71146f81c8a7da8d9a';
  String get _redirectUri => 'temp://callback';
  String get _callbackUrlScheme => 'temp';

  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  String? monitorDate = '';

  @override
  void initState() {
    super.initState();
    getDate();
  }

  Future<void> getDate() async {
    final SharedPreferences _ad = await _activity;

    setState(() {
      monitorDate = _ad.getString("dateTime_${364}_${0}")?.toString() ?? 'N/A';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 15.h,
      decoration: BoxDecoration(
        color: kOtherColor,
        borderRadius: BorderRadius.circular(kDefaultPadding * 2),
      ),
      child: TextButton(
        onPressed: () async {
          if (_isAuthorized) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fitbit is Updated!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                duration: Duration(milliseconds: 1700),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kPastelGreen,
                margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          } else {
            FitbitCredentials? fitbitCredentials =
                await FitbitConnector.authorize(
                    clientID: _clientId,
                    clientSecret: _clientSecret,
                    redirectUri: _redirectUri,
                    callbackUrlScheme: _callbackUrlScheme);
            if (fitbitCredentials != null) {
              setState(() {
                _isSyncing = true;
              });

              //---- Here we fetch the activity -------//

              //Initializng the day range of the data we want to fetch
              final startDate = DateTime.now();
              final endDate = startDate.subtract(Duration(days: 364));

              //Initializing Activity Timeseries data to fetch
              FitbitActivityTimeseriesDataManager
                  fitbitActivityTimeseriesDataManager =
                  FitbitActivityTimeseriesDataManager(
                clientID: _clientId,
                clientSecret: _clientSecret,
                type: '',
              );

              //calories
              final caloriesData =
                  await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'activityCalories',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              //distance traveled (km)
              final distanceData =
                  await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'distance',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              //floors
              final floorsData =
                  await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'floors',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              // minutes of exercise
              final exerciseData =
                  await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'minutesFairlyActive',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              //stading time
              final standData = await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'minutesSedentary',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              //steps
              final stepsData = await fitbitActivityTimeseriesDataManager.fetch(
                FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
                  fitbitCredentials: fitbitCredentials,
                  resource: 'steps',
                  startDate: startDate,
                  endDate: endDate,
                ),
              ) as List<FitbitActivityTimeseriesData>;

              // Accessing shared preferences
              final SharedPreferences _activity =
                  await SharedPreferences.getInstance();
              final SharedPreferences _activityData = await _activity;

              for (int i = 0; i < days; i++) {
                ActivityModel activityModel = ActivityModel(
                  // Dates
                  [caloriesData[i].dateOfMonitoring],
                  // Calories
                  [caloriesData[i].value],
                  // Distance
                  [distanceData[i].value],
                  // Floors
                  [floorsData[i].value],
                  // Exercise
                  [exerciseData[i].value],
                  // Stand
                  [standData[i].value],
                  // Steps
                  [stepsData[i].value],
                );
                // Formatting and storing the dates

                for (int j = 0; j < activityModel.dateTime.length; j++) {
                  DateTime? dateTime = activityModel.dateTime[j];
                  String formattedDate =
                      DateFormat('E dd MMM yyyy').format(dateTime!);
                  //
                  _activityData.setString("dateTime_${i}_${j}", formattedDate);
                  //
                  _activityData.setDouble("caloriesValue_${i}_${j}",
                      activityModel.caloriesValue[j] ?? 0);
                  //
                  _activityData.setDouble("distanceValue_${i}_${j}",
                      activityModel.distanceValue[j] ?? 0);
                  //
                  _activityData.setDouble("floorsValue_${i}_${j}",
                      activityModel.floorsValue[j] ?? 0);
                  //
                  _activityData.setDouble("exerciseValue_${i}_${j}",
                      activityModel.exerciseValue[j] ?? 0);
                  //
                  _activityData.setDouble(
                      "standValue_${i}_${j}", activityModel.standValue[j] ?? 0);
                  //
                  _activityData.setDouble(
                      "stepsValue_${i}_${j}", activityModel.stepsValue[j] ?? 0);
                }
              }

              //------//
              //Getting heart rate variability--//
              FitbitHeartRateVariabilityDataManager
                  fitbitHeartRateVariabilityDataManager =
                  FitbitHeartRateVariabilityDataManager(
                clientID: _clientId,
                clientSecret: _clientSecret,
              );

              //Beacuse hrv data is only given for a monthly range we have to
              // create seperated request for each month to cover a years data

              //1
              final variability1 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 29)),
                  endDate: DateTime.now(),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //2
              final variability2 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 59)),
                  endDate: DateTime.now().subtract(Duration(days: 30)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //3
              final variability3 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 89)),
                  endDate: DateTime.now().subtract(Duration(days: 60)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //4
              final variability4 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 119)),
                  endDate: DateTime.now().subtract(Duration(days: 90)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //5
              final variability5 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 149)),
                  endDate: DateTime.now().subtract(Duration(days: 120)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //6
              final variability6 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 179)),
                  endDate: DateTime.now().subtract(Duration(days: 150)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //7
              final variability7 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 199)),
                  endDate: DateTime.now().subtract(Duration(days: 180)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //8
              final variability8 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 219)),
                  endDate: DateTime.now().subtract(Duration(days: 200)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //9
              final variability9 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 239)),
                  endDate: DateTime.now().subtract(Duration(days: 220)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //10
              final variability10 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 259)),
                  endDate: DateTime.now().subtract(Duration(days: 240)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //11
              final variability11 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 289)),
                  endDate: DateTime.now().subtract(Duration(days: 260)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              //12
              final variability12 =
                  await fitbitHeartRateVariabilityDataManager.fetch(
                FitbitHeartRateVariabilityAPIURL.dateRange(
                  fitbitCredentials: fitbitCredentials,
                  startDate: DateTime.now().subtract(Duration(days: 319)),
                  endDate: DateTime.now().subtract(Duration(days: 290)),
                ),
              ) as List<FitbitHeartRateVariabilityData>;

              final variability = variability1 +
                  variability2 +
                  variability3 +
                  variability4 +
                  variability5 +
                  variability6 +
                  variability7 +
                  variability8 +
                  variability9 +
                  variability10 +
                  variability11 +
                  variability12;

              // Custom comparison function
              int compareByDateOfMonitoring(FitbitHeartRateVariabilityData a,
                  FitbitHeartRateVariabilityData b) {
                return a.dateOfMonitoring!
                    .compareTo(b.dateOfMonitoring ?? DateTime.now());
              }

              // Sort the list based on the dateOfMonitoring property
              variability.sort(compareByDateOfMonitoring);

              final SharedPreferences _hrv =
                  await SharedPreferences.getInstance();
              final SharedPreferences _hrvData = await _hrv;

              for (int i = 0; i < variability.length; i++) {
                HrvModel hrvModel = HrvModel(
                  [variability[i].dateOfMonitoring],
                  [variability[i].dailyRmssd],
                );
                for (int j = 0; j < hrvModel.hrv.length; j++) {
                  //
                  DateTime? dateTime = hrvModel.dateTime[j];
                  String formattedDate =
                      DateFormat('E dd MMM yyyy').format(dateTime!);
                  //
                  _hrvData.setString("dateTime_${i}_${j}", formattedDate);
                  //
                  _hrvData.setDouble("hrv_${i}_${j}", hrvModel.hrv[j] ?? 0);
                }
              }

              //-----//
              //Fetching heart rate data
              FitbitHeartDataManager fitbitHeartDataManager =
                  FitbitHeartDataManager(
                clientID: _clientId,
                clientSecret: _clientSecret,
              );

              final endDate2 = DateTime.now().subtract(Duration(days: 364));
              final startDate2 = DateTime.now();

              final heartData = await fitbitHeartDataManager
                  .fetch(FitbitHeartRateAPIURL.dateRange(
                fitbitCredentials: fitbitCredentials,
                startDate: startDate2,
                endDate: endDate2,
              )) as List<FitbitHeartRateData>;

              Future<SharedPreferences> _heart =
                  SharedPreferences.getInstance();
              final SharedPreferences _heartData = await _heart;

              for (int i = 0; i < days; i++) {
                HeartModel heartModel = HeartModel(
                  [heartData[i].restingHeartRate],
                );

                for (int j = 0; j < heartModel.restingHeartRate.length; j++) {
                  //
                  _heartData.setInt("restingHeartRate_${i}_${j}",
                      heartModel.restingHeartRate[j] ?? 0);
                }
              }

              //Fetching heart rate per minutes --//
              FitbitHeartRateIntradayDataManager
                  fitbitHeartRateIntradayDataManager =
                  FitbitHeartRateIntradayDataManager(
                clientID: _clientId,
                clientSecret: _clientSecret,
              );

              //Every 1 mins for the current date to use it for stress levels --//
              final perMinHeartRate =
                  await fitbitHeartRateIntradayDataManager.fetch(
                FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
                  date: DateTime.now(),
                  intradayDetailLevel: IntradayDetailLevel.ONE_MINUTE,
                  fitbitCredentials: fitbitCredentials,
                ),
              ) as List<FitbitHeartRateIntradayData>;

              Future<SharedPreferences> _heartPerMin =
                  SharedPreferences.getInstance();

              final SharedPreferences _heartPerMinData = await _heartPerMin;

              for (int i = 0; i < perMinHeartRate.length; i++) {
                PerMinHeartModel perMinheartModel = PerMinHeartModel(
                    [perMinHeartRate[i].dateOfMonitoring],
                    [perMinHeartRate[i].value]);

                for (int j = 0;
                    j < perMinheartModel.dailyHeartRate.length;
                    j++) {
                  //

                  DateTime? dateTime = perMinheartModel.dailyHeartHour[j];
                  String formattedDateTime =
                      DateFormat('yyyy-MM-dd HH:mm').format(dateTime!);

                  _heartPerMinData.setString(
                      "dailyHeartHour_${i}_${j}", formattedDateTime);
                  _heartPerMinData.setDouble("dailyHeartRate_${i}_${j}",
                      perMinheartModel.dailyHeartRate[j] ?? 0);
                }
              }

              //
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Authetication Failed!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(milliseconds: 1700),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: kErrorBorderColor,
                  margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }
          }
          Future.delayed(Duration(milliseconds: 1), () {
            setState(() {
              _isAuthorized = true;
              _isSyncing = false;
            });
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 6),
            Text(
              'Last Sync: $monitorDate',
              style: TextStyle(
                fontSize: 10,
                color: kTextBlackColor,
              ),
            ),
            SizedBox(height: 8),
            ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.teal.shade300, Colors.teal.shade500],
                ).createShader(bounds);
              },
              child: Image.asset(
                'assets/icons/fitbit-icon.png',
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(height: 8),
            _isSyncing
                ? Column(
                    children: [
                      Center(
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15.0,
                                height: 15.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Colors.teal,
                                ),
                              ),
                              Text(
                                '  Syncing...',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: kTextBlackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    _isAuthorized ? 'Synced' : 'Offline',
                    style: TextStyle(
                      fontSize: 15,
                      color: _isAuthorized
                          ? Colors.teal.shade300
                          : kErrorBorderColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

//---------------------/

//Acitivy Ring Widget
class RingPanel extends StatefulWidget {
  const RingPanel({Key? key}) : super(key: key);

  @override
  State<RingPanel> createState() => _RingPanelState();
}

class _RingPanelState extends State<RingPanel> {
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
      width: 42.w,
      height: 15.h,
      decoration: BoxDecoration(
        color: kOtherColor,
        borderRadius: BorderRadius.circular(kDefaultPadding * 2),
      ),
      child: SfCircularChart(
        onChartTouchInteractionDown: (ChartTouchInteractionArgs args) {
          Navigator.pushNamed(context, ActivityScreen.routeName);
        },
        series: <CircularSeries>[
          // Renders radial bar chart
          RadialBarSeries<RingData, String>(
            animationDelay: 0,
            animationDuration: 1500,
            useSeriesColor: true,
            trackOpacity: 0.5,
            cornerStyle: CornerStyle.bothCurve,
            pointColorMapper: (RingData data, _) => data.color,
            dataSource: ringData,
            xValueMapper: (RingData data, _) => data.x,
            yValueMapper: (RingData data, _) => data.y,
            maximumValue: 8,
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

//HeartRate Screen and Stress Screen Header
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 0.h),
        width: 90.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Title for Heart-Rate Chart for Home Screen
class HeartRateHeader extends StatelessWidget {
  const HeartRateHeader(
      {Key? key,
      required this.onPress,
      required this.image,
      required this.title})
      : super(key: key);

  final VoidCallback onPress;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(top: 1.h),
        width: 90.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: SizerUtil.deviceType == DeviceType.tablet ? 40.sp : 15.sp,
              width: SizerUtil.deviceType == DeviceType.tablet ? 40.sp : 15.sp,
              color: kRedRingColor,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Weekly Heart Rate Home Screen
class HomeWeeklyHeartChart extends StatefulWidget {
  const HomeWeeklyHeartChart({Key? key}) : super(key: key);

  @override
  State<HomeWeeklyHeartChart> createState() => _HomeWeeklyHeartChartState();
}

class _HomeWeeklyHeartChartState extends State<HomeWeeklyHeartChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> restingHeartRates = List<int?>.filled(365, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;

    setState(() {
      //Getting 1 week of dates
      for (int i = 364; i > 357; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
      }

      //Getting 1 weeks of days
      for (int i = 364; i > 357; i--) {
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
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

    List<WeeklyHeartData> weeklyHeartData = [];
    for (int i = 6; i >= 0; i--) {
      int index = 364 - i;
      weeklyHeartData
          .add(WeeklyHeartData(finalDates[i], restingHeartRates[index]));
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
          onChartTouchInteractionDown: (ChartTouchInteractionArgs args) {
            Navigator.pushNamed(context, HeartRateScreen.routeName);
          },
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(isVisible: false),
          plotAreaBorderWidth: 0,
          series: <ChartSeries>[
            ColumnSeries<WeeklyHeartData, String>(
              animationDelay: 100,
              animationDuration: 2000,
              color: kRedRingColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: weeklyHeartData,
              xValueMapper: (WeeklyHeartData data, String) => data.x,
              yValueMapper: (WeeklyHeartData data, _) => data.y,
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

class WeeklyHeartData {
  WeeklyHeartData(this.x, this.y);
  final String? x;
  final int? y;
}

//tress Levels Home Screen
//Weekly Heart Rate
class HomeWeeklyStressChart extends StatefulWidget {
  const HomeWeeklyStressChart({Key? key}) : super(key: key);

  @override
  State<HomeWeeklyStressChart> createState() => _HomeWeeklyStressChartState();
}

class _HomeWeeklyStressChartState extends State<HomeWeeklyStressChart> {
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

//---------------------/

//Title for Stress-Levels Chart for Home Screen
class StressLevelsHeader extends StatelessWidget {
  const StressLevelsHeader(
      {Key? key,
      required this.onPress,
      required this.image,
      required this.title})
      : super(key: key);

  final VoidCallback onPress;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(top: 1.h),
        width: 90.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kDefaultPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: SizerUtil.deviceType == DeviceType.tablet ? 40.sp : 17.sp,
              width: SizerUtil.deviceType == DeviceType.tablet ? 40.sp : 17.sp,
              color: kSecondaryColor,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------/

//Headers for Every Screen through the app
class Headers extends StatelessWidget {
  const Headers({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Titles for Every Screen through the app
class Titles extends StatelessWidget {
  const Titles({Key? key, required this.title}) : super(key: key);
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
                  fontSize: 20,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Descr for Every Screen through the app
class Descr extends StatelessWidget {
  const Descr({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 0.h, bottom: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 16,
                  color: kTextBlackColor,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

//Daily Gauge Radial in Daily Heart and Stress
class GaugeRadial extends StatefulWidget {
  final double radius;
  final double strokeWidth;
  final List<Color> gradientColors;
  final double value;
  final double trackOpacity;
  final Duration duration;

  GaugeRadial({
    required this.radius,
    required this.strokeWidth,
    required this.gradientColors,
    required this.value,
    this.trackOpacity = 0.5,
    required this.duration,
  });

  @override
  _GaugeRadialState createState() => _GaugeRadialState();
}

class _GaugeRadialState extends State<GaugeRadial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation =
        Tween<double>(begin: 0, end: widget.value).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _GaugeRadialPainter(
            radius: widget.radius,
            strokeWidth: widget.strokeWidth,
            gradientColors: widget.gradientColors,
            value: _animation.value,
            trackOpacity: widget.trackOpacity,
          ),
        );
      },
    );
  }
}

class _GaugeRadialPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final List<Color> gradientColors;
  final double value;
  final double trackOpacity;

  _GaugeRadialPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradientColors,
    required this.value,
    required this.trackOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final startAngle = -3 * pi / 2 + pi / 4;
    final endAngle = pi / 4;

    final opacityAngle = 2 * pi - pi / 2;
    final sweepAngle = (endAngle - startAngle) * value;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Apply linear gradient to the paint object
    final gradient = LinearGradient(
      colors: gradientColors,
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );
    paint.shader = gradient.createShader(path.getBounds());

    canvas.drawPath(path, paint);

    // Draw the track (background) path
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey.withOpacity(0.3);

    final trackPath = Path();
    trackPath.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      opacityAngle,
    );

    canvas.drawPath(trackPath, trackPaint);
  }

  @override
  bool shouldRepaint(_GaugeRadialPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.value != value ||
        oldDelegate.trackOpacity != trackOpacity;
  }
}

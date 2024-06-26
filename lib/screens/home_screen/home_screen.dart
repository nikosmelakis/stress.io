import 'dart:io';

import 'package:fitbitter/fitbitter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/models/activiry-model.dart';
import 'package:temp/models/heart-data_model.dart';
import 'package:temp/models/hourly-heart-data.dart';
import 'package:temp/models/hrv-model.dart';
import 'package:temp/screens/heart-rate_screen/heart-rate_screen.dart';
import 'package:temp/screens/profile_screen/my_profile.dart';
import 'package:temp/screens/home_screen/widgets/app_widgets.dart';
import 'dart:async';
import 'package:temp/screens/stress_screen/stress_screen.dart';

void main() => runApp(MaterialApp(home: HomeScreen()));

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();

  String? monitorDate = '';
  String fName = "";
  String profile = "assets/images/profile.png";
  late Widget avatar = Container(height: 160);

  Future<void> _getUserData() async {
    final SharedPreferences sp = await _pref;
    final SharedPreferences _actvityData = await _activity;

    setState(() {
      fName = sp.getString("fname")!;
      profile = sp.getString("img")!;
      monitorDate = _actvityData.getString("dateTime_${0}")?.toString() ?? null;
    });
  }

  @override
  void initState() {
    _getUserData().then((_) {
      avatar = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          backgroundImage: profile == "assets/images/profile.png"
              ? AssetImage(profile)
              : FileImage(File(profile)) as ImageProvider<Object>?);
    });
    super.initState();
  }

  Future<void> _refreshData() async {
    await _updateData(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Container(
            width: 100.w,
            height: 44.h,
            padding: EdgeInsets.all(kDefaultPadding / 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Username(
                          username: '$fName',
                        ),
                        kHalfSizedBox,
                        QuestionText(questionText: 'How you feeling today?'),
                      ],
                    ),
                    kHalfSizedBox,
                    UserPicture(
                      imagePath: profile,
                      onPress: () {
                        Navigator.pushNamed(context, MyProfileScreen.routeName);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FitbitApiClient(),
                    RingPanel(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshData,
              color: kSecondaryColor,
              backgroundColor: kOtherColor,
              strokeWidth: 2.0,
              displacement: 10,
              child: GestureDetector(
                child: Container(
                  width: 100.w,
                  height: 300.h,
                  decoration: BoxDecoration(
                    color: kOtherColor,
                    borderRadius: kTopBorderRadius * 3,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 23.0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 15),
                          HeartRateHeader(
                            onPress: () {
                              Navigator.pushNamed(
                                  context, HeartRateScreen.routeName);
                            },
                            image: 'assets/icons/heart_outline.png',
                            title: ' Heart Rate',
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeWeeklyHeartChart(),
                            ],
                          ),
                          StressLevelsHeader(
                            onPress: () {
                              Navigator.pushNamed(
                                  context, StressScreen.routeName);
                            },
                            image: 'assets/icons/stress.png',
                            title: ' Stress Levels',
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeWeeklyStressChart(),
                            ],
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Fitbit API
Future<void> _updateData(Function callback) async {
  String _clientId = '23QSMS';
  String _clientSecret = '004fbc6269161d71146f81c8a7da8d9a';
  String _redirectUri = 'temp://callback';
  String _callbackUrlScheme = 'temp';

  FitbitCredentials? fitbitCredentials = await FitbitConnector.authorize(
      clientID: _clientId,
      clientSecret: _clientSecret,
      redirectUri: _redirectUri,
      callbackUrlScheme: _callbackUrlScheme);

  if (fitbitCredentials != null) {
    //Initializng the day range of the data we want to fetch
    final currentDate = DateTime.now();
    final endDate = currentDate.subtract(Duration(days: 364));
    final startDate = currentDate;

    //Initializing Activity Timeseries data to fetch
    FitbitActivityTimeseriesDataManager fitbitActivityTimeseriesDataManager =
        FitbitActivityTimeseriesDataManager(
      clientID: _clientId,
      clientSecret: _clientSecret,
      type: '',
    );

    final caloriesData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'activityCalories',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    final distanceData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'distance',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    final floorsData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'floors',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    final exerciseData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'minutesFairlyActive',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    final standData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'minutesSedentary',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    final stepsData = await fitbitActivityTimeseriesDataManager.fetch(
      FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
        fitbitCredentials: fitbitCredentials,
        resource: 'steps',
        startDate: startDate,
        endDate: endDate,
      ),
    ) as List<FitbitActivityTimeseriesData>;

    // Accessing shared preferences
    final SharedPreferences _activity = await SharedPreferences.getInstance();
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
        //

        DateTime? dateTime = activityModel.dateTime[j];
        String formattedDate = DateFormat('E dd MMM yyyy').format(dateTime!);

        _activityData.setString("dateTime_${i}_${j}", formattedDate);
        //
        _activityData.setDouble(
            "caloriesValue_${i}_${j}", activityModel.caloriesValue[j] ?? 0);
        //

        //
        _activityData.setDouble(
            "distanceValue_${i}_${j}", activityModel.distanceValue[j] ?? 0);
        //
        _activityData.setDouble(
            "floorsValue_${i}_${j}", activityModel.floorsValue[j] ?? 0);
        //
        _activityData.setDouble(
            "exerciseValue_${i}_${j}", activityModel.exerciseValue[j] ?? 0);
        //
        _activityData.setDouble(
            "standValue_${i}_${j}", activityModel.standValue[j] ?? 0);
        //
        _activityData.setDouble(
            "stepsValue_${i}_${j}", activityModel.stepsValue[j] ?? 0);
      }
    }

    //------//
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
    final variability1 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 29)),
        endDate: DateTime.now(),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //2
    final variability2 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 59)),
        endDate: DateTime.now().subtract(Duration(days: 30)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //3
    final variability3 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 89)),
        endDate: DateTime.now().subtract(Duration(days: 60)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //4
    final variability4 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 119)),
        endDate: DateTime.now().subtract(Duration(days: 90)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //5
    final variability5 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 149)),
        endDate: DateTime.now().subtract(Duration(days: 120)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //6
    final variability6 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 179)),
        endDate: DateTime.now().subtract(Duration(days: 150)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //7
    final variability7 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 199)),
        endDate: DateTime.now().subtract(Duration(days: 180)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //8
    final variability8 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 219)),
        endDate: DateTime.now().subtract(Duration(days: 200)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //9
    final variability9 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 239)),
        endDate: DateTime.now().subtract(Duration(days: 220)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //10
    final variability10 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 259)),
        endDate: DateTime.now().subtract(Duration(days: 240)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //11
    final variability11 = await fitbitHeartRateVariabilityDataManager.fetch(
      FitbitHeartRateVariabilityAPIURL.dateRange(
        fitbitCredentials: fitbitCredentials,
        startDate: DateTime.now().subtract(Duration(days: 289)),
        endDate: DateTime.now().subtract(Duration(days: 260)),
      ),
    ) as List<FitbitHeartRateVariabilityData>;

    //12
    final variability12 = await fitbitHeartRateVariabilityDataManager.fetch(
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

    final SharedPreferences _hrv = await SharedPreferences.getInstance();
    final SharedPreferences _hrvData = await _hrv;

    for (int i = 0; i < variability.length; i++) {
      HrvModel hrvModel = HrvModel(
        [variability[i].dateOfMonitoring],
        [variability[i].dailyRmssd],
      );
      for (int j = 0; j < hrvModel.hrv.length; j++) {
        //
        DateTime? dateTime = hrvModel.dateTime[j];
        String formattedDate = DateFormat('E dd MMM yyyy').format(dateTime!);
        //
        _hrvData.setString("dateTime_${i}_${j}", formattedDate);
        //
        _hrvData.setDouble("hrv_${i}_${j}", hrvModel.hrv[j] ?? 0);
      }
    }
    //----//

    //Fetching heart data for weekly, monthly and yearly
    FitbitHeartDataManager fitbitHeartDataManager = FitbitHeartDataManager(
      clientID: _clientId,
      clientSecret: _clientSecret,
    );

    final endDate2 = DateTime.now().subtract(Duration(days: 364));
    final startDate2 = DateTime.now();

    final heartData =
        await fitbitHeartDataManager.fetch(FitbitHeartRateAPIURL.dateRange(
      fitbitCredentials: fitbitCredentials,
      startDate: startDate2,
      endDate: endDate2,
    )) as List<FitbitHeartRateData>;

    Future<SharedPreferences> _heart = SharedPreferences.getInstance();
    final SharedPreferences _heartData = await _heart;

    for (int i = 0; i < days; i++) {
      HeartModel heartModel = HeartModel(
        [heartData[i].restingHeartRate],
      );

      for (int j = 0; j < heartModel.restingHeartRate.length; j++) {
        //
        _heartData.setInt(
            "restingHeartRate_${i}_${j}", heartModel.restingHeartRate[j] ?? 0);
      }
    }

    //Fetching heart rate per minutes --//
    FitbitHeartRateIntradayDataManager fitbitHeartRateIntradayDataManager =
        FitbitHeartRateIntradayDataManager(
      clientID: _clientId,
      clientSecret: _clientSecret,
    );

    //Every 1 mins for the current date to use it for stress levels --//
    final perMinHeartRate = await fitbitHeartRateIntradayDataManager.fetch(
      FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
        date: DateTime.now(),
        intradayDetailLevel: IntradayDetailLevel.ONE_MINUTE,
        fitbitCredentials: fitbitCredentials,
      ),
    ) as List<FitbitHeartRateIntradayData>;

    Future<SharedPreferences> _heartPerMin = SharedPreferences.getInstance();

    final SharedPreferences _heartPerMinData = await _heartPerMin;

    for (int i = 0; i < perMinHeartRate.length; i++) {
      PerMinHeartModel perMinheartModel = PerMinHeartModel(
          [perMinHeartRate[i].dateOfMonitoring], [perMinHeartRate[i].value]);

      for (int j = 0; j < perMinheartModel.dailyHeartRate.length; j++) {
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
    callback();
  } else
    SnackBar(
      content: Text(
        'Something went wrong. Try again later!',
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
    );
}

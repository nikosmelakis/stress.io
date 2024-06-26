import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:temp/models/hourly-heart-data.dart';
import '../../../constants.dart';

//Hourly Heart Chart
//Shows the last 24hrs values only
class HourlyHeartChart extends StatefulWidget {
  const HourlyHeartChart({Key? key}) : super(key: key);

  @override
  State<HourlyHeartChart> createState() => _HourlyHeartChartState();
}

class _HourlyHeartChartState extends State<HourlyHeartChart> {
  Future<SharedPreferences> _perMinHeart = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(minutes, null);
  List<double?> minHeartRates = List<double?>.filled(minutes, null);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences _perMinHeartData = await _perMinHeart;

    setState(() {
      //Getting exact time of heartrate
      for (int i = 0; i < minutes; i += 10) {
        String? dateTime =
            _perMinHeartData.getString("dailyHeartHour_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;
      }
      for (int i = 0; i < minutes; i += 1) {
        double? minHeartRate =
            _perMinHeartData.getDouble("dailyHeartRate_${i}_${0}") ?? 0;
        minHeartRates[i] = minHeartRate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 0; i < minutes; i += 1) {
      String tempDate = dateTimes[i].toString();
      String tempDate2 =
          tempDate.length >= 16 ? tempDate.substring(0, 16) : tempDate;
      finalDates.add(tempDate2);
      finalDates.sort();
    }

    List<HourlyHeartData> hourlyHeartData = [];
    for (int i = 0; i < minutes; i++) {
      String tempDate = finalDates[i];
      String finalDate =
          tempDate.length >= 16 ? tempDate.substring(10, 16) : tempDate;
      if (finalDate != 'N/A' && finalDate != 'null') {
        hourlyHeartData.add(HourlyHeartData(finalDate, minHeartRates[i]));
      } else {}
    }

    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width, // Set a larger width
        child: Scrollbar(
          trackVisibility: true,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.down,
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: EdgeInsets.only(bottom: 25),
              controller: ScrollController(),
              child: Container(
                width: 300.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(kDefaultPadding),
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(isVisible: false),
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.y',
                  ),
                  series: <ChartSeries>[
                    BubbleSeries<HourlyHeartData, String>(
                      name: 'BPM',
                      color: kRedRingColor,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: false,
                        textStyle: TextStyle(color: kTextBlackColor),
                        labelAlignment: ChartDataLabelAlignment.outer,
                      ),
                      opacity: 1.0,
                      dataSource: hourlyHeartData,
                      xValueMapper: (HourlyHeartData data, String) => data.x,
                      yValueMapper: (HourlyHeartData data, _) => data.y,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HourlyHeartData {
  HourlyHeartData(this.x, this.y);
  final String x;
  final double? y;
}

//Weekly Heart Rate
class WeeklyHeartChart extends StatefulWidget {
  const WeeklyHeartChart({Key? key}) : super(key: key);

  @override
  State<WeeklyHeartChart> createState() => _WeeklyHeartChartState();
}

class _WeeklyHeartChartState extends State<WeeklyHeartChart> {
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
        //Getting 1 week od resting heart rates
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
            ColumnSeries<WeeklyHeartData, String>(
              name: 'BPM',
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

//Monthly HeartRate
class MonthlyHeartChart extends StatefulWidget {
  const MonthlyHeartChart({Key? key}) : super(key: key);

  @override
  State<MonthlyHeartChart> createState() => _MonthlyHeartChartState();
}

class _MonthlyHeartChartState extends State<MonthlyHeartChart> {
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
      //Getting 1 month dates
      for (int i = 364; i > 332; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;

        //Getting 1 month heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
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

    List<MonthlyHeartData> monthlyHeartData = [];
    for (int i = 2; i <= 31; i++) {
      int index = 333 + i;
      int temp = 31 - i;
      monthlyHeartData
          .add(MonthlyHeartData(finalDates[temp], restingHeartRates[index]));
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
            ColumnSeries<MonthlyHeartData, String>(
              name: 'BPM',
              animationDelay: 100,
              animationDuration: 2000,
              color: kRedRingColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: monthlyHeartData,
              xValueMapper: (MonthlyHeartData data, String) => data.x,
              yValueMapper: (MonthlyHeartData data, _) => data.y,
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

class MonthlyHeartData {
  MonthlyHeartData(this.x, this.y);
  final String x;
  final int? y;
}

//6 Months HeartRate
class SMonthHeartChart extends StatefulWidget {
  const SMonthHeartChart({Key? key}) : super(key: key);

  @override
  State<SMonthHeartChart> createState() => _SMonthHeartChartState();
}

class _SMonthHeartChartState extends State<SMonthHeartChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> monthlyAverages = List<double?>.filled(6, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;

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

      int sum = 0;
      int count = 0;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> finalDates = [];
    for (int i = 364; i > 183; i -= 32) {
      String tempDate = dateTimes[i].toString();
      String finalDate =
          tempDate.length >= 11 ? tempDate.substring(7, 10) : tempDate;
      finalDates.add(finalDate);
    }

    int temp = 6;
    int index = 5;
    List<SMonthsHeartData> sMonthsHeartData = [];
    for (int i = 0; i <= 184; i += 31) {
      temp -= 1;
      sMonthsHeartData
          .add(SMonthsHeartData(finalDates[temp], monthlyAverages[index]));
      index--;
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
            ColumnSeries<SMonthsHeartData, String>(
              name: 'AVG BPM',
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
              dataSource: sMonthsHeartData,
              xValueMapper: (SMonthsHeartData data, String) => data.x,
              yValueMapper: (SMonthsHeartData data, _) => data.y,
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

class SMonthsHeartData {
  SMonthsHeartData(this.x, this.y);
  final String x;
  final double? y;
}

//1 Year HeartRate
class YHeartChart extends StatefulWidget {
  const YHeartChart({Key? key}) : super(key: key);

  @override
  State<YHeartChart> createState() => _YHeartChartState();
}

class _YHeartChartState extends State<YHeartChart> {
  //Requesting the data needed to print on the column chart
  Future<SharedPreferences> _activity = SharedPreferences.getInstance();
  Future<SharedPreferences> _heart = SharedPreferences.getInstance();

  List<String?> dateTimes = List<String?>.filled(365, null);
  List<int?> restingHeartRates = List<int?>.filled(365, null);
  List<double?> yearlyAverages = List<double?>.filled(12, null);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final SharedPreferences _activityData = await _activity;
    final SharedPreferences _heartData = await _heart;

    setState(() {
      // Getting 1 year dates
      for (int i = 364; i >= 0; i--) {
        String? dateTime =
            _activityData.getString("dateTime_${i}_${0}") ?? 'N/A';
        dateTimes[i] = dateTime;

        // Getting 1 year heart rates
        int? restingHeartRate =
            _heartData.getInt("restingHeartRate_${i}_${0}") ?? 0;
        restingHeartRates[i] = restingHeartRate;
      }

      int sum = 0;
      int count = 0;
      int startIndex = 364;
      int endIndex = 332;

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
    List<YHeartData> yHeartData = [];
    for (int i = 0; i <= 364; i += 31) {
      temp -= 1;
      yHeartData.add(YHeartData(finalDates[temp], yearlyAverages[index]));
      index--;
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
            ColumnSeries<YHeartData, String>(
              name: 'AVG BPM',
              animationDelay: 100,
              animationDuration: 2000,
              color: kRedRingColor,
              isTrackVisible: false,
              trackBorderColor: kTextBlackColor,
              dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: kTextBlackColor),
                  labelAlignment: ChartDataLabelAlignment.outer),
              opacity: 1.0,
              dataSource: yHeartData,
              xValueMapper: (YHeartData data, String) => data.x,
              yValueMapper: (YHeartData data, _) => data.y,
              width: 0.3,
              spacing: 0.2,
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

class YHeartData {
  YHeartData(this.x, this.y);
  final String x;
  final double? y;
}

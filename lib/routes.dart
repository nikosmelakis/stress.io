import 'package:temp/screens/activity_screen/activity_screen.dart';
import 'package:temp/screens/auth_screen/login_screen.dart';
import 'package:temp/screens/auth_screen/register_screen.dart';
import 'package:temp/screens/auth_screen/forgot_screen.dart';
import 'package:temp/screens/heart-rate_screen/heart-rate_screen.dart';
import 'package:temp/screens/profile_screen/edit_profile.dart';
import 'package:temp/screens/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:temp/my_nav_bar.dart';
import 'package:temp/screens/stress_screen/stress_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/profile_screen/profile_info.dart';
import 'screens/profile_screen/my_profile.dart';

Map<String, WidgetBuilder> routes = {
  //all screens will be registered here
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  MyNavBar.routeName: (context) => MyNavBar(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  ForgotScreen.routeName: (context) => ForgotScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  MyProfileScreen.routeName: (context) => MyProfileScreen(),
  ProfileInfo.routeName: (context) => ProfileInfo(),
  EditMyProfile.routeName: (context) => EditMyProfile(),
  ActivityScreen.routeName: (context) => ActivityScreen(),
  HeartRateScreen.routeName: (context) => HeartRateScreen(),
  StressScreen.routeName: (context) => StressScreen(),
};

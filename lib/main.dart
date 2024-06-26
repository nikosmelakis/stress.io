import 'package:provider/provider.dart';
import 'package:temp/constants.dart';
import 'package:temp/models/change-profile_model.dart';
import 'package:temp/routes.dart';
import 'package:temp/screens/splash_screen/splash_screen.dart';
import 'package:temp/theme.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
        // ignore: deprecated_member_use
        builder: (context, orientation, device) => WillPopScope(
              child: ChangeNotifierProvider(
                create: (context) => EventProvider(),
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Stress.io',
                  theme: CustomTheme().baseTheme,
                  //initial route is splash screen
                  initialRoute: SplashScreen.routeName,
                  color: kSplashColor,
                  //defining the routes file here
                  routes: routes,
                ),
              ),
              onWillPop: () async {
                return false;
              },
            ));
  }
}


// Run this command on terminal to see how many lines of code the whole project is
// As of 10 Oct 2023 the code is 11197 lines in total
// (For macOS)
// loc --exclude ".*\.g\.dart" | grep Dart | tr -s ' ' | cut -d ' ' -f 7

//demo account
//info@nikosmelakis.com
//ThisIsAP4ssword!
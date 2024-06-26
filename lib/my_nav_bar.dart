// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:temp/constants.dart';
// import 'package:temp/screens/activity_screen/activity_screen.dart';
// import 'package:temp/screens/heart-rate_screen/heart-rate_screen.dart';
// import 'package:temp/screens/home_screen/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:temp/screens/profile_screen/my_profile.dart';
// import 'package:temp/screens/stress_screen/stress_screen.dart';
// import 'package:unicons/unicons.dart';

// class MyNavBar extends StatefulWidget {
//   const MyNavBar({Key? key}) : super(key: key);
//   static String routeName = 'MyNavBar';

//   @override
//   _MyNavBarState createState() => _MyNavBarState();
// }

// class _MyNavBarState extends State<MyNavBar> {
//   int _currentIndex = 0;

//   void changePage(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   final pages = [
//     const HomeScreen(),
//     ActivityScreen(),
//     HeartRateScreen(),
//     StressScreen(),
//     MyProfileScreen()
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       body: pages[_currentIndex],
//       bottomNavigationBar: CurvedNavigationBar(
//         // key: _bottomNavigationKey,
//         index: 0,
//         height: 75.0,
//         items: <Widget>[
//           //BackUp
//           Icon(UniconsLine.estate, size: 30),
//           Icon(CupertinoIcons.chart_pie, size: 30),
//           Icon(UniconsLine.heart_alt, size: 30),
//           Icon(UniconsLine.clipboard, size: 30),
//           Icon(UniconsLine.user, size: 30),
//         ],
//         color: kPrimaryColor,
//         buttonBackgroundColor: kPrimaryColor,
//         backgroundColor: Colors.transparent,
//         animationCurve: Curves.easeInOut,
//         animationDuration: Duration(milliseconds: 400),
//         onTap: changePage,
//         letIndexChange: (index) => true,
//       ),
//     );
//   }
// }

//!Another nav bar

import 'package:flutter/cupertino.dart';
import 'package:temp/constants.dart';
import 'package:temp/screens/activity_screen/activity_screen.dart';
import 'package:temp/screens/heart-rate_screen/heart-rate_screen.dart';
import 'package:temp/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:temp/screens/profile_screen/my_profile.dart';
import 'package:temp/screens/stress_screen/stress_screen.dart';
import 'package:unicons/unicons.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class MyNavBar extends StatefulWidget {
  const MyNavBar({Key? key}) : super(key: key);
  static String routeName = 'MyNavBar';

  @override
  _MyNavBarState createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    ActivityScreen(),
    HeartRateScreen(),
    StressScreen(),
    MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 50,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
          child: FloatingNavbar(
            iconSize: 25,
            backgroundColor: kOtherColor,
            selectedItemColor: kSecondaryColor,
            unselectedItemColor: kContainerColor,
            selectedBackgroundColor: kPrimaryColor,
            elevation: 0.0,
            borderRadius: 35,
            itemBorderRadius: 50,
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              FloatingNavbarItem(icon: UniconsLine.home_alt),
              FloatingNavbarItem(icon: CupertinoIcons.chart_pie),
              FloatingNavbarItem(icon: UniconsLine.heart_sign),
              FloatingNavbarItem(icon: UniconsLine.clipboard_alt),
              FloatingNavbarItem(icon: UniconsLine.user),
            ],
          ),
        ),
      ),
    );
  }
}

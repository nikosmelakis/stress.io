import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/screens/auth_screen/login_screen.dart';
import 'package:temp/screens/profile_screen/profile_info.dart';
import 'package:unicons/unicons.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);
  static String routeName = 'MyProfileScreen';

  @override
  // ignore: library_private_types_in_public_api
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  String fName = "";
  String lName = "";
  String profile = "assets/images/profile.png";
  late Widget avatar = Container(height: 160);

  @override
  void initState() {
    getUserData().then((_) {
      avatar = Container(
        child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black,
            backgroundImage: profile == "assets/images/profile.png"
                ? AssetImage(profile)
                : FileImage(File(profile)) as ImageProvider<Object>?),
      );
    });
    super.initState();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      fName = sp.getString("fname")!;
      lName = sp.getString("lname")!;
      profile = sp.getString("img")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            width: 100.w,
            height: SizerUtil.deviceType == DeviceType.tablet ? 19.h : 15.h,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: kBottomBorderRadius * 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Stack(
                    children: [avatar],
                  ),
                ),
                kWidthSizedBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$fName $lName',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 100.w,
              height: 10.h,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                //for padding
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, ProfileInfo.routeName);
                            },
                            icon: Icon(
                              UniconsLine.user,
                              size: 24.0,
                              color: kTextBlackColor,
                            ),
                            label: Text(
                              'Account Setings',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: kTextBlackColor,
                                  fontWeight: FontWeight.w300),
                            ),
                            style: TextButton.styleFrom(
                                foregroundColor: kOtherColor),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            UniconsLine.watch,
                            size: 24.0,
                            color: kTextBlackColor,
                          ),
                          label: Text(
                            'Connect Fitbit',
                            style: TextStyle(
                                fontSize: 24.0,
                                color: kTextBlackColor,
                                fontWeight: FontWeight.w300),
                          ),
                          style: TextButton.styleFrom(
                              foregroundColor: kOtherColor),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            UniconsLine.file_edit_alt,
                            size: 24.0,
                            color: kTextBlackColor,
                          ),
                          label: Text(
                            'Statistics',
                            style: TextStyle(
                                fontSize: 24.0,
                                color: kTextBlackColor,
                                fontWeight: FontWeight.w300),
                          ),
                          style: TextButton.styleFrom(
                              foregroundColor: kOtherColor),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            UniconsLine.info_circle,
                            size: 24.0,
                            color: kTextBlackColor,
                          ),
                          label: Text(
                            'Information',
                            style: TextStyle(
                                fontSize: 24.0,
                                color: kTextBlackColor,
                                fontWeight: FontWeight.w300),
                          ),
                          style: TextButton.styleFrom(
                              foregroundColor: kOtherColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 80.w,
                      child: Divider(
                        thickness: 1.0,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            //Function to clear or reset shared preferences
                            Future<void> clearPreferences() async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                            }

                            // Usage when logging out
                            // Clear or reset shared preferences
                            clearPreferences().then((_) {
                              // Shared preferences cleared successfully
                              // Perform any additional logout actions if needed
                            }).catchError((error) {
                              // Error occurred while clearing shared preferences
                              // Handle the error appropriately
                            });

                            Navigator.pushNamedAndRemoveUntil(context,
                                LoginScreen.routeName, (route) => false);
                          },
                          icon: Icon(
                            UniconsLine.exit,
                            size: 24.0,
                            color: kRedRingColor,
                          ),
                          label: Text(
                            'Log Out',
                            style: TextStyle(
                                fontSize: 24.0,
                                color: kRedRingColor,
                                fontWeight: FontWeight.w300),
                          ),
                          style: TextButton.styleFrom(
                              foregroundColor: kOtherColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

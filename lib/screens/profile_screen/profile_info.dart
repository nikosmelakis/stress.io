import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/screens/profile_screen/edit_profile.dart';
import 'package:unicons/unicons.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({Key? key}) : super(key: key);
  static String routeName = 'ProfileInfo';

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  String fName = "";
  String lName = "";
  String email = "";
  String bdate = "";
  String profile = "assets/images/profile.png";
  late Widget avatar = Container(height: 160);

  @override
  void initState() {
    getUserData().then((_) {
      avatar = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          backgroundImage: profile == "assets/images/profile.png"
              ? AssetImage(profile)
              : FileImage(File(profile)) as ImageProvider<Object>?);
    });
    super.initState();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      fName = sp.getString("fname")!;
      lName = sp.getString("lname")!;
      email = sp.getString("email")!;
      bdate = sp.getString("bdate")!;
      profile = sp.getString("img")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar theme for tablet
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, EditMyProfile.routeName);
            },
            splashColor: kPrimaryColor,
            highlightColor: kPrimaryColor,
            child: Container(
              padding: EdgeInsets.only(right: kDefaultPadding / 2),
              child: Row(
                children: [
                  Icon(UniconsLine.edit),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, EditMyProfile.routeName);
                    },
                    child: Text(
                      'Edit',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: kTextBlackColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: kOtherColor,
        child: Column(
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
            SizedBox(height: 40),
            ProfileDetailColumn(
              title: 'First Name',
              value: '$fName',
            ),
            SizedBox(height: 20),
            ProfileDetailColumn(
              title: 'Last Name',
              value: '$lName',
            ),
            SizedBox(height: 20),
            ProfileDetailColumn(
              title: 'Email Address',
              value: '$email',
            ),
            SizedBox(height: 20),
            ProfileDetailColumn(
              title: 'Date of Birth',
              value: '$bdate',
            ),
            SizedBox(height: 20),
            ProfileDetailColumn(
              title: 'Password',
              value: '*************',
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailColumn extends StatelessWidget {
  const ProfileDetailColumn(
      {Key? key, required this.title, required this.value})
      : super(key: key);
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
                      fontSize: SizerUtil.deviceType == DeviceType.tablet
                          ? 10.sp
                          : 10.sp,
                    ),
              ),
              kHalfSizedBox,
              Text(value, style: Theme.of(context).textTheme.bodySmall),
              kHalfSizedBox,
              SizedBox(
                width: 92.w,
                child: Divider(
                  thickness: 1.0,
                ),
              )
            ],
          ),
          Icon(
            Icons.lock_outline,
            size: 10.sp,
          ),
        ],
      ),
    );
  }
}

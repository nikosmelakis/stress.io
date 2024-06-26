import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

//colors
const Color kSplashColor = Color(0xFFFFFFFF);
const Color kRedRingColor = Color(0xFFF44336);
const Color kGreenRingColor = Color(0xFF72AF00);
const Color kBlueRingColor = Color(0xFF66B3FF);
const Color kPrimaryColor = Color(0xFFA7C7E7);
const Color kSecondaryColor = Color(0xFF3D426B);
const Color kTextBlackColor = Color(0xFF313131);
const Color kTextWhiteColor = Color(0xFFFFFFFF);
const Color kContainerColor = Color(0xFF777777);
const Color kOtherColor = Color(0xFFF4F6F7);
const Color kTextLightColor = Color(0xFFA5A5A5);
const Color kErrorBorderColor = Color(0xFFE74C3C);
const Color kPastelGreen = Color(0xFF77DD77);

//default value
const kDefaultPadding = 20.0;
const kBottomPadding = 40.0;
const kBorderRadius = 30.0;

const kWidthSizedBox = SizedBox(width: kDefaultPadding);

const kHalfSizedBox = SizedBox(height: kDefaultPadding / 2);

const kIconSize =
    SizedBox(height: kDefaultPadding / 2, width: kDefaultPadding / 2);

const kHalfWidthSizedBox = SizedBox(width: kDefaultPadding / 2);

final kTopBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(SizerUtil.deviceType == DeviceType.tablet ? 40 : 20),
  topRight:
      Radius.circular(SizerUtil.deviceType == DeviceType.tablet ? 40 : 20),
);

final kBottomBorderRadius = BorderRadius.only(
    bottomRight:
        Radius.circular(SizerUtil.deviceType == DeviceType.tablet ? 40 : 20),
    bottomLeft:
        Radius.circular(SizerUtil.deviceType == DeviceType.tablet ? 40 : 20));

final kInputTextStyle = GoogleFonts.poppins(
    color: kTextBlackColor, fontSize: 11.sp, fontWeight: FontWeight.w500);

//validator for fname, lname
const String namePattern = r'^[a-zA-Z]+$';

//validation for email
const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

//validation for password
const String passwordPattern =
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

class BottomToTopPageRoute extends PageRouteBuilder {
  final Widget page;

  BottomToTopPageRoute({required this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              page,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              SlideTransition(
                  position:
                      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(animation),
                  child: child),
        );
}

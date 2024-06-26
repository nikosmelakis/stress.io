// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'constants.dart';

class CustomTheme {
  var baseTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: kOtherColor,
    primaryColor: kPrimaryColor,
    appBarTheme: AppBarTheme(
      //height for both phone and tablet
      toolbarHeight: SizerUtil.deviceType == DeviceType.tablet ? 10.h : 7.h,
      backgroundColor: kPrimaryColor,
      titleTextStyle: GoogleFonts.poppins(
        color: kTextBlackColor,
        fontSize: SizerUtil.deviceType == DeviceType.tablet ? 20.sp : 13.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
      ),
      iconTheme: IconThemeData(
        color: kTextBlackColor,
        size: SizerUtil.deviceType == DeviceType.tablet ? 17.sp : 18.sp,
      ),
      elevation: 0,
    ),
    //input decoration theme for all our the app
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: kPrimaryColor,
      suffixIconColor: kTextLightColor,
      //label style for formField
      labelStyle: TextStyle(
          fontSize: 11.sp, color: kTextLightColor, fontWeight: FontWeight.w400),
      //hint style
      hintStyle: TextStyle(fontSize: 16.0, color: kTextBlackColor, height: 0.5),
      //we are using underline input border
      //not outline
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kTextBlackColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kTextBlackColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kTextBlackColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      // on focus  change color
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kTextBlackColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      //color changes when user enters wrong information,
      //we will use validators for this process
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kErrorBorderColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      //same on focus error color
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(width: .5, color: kErrorBorderColor),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      //custom text for bodyText1
      headlineSmall: GoogleFonts.chewy(
        color: kTextWhiteColor,
        //condition if device is tablet or a phone
        fontSize: SizerUtil.deviceType == DeviceType.tablet ? 45.sp : 40.sp,
      ),
      bodyLarge: TextStyle(
          color: kTextWhiteColor, fontSize: 35.0, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(
        color: kTextWhiteColor,
        fontSize: 28.0,
      ),
      titleMedium: TextStyle(
          color: kTextBlackColor,
          fontSize: SizerUtil.deviceType == DeviceType.tablet ? 14.sp : 17.sp,
          fontWeight: FontWeight.w700),
      titleSmall: GoogleFonts.poppins(
          color: kTextBlackColor,
          fontSize: SizerUtil.deviceType == DeviceType.tablet ? 12.sp : 13.sp,
          fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.poppins(
          color: kTextLightColor,
          fontSize: SizerUtil.deviceType == DeviceType.tablet ? 7.sp : 10.sp,
          fontWeight: FontWeight.w400),
    ),
  );
}

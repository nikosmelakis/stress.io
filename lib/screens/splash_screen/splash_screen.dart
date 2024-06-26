import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/constants.dart';
import 'package:temp/screens/auth_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);

    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(context, BottomToTopPageRoute(page: LoginScreen()));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: GoogleFonts.dancingScript(
                    color: kTextBlackColor, fontSize: 32.sp),
                child: AnimatedTextKit(animatedTexts: [
                  TyperAnimatedText(
                    'Stress.io',
                    speed: Duration(milliseconds: 120),
                    textStyle: const TextStyle(
                        color: kTextBlackColor,
                        fontSize: 70,
                        fontWeight: FontWeight.normal,
                        wordSpacing: 3),
                  ),
                ], isRepeatingAnimation: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

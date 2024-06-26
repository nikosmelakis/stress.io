import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:temp/constants.dart';
import 'package:temp/screens/auth_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:temp/database/db_helper.dart';
import 'package:mailer/smtp_server.dart';

// Making button states for login button
enum ButtonState { init, loading, done, wrong }

class ForgotScreen extends StatefulWidget {
  static String routeName = 'ForgotScreen';

  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  bool isAnimating = true;
  ButtonState state = ButtonState.init;

  // Validate our form now
  final _formKey = GlobalKey<FormState>();

  final _forgotEmail = TextEditingController();

  final db_helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    final isDone = state == ButtonState.done;
    final isStretched = isAnimating || state == ButtonState.init;
    final isWrong = state == ButtonState.wrong;
    return GestureDetector(
      // When user taps anywhere on the screen, keyboard hides
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Column(
          children: [
            Container(
              width: 100.w,
              height: 35.h,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      left: 30.0,
                      right: 30,
                      bottom: 10.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Don\'t Stress!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Account will be recovered soon!',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100, right: 40),
                      child: Hero(
                        tag: 'logo',
                        child: Column(
                          children: [
                            DefaultTextStyle(
                              style: GoogleFonts.dancingScript(
                                color: kTextBlackColor,
                                fontSize: 40,
                                fontWeight: FontWeight.normal,
                                wordSpacing: 3,
                              ),
                              child: Text('Stress.io'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 5.w, right: 5.w),
                decoration: BoxDecoration(
                  color: kOtherColor,
                  // Reusable radius,
                  borderRadius: kTopBorderRadius * 3,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        buildEmailField(),
                        SizedBox(height: 20),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          width: state == ButtonState.init ? 160 : 70,
                          onEnd: () =>
                              setState(() => isAnimating = !isAnimating),
                          height: 60,
                          child: isStretched
                              ? buildButton()
                              : isWrong
                                  ? buildWrongButton(isWrong)
                                  : buildCheckButton(isDone),
                        ),
                        SizedBox(height: 40),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: kTextBlackColor,
                            backgroundColor: kOtherColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context, LoginScreen.routeName);
                          },
                          child: Text(
                            'Return to Log In Page',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: kTextBlackColor,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildEmailField() {
    return TextFormField(
      controller: _forgotEmail,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.emailAddress,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.envelope),
        labelText: 'Email',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        // For validation
        RegExp regExp = RegExp(emailPattern);
        if (value == null || value.isEmpty) {
          return 'Please enter your email address to recover your account';
          // If it does not match the pattern, like
          // it does not contain something@something.something
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget buildButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: kPrimaryColor,
          shape: StadiumBorder(),
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RECOVER',
                style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 5), // Adjust the spacing as needed
              Icon(
                Icons.arrow_forward_ios,
                color: kTextBlackColor,
                size: 20,
              ),
            ],
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => state = ButtonState.loading);
            await Future.delayed(Duration(milliseconds: 1500));
            recover();
          }
        },
      );

  Widget buildCheckButton(bool isDone) {
    final color = isDone ? kPastelGreen : kPrimaryColor;
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: isDone
            ? Icon(
                UniconsLine.check,
                weight: 2,
                size: 50,
                color: kSplashColor,
              )
            : CircularProgressIndicator(
                color: kSplashColor,
                strokeWidth: 3.5,
              ),
      ),
    );
  }

  Widget buildWrongButton(bool isDone) {
    final color = isDone ? kErrorBorderColor : kPrimaryColor;
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: isDone
            ? Icon(
                UniconsLine.times,
                weight: 2,
                size: 50,
                color: kSplashColor,
              )
            : CircularProgressIndicator(
                color: kTextBlackColor,
                strokeWidth: 3,
              ),
      ),
    );
  }

  void recover() async {
    final form = _formKey.currentState;

    // Getting form values
    String email = _forgotEmail.text;

    if (form!.validate()) {
      await db_helper.checkEmail(email).then(
        (UserData) async {
          if (UserData == null) {
            String? pwd = await db_helper.getPwd(email);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Password recovery email sent!',
                  textAlign: TextAlign.center,
                  style: (TextStyle(fontSize: 20)),
                ),
                duration: Duration(milliseconds: 1100),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kPastelGreen,
                margin: EdgeInsets.only(bottom: 10, left: 50, right: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
            sendEmail(email, pwd);
            await Future.delayed(
              Duration(milliseconds: 100),
            );
            setState(() => state = ButtonState.done);
            await Future.delayed(
              Duration(milliseconds: 1300),
            );
            setState(() => state = ButtonState.init);
            Navigator.pop(
              context,
              LoginScreen.routeName,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Email not registered!',
                  textAlign: TextAlign.center,
                  style: (TextStyle(fontSize: 20)),
                ),
                duration: Duration(milliseconds: 1000),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kErrorBorderColor,
                margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
            await Future.delayed(
              Duration(milliseconds: 100),
            );
            setState(() => state = ButtonState.wrong);
            await Future.delayed(
              Duration(milliseconds: 1200),
            );
            setState(() => state = ButtonState.init);
          }
        },
      );
    }
  }

  void sendEmail(String email, pwd) async {
    String username = 'noreply.stress.io@gmail.com';
    String password = 'ylwtrttuermsjtqb';
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd at HH:MM:SS').format(now);
    final smtpServer = gmail(username, password);

    print(email);
    print(pwd);

    // Create our message.
    final message = Message()
      ..from = Address(username, 'Stress.io')
      ..recipients.add(email)
      ..subject = 'Password recovery request on $formattedDateTime}'
      ..text = 'Your password is: $pwd';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
    }
  }
}

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:temp/database/db_helper.dart';
import 'package:temp/models/user_model.dart';
import 'package:temp/screens/auth_screen/register_screen.dart';
import 'package:temp/screens/auth_screen/forgot_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/my_nav_bar.dart';
import 'package:unicons/unicons.dart';

late bool _passwordVisible;

//Making button states for loging button
enum ButtonState { init, loading, done, wrong }

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimating = true;
  ButtonState state = ButtonState.init;

  //Getting the users fname for the home page
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  //form key
  final _formKey = GlobalKey<FormState>();
  //validate our form now
  final _userEmail = TextEditingController();
  final _userPwd = TextEditingController();
  var db_helper;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    db_helper = DbHelper();
  }

  logIn() async {
    final form = _formKey.currentState;
    //Geeting form values
    String email = _userEmail.text;
    String pwd = _userPwd.text;

    if (form!.validate()) {
      await db_helper.getLogInData(email, pwd).then((UserData) async {
        if (UserData != null) {
          Future.delayed(Duration(milliseconds: 2000));
          setSP(UserData).whenComplete(() async {
            setState(() => state = ButtonState.done);
            await Future.delayed(Duration(milliseconds: 1200));
            Navigator.pushNamedAndRemoveUntil(
                context, MyNavBar.routeName, (route) => false);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid email or password!',
                textAlign: TextAlign.center,
                style: (TextStyle(fontSize: 20)),
              ),
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              backgroundColor: kErrorBorderColor,
              margin: EdgeInsets.only(bottom: 10, left: 50, right: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          await Future.delayed(Duration(milliseconds: 100));
          setState(() => state = ButtonState.wrong);
          await Future.delayed(Duration(milliseconds: 1200));
          setState(() => state = ButtonState.init);

          print('wrong email or password');
        }
      }).catchError((error) {
        print('error occured');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occured!\nPlease try again later.',
              textAlign: TextAlign.center,
            ),
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
            backgroundColor: kErrorBorderColor,
            margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      });
    }
  }

  //Get function for add shared preferences
  Future setSP(UserModel user) async {
    final SharedPreferences sp = await _pref;

    sp.setString("fname", user.fname);
    sp.setString("lname", user.lname);
    sp.setString("email", user.email);
    sp.setString("bdate", user.bdate);
    sp.setString("pwd", user.pwd);
    sp.setString("img", user.img);
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    //For button animation status
    final isDone = state == ButtonState.done;
    final isWrong = state == ButtonState.wrong;
    final isStretched = isAnimating || state == ButtonState.init;
    return GestureDetector(
      //when user taps anywhere on the screen, keyboard hides
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
                        top: 30.0, left: 30.0, right: 30, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Sign in to continue',
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
                                  wordSpacing: 3),
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
                  borderRadius: kTopBorderRadius * 3,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        buildEmailField(),
                        SizedBox(height: 20),
                        buildPasswordField(),
                        SizedBox(height: 60),
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
                                    : buildCheckButton(isDone)),
                        SizedBox(height: 60),
                        SizedBox(height: 20),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: kTextBlackColor,
                              backgroundColor: kOtherColor),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, ForgotScreen.routeName);
                          },
                          child: Text(
                            'Forgot Password',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: kTextBlackColor,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: kTextBlackColor,
                              backgroundColor: kOtherColor),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RegisterScreen.routeName);
                          },
                          child: Text(
                            'Not a member? Sign Up',
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
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildEmailField() {
    return TextFormField(
      controller: _userEmail,
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
        //for validation
        RegExp regExp = new RegExp(emailPattern);
        if (value == null || value.isEmpty) {
          return 'Please enter your emai address';
          //if it does not matches the pattern, like
          //it not contains somethin@something.something
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  TextFormField buildPasswordField() {
    return TextFormField(
      controller: _userPwd,
      obscureText: _passwordVisible,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.visiblePassword,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.lock),
        labelText: 'Password',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible ? UniconsLine.eye_slash : UniconsLine.eye,
          ),
          iconSize: kDefaultPadding,
        ),
      ),
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
                'SIGN IN',
                style: TextStyle(
                    fontSize: 20,
                    color: kTextBlackColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(width: 5), // adjust the spacing as needed
              Icon(Icons.arrow_forward_ios, color: kTextBlackColor, size: 20),
            ],
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() => state = ButtonState.loading);
            await Future.delayed(Duration(milliseconds: 1500));
            logIn();
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
            ? Icon(UniconsLine.check, weight: 2, size: 50, color: kSplashColor)
            : CircularProgressIndicator(color: kSplashColor, strokeWidth: 3.5),
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
            ? Icon(UniconsLine.times, weight: 2, size: 50, color: kSplashColor)
            : CircularProgressIndicator(color: kTextBlackColor, strokeWidth: 3),
      ),
    );
  }
}

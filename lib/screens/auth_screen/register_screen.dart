import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:temp/constants.dart';
import 'package:temp/database/db_helper.dart';
import 'package:temp/models/user_model.dart';
import 'package:temp/screens/auth_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

late bool _passwordVisible;

//Making button states for loging button
enum ButtonState { init, loading, done, wrong }

class RegisterScreen extends StatefulWidget {
  static String routeName = 'RegisterScreen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isAnimating = true;
  ButtonState state = ButtonState.init;
  //validate our form now
  final _formKey = GlobalKey<FormState>();

  final _userFname = TextEditingController();
  final _userLname = TextEditingController();
  final _userEmail = TextEditingController();
  final _userBdate = TextEditingController();
  final _userPwd = TextEditingController();
  final _userImg = "assets/images/profile.png";

  var db_helper;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    db_helper = DbHelper();
  }

  @override
  Widget build(BuildContext context) {
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
              height: 30.h,
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
                          'Welcome!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Complete the following steps to continue',
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
                padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 13),
                decoration: BoxDecoration(
                  color: kOtherColor,
                  borderRadius: kTopBorderRadius * 3,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        buildFnameField(),
                        SizedBox(height: 20),
                        buildLNameField(),
                        SizedBox(height: 20),
                        buildEmailField(),
                        SizedBox(height: 20),
                        buildDateOfBirthField(),
                        SizedBox(height: 20),
                        buildPasswordField(),
                        SizedBox(height: 20),
                        buildConfimrPasswordField(),
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
                        SizedBox(height: 20),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: kTextBlackColor,
                            backgroundColor: kOtherColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context, LoginScreen.routeName);
                          },
                          child: Text(
                            'Already a member? Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            '',
                            textAlign: TextAlign.end,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
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

  TextFormField buildFnameField() {
    return TextFormField(
      controller: _userFname,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.name,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.user),
        labelText: 'First Name',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        //for validation
        RegExp regExp = new RegExp(namePattern);
        if (value == null || value.isEmpty) {
          return 'Please enter your first name';
          //if it does not matches the pattern, like
          //it not contains somethin@something.something
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid first name';
        }
        return null;
      },
    );
  }

  TextFormField buildLNameField() {
    return TextFormField(
      controller: _userLname,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.name,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.user),
        labelText: 'Last Name',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        //for validation
        RegExp regExp = new RegExp(namePattern);
        if (value == null || value.isEmpty) {
          return 'Please enter your last name';
          //if it does not matches the pattern, like
          //it not contains somethin@something.something
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid last name';
        }
        return null;
      },
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

  TextFormField buildDateOfBirthField() {
    return TextFormField(
        controller: _userBdate,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.datetime,
        style: kInputTextStyle,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          prefixIcon: Icon(UniconsLine.calender),
          labelText: 'Date of Birth',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        readOnly: true,
        onTap: () async {
          var pickedDate = await DatePicker.showSimpleDatePicker(context,
              titleText: "Pick a Date",
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 29380)),
              lastDate: DateTime.now(),
              itemTextStyle:
                  TextStyle(fontStyle: FontStyle.normal, fontFamily: 'Poppins'),
              dateFormat: "dd-MMMM-yyyy",
              locale: DateTimePickerLocale.en_us,
              looping: true,
              pickerMode: DateTimePickerMode.date);

          if (pickedDate != null) {
            _userBdate.text = DateFormat('dd MMMM yyyy').format(pickedDate);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a valid date';
          }
          return null;
        });
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
      // validator: (value) {
      //   //for validation
      //   RegExp regExp = new RegExp(passwordPattern);
      //   if (value == null || value.isEmpty) {
      //     return 'Please enter a secure password';
      //     //if it does not matches the pattern, like
      //     //it not contains somethin@something.something
      //   } else if (!regExp.hasMatch(value)) {
      //     return 'Password must be 8 digits long \nand to contain at least: \n · 1 Upper case letter \n · 1 Lower case letter \n · 1 Symbol \n · 1 Number';
      //   }
      //   return null;
      // },
    );
  }

  TextFormField buildConfimrPasswordField() {
    return TextFormField(
      obscureText: _passwordVisible,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.visiblePassword,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.lock),
        labelText: 'Confirm Password',
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
      // validator: (value) {
      //   //for validation
      //   RegExp regExp = new RegExp(passwordPattern);
      //   if (value == null || value.isEmpty) {
      //     return 'Please enter a secure password';
      //     //if it does not matches the pattern, like
      //     //it not contains somethin@something.something
      //   } else if (value != _userPwd.text)
      //     return 'Passwords don΄t match!';
      //   else if (!regExp.hasMatch(value)) {
      //     return 'Password must contain at least: \n · 1 Upper case letter \n · 1 Lower case letter \n · 1 Symbol \n · 1 Number';
      //   }
      //   return null;
      // },
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
                'SIGN UP',
                style: TextStyle(
                  fontSize: 20,
                  color: kTextBlackColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 5), // adjust the spacing as needed
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
            singUp();
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
                strokeWidth: 3,
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
                color: kSplashColor,
                strokeWidth: 3.5,
              ),
      ),
    );
  }

  singUp() async {
    final form = _formKey.currentState;

    //Geeting form values
    String fname = _userFname.text;
    String lname = _userLname.text;
    String email = _userEmail.text;
    String bdate = _userBdate.text;
    String pwd = _userPwd.text;
    String img = _userImg;

    if (form!.validate()) {
      await db_helper.checkEmail(email).then((UserData) async {
        if (UserData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'This email is already in use!',
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
          await Future.delayed(
            Duration(milliseconds: 100),
          );
          setState(() => state = ButtonState.wrong);
          await Future.delayed(
            Duration(milliseconds: 1200),
          );
          setState(() => state = ButtonState.init);
        } else {
          form.save();
          UserModel uModel = UserModel(fname, lname, email, bdate, pwd, img);
          db_helper.saveData(uModel).then((userData) async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account successfully created!',
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
            await Future.delayed(
              Duration(milliseconds: 100),
            );
            setState(() => state = ButtonState.done);
            await Future.delayed(
              Duration(milliseconds: 1300),
            );
            Navigator.pop(
              context,
              LoginScreen.routeName,
            );
            setState(() => state = ButtonState.init);
          }).catchError((error) {
            print(error);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unexepcted error occured.\nPlease try again later!',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(milliseconds: 1700),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kErrorBorderColor,
                margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          });
          print('User with email ' +
              email +
              ' and password: ' +
              pwd +
              ' succesfully created! \n img=' +
              img +
              '');
        }
        ;
      });
    }
  }
}

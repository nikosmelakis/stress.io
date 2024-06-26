// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:temp/database/db_helper.dart';
import 'package:temp/models/change-profile_model.dart';
import 'package:temp/models/user_model.dart';
import 'package:temp/my_nav_bar.dart';
import 'package:temp/screens/profile_screen/my_profile.dart';
import 'package:unicons/unicons.dart';
import 'package:image_picker/image_picker.dart';

late bool _passwordVisible;

class EditMyProfile extends StatefulWidget {
  static String routeName = 'EditMyProfile';

  @override
  _EditMyProfileState createState() => _EditMyProfileState();
}

class _EditMyProfileState extends State<EditMyProfile> {
  //To get user info
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  //validate our form now
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  //Form input
  final _userFname = TextEditingController();
  final _userLname = TextEditingController();
  final _userEmail = TextEditingController();
  final _userBdate = TextEditingController();
  final _userPwd = TextEditingController();
  String profile = "assets/images/profile.png";
  PickedFile? imageFile;
  late Widget avatar = Container(height: 160);

  var db_helper;

  //User info to print on screen
  String fName = "";
  String lName = "";
  String email = "";
  String bdate = "";
  String pwd = "";
  String img = "";

  @override
  void initState() {
    _passwordVisible = true;
    getUserData().then((_) {
      avatar = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          backgroundImage: profile == "assets/images/profile.png"
              ? AssetImage(profile)
              : FileImage(File(profile)) as ImageProvider<Object>?);
    });
    db_helper = DbHelper();
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

  update() async {
    final form = _formKey.currentState;
    //Geeting form values
    String fname = _userFname.text;
    String lname = _userLname.text;
    String email = _userEmail.text;
    String bdate = _userBdate.text;
    String pwd = _userPwd.text;
    String img = profile;

    if (form!.validate()) {
      form.save();

      UserModel user = UserModel(fname, lname, email, bdate, pwd, img);
      await db_helper.updateUser(user).then((value) {
        if (value == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account Successfully Updated!',
                textAlign: TextAlign.center,
              ),
              duration: Duration(milliseconds: 2000),
              behavior: SnackBarBehavior.floating,
              backgroundColor: kPastelGreen,
              margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          Future.delayed(Duration(milliseconds: 2000), () {
            Navigator.pushNamedAndRemoveUntil(
                context, MyNavBar.routeName, (route) => false);
          });
          updateSP(user).whenComplete(() {});
          print('Update email is: ' +
              email +
              ' and updated password is: ' +
              pwd +
              "with image" +
              img);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'An unexpected error occured! \n Please try again later.',
                textAlign: TextAlign.center,
              ),
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              backgroundColor: kPastelGreen,
              margin: EdgeInsets.only(bottom: 10, left: 80, right: 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          Future.delayed(Duration(milliseconds: 2000), () {
            Navigator.pushNamedAndRemoveUntil(
                context, MyProfileScreen.routeName, (route) => false);
          });
        }
      }).catchError((error) {
        print(error);
      });
    }
  }

  //To print updated user info
  Future updateSP(UserModel user) async {
    final SharedPreferences sp = await _pref;

    sp.setString("fname", user.fname);
    sp.setString("lname", user.lname);
    sp.setString("email", user.email);
    sp.setString("bdate", user.bdate);
    sp.setString("img", user.img);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context, MyProfileScreen.routeName);
            },
            splashColor: kPrimaryColor,
            highlightColor: kPrimaryColor,
            child: Container(
              padding: EdgeInsets.only(right: kDefaultPadding / 2),
              child: Row(
                children: [
                  Icon(UniconsLine.save),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      update();
                    },
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: kTextBlackColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                imageProfile(),

                // Hero(
                //   tag: 'avatarTag', // Unique tag for Hero animation
                //   child: CircleAvatar(
                //     radius:
                //         SizerUtil.deviceType == DeviceType.tablet ? 12.w : 13.w,
                //     backgroundColor: kSecondaryColor,
                //     backgroundImage: AssetImage('assets/images/profile.png'),
                //     child: InkWell(
                //       onTap: () {
                //         // Will change profile from here
                //       },
                //       child: Align(
                //         alignment: Alignment.bottomRight,
                //         child: CircleAvatar(
                //             radius: 18,
                //             backgroundColor: Colors.white38,
                //             child: GestureDetector(
                //               onTap: () {
                //                 showModalBottomSheet(
                //                     context: context,
                //                     builder: ((builder) => bottomSheet()));
                //               },
                //               child: Icon(
                //                 UniconsLine.edit,
                //                 color: kSecondaryColor,
                //               ),
                //             )),
                //       ),
                //     ),
                //   ),
                // ),
                // kWidthSizedBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        '$fName $lName',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 5.w, right: 5.w),
              decoration: BoxDecoration(
                color: kOtherColor,
                //reusable radius,
                borderRadius: kTopBorderRadius,
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
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//Text fields
  TextFormField buildFnameField() {
    return TextFormField(
      controller: _userFname,
      textAlign: TextAlign.start,
      keyboardType: TextInputType.name,
      style: kInputTextStyle,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        labelText: 'First Name',
        hintText: '$fName',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        labelText: 'Last Name',
        hintText: '$lName',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        labelText: 'Email',
        hintText: '$email',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (value) {
        //for validation
        RegExp regExp = new RegExp(emailPattern);
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
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
          border: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: .3, color: kTextBlackColor),
          ),
          labelText: 'Date Of Birth',
          hintText: '$bdate',
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        readOnly: true,
        onTap: () async {
          var pickedDate = await DatePicker.showSimpleDatePicker(
            context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(Duration(days: 29380)),
            lastDate: DateTime.now(),
            dateFormat: "dd-MMMM-yyyy",
            locale: DateTimePickerLocale.en_us,
            looping: true,
          );

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
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        labelText: 'Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
      //     return 'Password must contain at least: \n · 1 Upper case letter \n · 1 Lower case letter \n · 1 Symbol \n · 1 Number';
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
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: .3, color: kTextBlackColor),
        ),
        labelText: 'Confirm Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
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

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: [
          Text(
            "Choose Profile Picture",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.pop(context);
                },
                icon: Icon(UniconsLine.camera),
                label: Text("Camera"),
              ),
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.pop(context);
                },
                icon: Icon(UniconsLine.image),
                label: Text("Gallery"),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget imageProfile() {
    final imageProvider = Provider.of<EventProvider>(context);
    PickedFile? currentImageFile = imageProvider.newFile;

    if (currentImageFile != null) {
      imageFile = currentImageFile;
    }

    return SafeArea(
      child: Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: kOtherColor),
                child: Icon(
                  UniconsLine.edit,
                  color: kTextBlackColor,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    final imageProvider = Provider.of<EventProvider>(context, listen: false);
    imageProvider.setImageFile(pickedFile);
    setState(
      () {
        imageFile = pickedFile;
        profile = imageFile!.path;
        avatar = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: FileImage(File(profile)),
        );
      },
    );
  }
}

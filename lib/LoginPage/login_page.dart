import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Auth/chat_login_service.dart';
import '../CommonCalling/Common.dart';
import '../ContainerShape/container.dart';
import '../DashBoardTeacher/home_bootom_teacher.dart';
import '../ForgotPassword/forgot_password.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../RegisterPage/register_page.dart';
import '../RegisterPage/widgets/widgets.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../baseurl/baseurl.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isloading = false;
  CommonMethod common = CommonMethod();
  final AuthServiceChat _authService = AuthServiceChat();


  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String _deviceModel = "Loading...";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String? deviceModel = "Unknown";

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceModel = webInfo.appName;
      } else {
        deviceModel = switch (defaultTargetPlatform) {
          TargetPlatform.android => (await deviceInfoPlugin.androidInfo).model,
          TargetPlatform.iOS => (await deviceInfoPlugin.iosInfo).model,
          TargetPlatform.linux => (await deviceInfoPlugin.linuxInfo).prettyName,
          TargetPlatform.windows => (await deviceInfoPlugin.windowsInfo).productName,
          TargetPlatform.macOS => (await deviceInfoPlugin.macOsInfo).model,
          TargetPlatform.fuchsia => "Fuchsia platform isn't supported",
        };
      }
    } on PlatformException {
      deviceModel = "Failed to get platform version.";
    }

    if (!mounted) return;

    setState(() {
      _deviceModel = deviceModel!;
    });
  }


  bool _isLoading = false;
  String? validationMessage;
  String? passwordError ;



  void _login() async {
    User? user = await _authService.signIn(
      emailController.text,
      passwordController.text,
    );
    // if (user != null) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => UserListScreen()),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
    // }
  }



  void validateEmail() {
    setState(() {
      String value = emailController.text;

      // Regular expression for validating an email
      String emailPattern = r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

      RegExp regex = RegExp(emailPattern);

      if (value.isEmpty) {
        validationMessage = 'Please enter your email id';
      }
      // Check if email matches the regex pattern
      else if (!regex.hasMatch(value)) {
        validationMessage = 'Please enter a valid email id';
      }
      else {
        validationMessage = null;
      }
    });
  }
  void validatePassword() {
    setState(() {
      String value = passwordController.text;

      if (value.isEmpty) {
        passwordError = 'Please enter your password';
      } else if (value.length < 6) {
        passwordError = "Password must be at least 6 characters";
      } else {
        passwordError = null;  // Clear error if password is valid
      }
    });
  }
  Future<void> loginUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
            ],
          ),
        );
      },
    );

    try {
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? deviceToken = await _firebaseMessaging.getToken();
      print('Device id: $deviceToken');

      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        String apiUrl = login; // Replace with your API endpoint

        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'email': emailController.text,
            'password': passwordController.text,
            'device_id': _deviceModel,
            'firebase_token': deviceToken,
            // Pass device token to your API
          },
        );
        setState(() {
          _isLoading =
          false; // Set loading state to false after registration completes
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);


          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String token = responseData['token'];
          final String Userid = responseData['data']['id'].toString();
          final String name = responseData['data']['name'].toString();
          final String User1 = responseData['data'].toString();
          // Save token using shared_preferences
          await prefs.setString('token', token);
          await prefs.setString('name', name);
          await prefs.setString('id', Userid);
          await prefs.setString('data', User1);
          print('UserName :-  $name');


          User? user = await _authService.signIn(
            responseData['data']['email'].toString(),
            passwordController.text.toString(),
          );

          prefs.setBool('isLoggedIn', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(initialIndex: 0,),
            ),
          );


          print('User registered successfully!');
          print(token);
          print(response.body);
        } else {
          Navigator.pop(context);
          // Registration failed
          // You may handle the error response here, e.g., show an error message
          print('Registration failed!');
          Fluttertoast.showToast(
            msg:'You are already logged in on another device.',
            toastLength: Toast.LENGTH_LONG,
            // Duration for which the toast should be displayed
            gravity: ToastGravity.BOTTOM,
            // Toast gravity
            timeInSecForIosWeb: 1,
            // Time in seconds for iOS and web
            backgroundColor: Colors.black.withOpacity(0.8),
            // Background color of the toast
            textColor: Colors.white,
            // Text color of the toast
            fontSize: 16.0, // Font size of the toast message
          );

          // Fluttertoast.showToast(
          //   msg:'You are already logged in on another device.',
          //   toastLength: Toast.LENGTH_LONG,
          //   // Duration for which the toast should be displayed
          //   gravity: ToastGravity.BOTTOM,
          //   // Toast gravity
          //   timeInSecForIosWeb: 1,
          //   // Time in seconds for iOS and web
          //   backgroundColor: Colors.black.withOpacity(0.8),
          //   // Background color of the toast
          //   textColor: Colors.white,
          //   // Text color of the toast
          //   fontSize: 16.0, // Font size of the toast message
          // );

        }
      }
    } catch (e) {
      emailController.clear();
      passwordController.clear();
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during login: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      ))
      ;
    }
  }

  Future<void> loginTeacherApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
            ],
          ),
        );
      },
    );

    try {
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? deviceToken = await _firebaseMessaging.getToken();
      print('Device id: $deviceToken');

      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        final response = await http.post(
          Uri.parse(loginTeacher),
          body: {
            'email': emailController.text,
            'password': passwordController.text,
            'device_id': _deviceModel,
            'firebase_token': deviceToken,
          },
        );
        setState(() {
          _isLoading =
          false; // Set loading state to false after registration completes
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String token = responseData['token'];
          final String Userid = responseData['data']['id'].toString();
          final String User1 = responseData['data'].toString();
          // Save token using shared_preferences
          await prefs.setString('token', token);
          await prefs.setString('id', Userid);
          await prefs.setString('data', User1);
          print('User List$User1');

          User? user = await _authService.signIn(
            responseData['data']['email'].toString(),
            passwordController.text.toString(),
          );

          prefs.setBool('isLoggedInTeacher', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeBottomTeacher(),
            ),
          );


          print('User registered successfully!');
          print(token);
          print(response.body);
        } else {
          Navigator.pop(context);
          // Registration failed
          // You may handle the error response here, e.g., show an error message
          print('Registration failed!');
          Fluttertoast.showToast(
            msg:'You are already logged in on another device.',
            toastLength: Toast.LENGTH_LONG,
            // Duration for which the toast should be displayed
            gravity: ToastGravity.BOTTOM,
            // Toast gravity
            timeInSecForIosWeb: 1,
            // Time in seconds for iOS and web
            backgroundColor: Colors.black.withOpacity(0.8),
            // Background color of the toast
            textColor: Colors.white,
            // Text color of the toast
            fontSize: 16.0, // Font size of the toast message
          );

          // Fluttertoast.showToast(
          //   msg:'You are already logged in on another device.',
          //   toastLength: Toast.LENGTH_LONG,
          //   // Duration for which the toast should be displayed
          //   gravity: ToastGravity.BOTTOM,
          //   // Toast gravity
          //   timeInSecForIosWeb: 1,
          //   // Time in seconds for iOS and web
          //   backgroundColor: Colors.black.withOpacity(0.8),
          //   // Background color of the toast
          //   textColor: Colors.white,
          //   // Text color of the toast
          //   fontSize: 16.0, // Font size of the toast message
          // );

        }
      }
    } catch (e) {
      emailController.clear();
      passwordController.clear();
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during login: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      ))
      ;
    }
  }

  List<bool> isSelected = [true, false]; // Default: Student selected


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isSelected[0]? primaryColor:Colors.blueGrey,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 280.sp,
                color: isSelected[0]? primaryColor:Colors.blueGrey,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        height: 280.sp, // Adjust height according to your need
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                          isSelected[0]? primaryColor:Colors.blueGrey,
                              isSelected[0]? Colors.blueGrey:primaryColor,

                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: SizedBox(

                                  height: 150.sp,
                                  // child: Image.asset('assets/log_in.png')

                                  child: Column(
                                    children: [
                                      SizedBox(
                                          width: 150.sp ,
                                          height: 120.sp,
                                          child: Image.asset(logo)),
                                      Text.rich(TextSpan(
                                        text: AppConstants.appLogoName,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,color: Colors.white),
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: AppConstants.appLogoName2,
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,color: Colors.white),
                                            ),
                                          )
                                        ],
                                      )),

                                    ],
                                  )

                              )),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.only(bottom: 28.sp),
                child: Center(
                  child: Container(
                    width: screenWidth * 0.9, // Use 80% of the screen width
                    child: ToggleButtons(
                      borderColor: Colors.white,
                      selectedBorderColor: Colors.white,
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = i == index;
                          }
                        });
                      },
                      children: [
                        // Adjust width of each button
                        Container(
                          width: (screenWidth * 0.9) / 2 - 4, // Half of 80% minus spacing
                          alignment: Alignment.center,
                          child:  Text(
                            'Student',

                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color:isSelected[0]? Colors.black:Colors.white,),
                            ),
                          ),
                        ),
                        Container(
                          width: (screenWidth * 0.9) / 2 - 4,
                          alignment: Alignment.center,
                          child:  Text(
                            'Teacher',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color:isSelected[0]? Colors.white:Colors.black,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // Conditional Container
              isSelected[0]
                  ?  SingleChildScrollView(
                child:   Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Container(
                    color:primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.only(
                            //     topLeft: Radius.circular(30.sp),
                            //     topRight: Radius.circular(30.sp),
                            //   ),
                            // ),


                            child:
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 1.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Email Id",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Text('')
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 10,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 50.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                          child: Container(
                                            width: double.infinity,

                                            height: 50.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: emailController,
                                                      keyboardType: TextInputType.emailAddress,


                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your email',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.email, color: Colors.black),
                                                      ),

                                                      onChanged: (val) {
                                                        validateEmail();

                                                        // setState(() {
                                                        //   email = val;
                                                        // });
                                                      },

                                                      // check tha validation
                                                      // validator: (val) {
                                                      //   return RegExp(
                                                      //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      //       .hasMatch(val!)
                                                      //       ? null
                                                      //       : "Please enter a valid email";
                                                      // },
                                                      textInputAction: TextInputAction.next, // This sets the keyboard action to "Next"
                                                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (validationMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.red[100],
                                          //   borderRadius: BorderRadius.circular(5),
                                          // ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  validationMessage!,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),



                                    // Password
                                    SizedBox(height: 10.sp),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Password",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Text('')
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 10,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 50.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 50.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [

                                                Flexible(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: passwordController,
                                                      keyboardType: TextInputType.emailAddress,
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      obscureText: true,
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your password',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.lock, color: Colors.black),

                                                      ),
                                                      // validator: (val) {
                                                      //   if (val!.length < 6) {
                                                      //     return "Password must be at least 6 characters";
                                                      //   } else {
                                                      //     return null;
                                                      //   }
                                                      // },
                                                      onChanged: (val) {
                                                        validatePassword();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (passwordError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.red[100],
                                          //   borderRadius: BorderRadius.circular(5),
                                          // ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  passwordError!,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 10.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPasswordPage()),);
                                          },
                                          child: Text(
                                            "Forgot password?",
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(fontSize: 12.sp,
                                                  fontWeight: FontWeight.normal,
                                                  color: HexColor('#f04949')),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30.sp),

                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 40.sp,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryColor2,
                                                  primaryColor,


                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              // borderRadius: BorderRadius.only(
                                              //   bottomLeft: Radius.circular(50.sp),
                                              //   bottomRight: Radius.circular(50.sp),
                                              // ),
                                            ),

                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // Make the button background transparent
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0)),// Remove the shadow (optional)
                                              ),

                                              child: Text(
                                                "Login",
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(fontSize: 17.sp,
                                                      fontWeight: FontWeight.normal,
                                                      color: whiteColor),
                                                ),
                                              ),

                                              onPressed: (){
                                                validateEmail();
                                                validatePassword();
                                                if ( validationMessage == null && passwordError == null  ) {
                                                  if (formKey.currentState!.validate()) {

                                                    loginUser(context);

                                                  }
                                                } else {
                                                  print('Validation failed: $validationMessage');
                                                }

                                              },

                                            ),
                                          ),
                                        ),
                                        isloading
                                            ? SizedBox(
                                            height: 40.sp,
                                            child: Center(
                                                child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )))
                                            : SizedBox()
                                      ],
                                    ),


                                    SizedBox(height: 10.sp),
                                    // Container(
                                    //   height: 25.sp,
                                    //   child: Stack(
                                    //     children: [
                                    //       Center(
                                    //         child: Container(
                                    //           height: 2,
                                    //           decoration: BoxDecoration(
                                    //             gradient: LinearGradient(
                                    //               colors: [
                                    //                 Colors.grey.shade100,
                                    //                 Colors.black54,
                                    //                 Colors.grey.shade100,
                                    //               ],
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Center(
                                    //         child: Container(
                                    //           color: Colors.white,
                                    //           height: 25.sp,
                                    //           width: 40.sp,
                                    //           child: Center(
                                    //             child: Text(
                                    //               "OR",
                                    //               style: GoogleFonts.poppins(
                                    //                 textStyle: TextStyle(fontSize: 17.sp,
                                    //                     fontWeight: FontWeight.normal,
                                    //                     color: Colors.black),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // SizedBox(height: 10.sp),
                                    //
                                    // Stack(
                                    //   children: [
                                    //     SizedBox(
                                    //       width: double.infinity,
                                    //       height: 40.sp,
                                    //       child: Container(
                                    //         decoration: BoxDecoration(
                                    //           borderRadius: BorderRadius.circular(8.0),
                                    //           gradient: LinearGradient(
                                    //             colors: [
                                    //               primaryColor2,
                                    //               primaryColor,
                                    //
                                    //
                                    //             ],
                                    //             begin: Alignment.topLeft,
                                    //             end: Alignment.bottomRight,
                                    //           ),
                                    //           // borderRadius: BorderRadius.only(
                                    //           //   bottomLeft: Radius.circular(50.sp),
                                    //           //   bottomRight: Radius.circular(50.sp),
                                    //           // ),
                                    //         ),
                                    //
                                    //         child: ElevatedButton(
                                    //
                                    //           style: ElevatedButton.styleFrom(
                                    //             backgroundColor: Colors.transparent, // Make the button background transparent
                                    //             shadowColor: Colors.transparent,
                                    //             shape: RoundedRectangleBorder(
                                    //                 borderRadius: BorderRadius.circular(0)),// Remove the shadow (optional)
                                    //           ),
                                    //
                                    //           child: Center(
                                    //             child: Row(
                                    //               crossAxisAlignment: CrossAxisAlignment.center,
                                    //               mainAxisAlignment: MainAxisAlignment.center,
                                    //               children: [
                                    //                 Image.asset(
                                    //                   'assets/google_icon.png',
                                    //                   // Replace with your image path
                                    //                   height: 20.sp
                                    //                       .sp, // Adjust the height as needed
                                    //                 ),
                                    //                 SizedBox(
                                    //                   width: 10.sp,
                                    //                 ),
                                    //                 Text(
                                    //                   "Gmail",
                                    //                   style: GoogleFonts.poppins(
                                    //                     textStyle: TextStyle(fontSize: 17.sp,
                                    //                         fontWeight: FontWeight.normal,
                                    //                         color: whiteColor),
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //
                                    //
                                    //
                                    //           onPressed: (){
                                    //             common.login(context);
                                    //
                                    //           },
                                    //
                                    //
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     isloading
                                    //         ? SizedBox(
                                    //         height: 40.sp,
                                    //         child: Center(
                                    //             child:
                                    //             const CircularProgressIndicator(
                                    //               color: Colors.white,
                                    //             )))
                                    //         : SizedBox()
                                    //   ],
                                    // ),

                                    SizedBox(height: 0.sp,),




                                  ],
                                ),
                              ),
                            ),
                          ),

                        ),
                        SizedBox(height: 30.sp,),

                        Text.rich(TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context,  RegisterPage());
                                  }),
                          ],
                        )),
                        // Transform.rotate(
                        //   angle: 3.14159, // Rotate by 180 degrees (PI radians)
                        //   child: ClipPath(
                        //     clipper: WaveClipper(),
                        //     child: Container(
                        //       width: double.infinity,
                        //       height: 130.sp,
                        //       decoration: BoxDecoration(
                        //         // borderRadius: BorderRadius.circular(8.0),
                        //         gradient: LinearGradient(
                        //           colors: [
                        //             primaryColor2,
                        //             primaryColor,
                        //
                        //
                        //           ],
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //         ),
                        //         // borderRadius: BorderRadius.only(
                        //         //   bottomLeft: Radius.circular(50.sp),
                        //         //   bottomRight: Radius.circular(50.sp),
                        //         // ),
                        //       ),
                        //         child: SizedBox(
                        //           height: 130.sp,
                        //           child: Align(
                        //             alignment: Alignment.bottomCenter,
                        //             child: Transform.rotate(
                        //               angle: 3.14159,
                        //               child: Center(
                        //                 child: Padding(
                        //                   padding:  EdgeInsets.only(top: 15.sp),
                        //                   child: Text.rich(TextSpan(
                        //                     text: "Don't have an account? ",
                        //                     style: const TextStyle(
                        //                         color: Colors.white, fontSize: 14),
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                           text: "Register here",
                        //                           style: const TextStyle(
                        //                               fontSize: 20,
                        //                               color: Colors.black,
                        //                               decoration: TextDecoration.underline),
                        //                           recognizer: TapGestureRecognizer()
                        //                             ..onTap = () {
                        //                               nextScreen(context,  RegisterPage());
                        //                             }),
                        //                     ],
                        //                   )),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //
                        //     ),
                        //   ),

                      ],
                    ),
                  ),
                ),
              )
                  :  SingleChildScrollView(
                child:   Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,

                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.only(
                            //     topLeft: Radius.circular(30.sp),
                            //     topRight: Radius.circular(30.sp),
                            //   ),
                            // ),


                            child:
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 1.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Email Id",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Text('')
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 10,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 50.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                          child: Container(
                                            width: double.infinity,

                                            height: 50.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: emailController,
                                                      keyboardType: TextInputType.emailAddress,


                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your email',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.email, color: Colors.black),
                                                      ),

                                                      onChanged: (val) {
                                                        validateEmail();

                                                        // setState(() {
                                                        //   email = val;
                                                        // });
                                                      },

                                                      // check tha validation
                                                      // validator: (val) {
                                                      //   return RegExp(
                                                      //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      //       .hasMatch(val!)
                                                      //       ? null
                                                      //       : "Please enter a valid email";
                                                      // },
                                                      textInputAction: TextInputAction.next, // This sets the keyboard action to "Next"
                                                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (validationMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.red[100],
                                          //   borderRadius: BorderRadius.circular(5),
                                          // ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  validationMessage!,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),



                                    // Password
                                    SizedBox(height: 10.sp),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Password",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Text('')
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 10,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 50.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 50.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [

                                                Flexible(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: passwordController,
                                                      keyboardType: TextInputType.emailAddress,
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      obscureText: true,
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your password',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.lock, color: Colors.black),

                                                      ),
                                                      // validator: (val) {
                                                      //   if (val!.length < 6) {
                                                      //     return "Password must be at least 6 characters";
                                                      //   } else {
                                                      //     return null;
                                                      //   }
                                                      // },
                                                      onChanged: (val) {
                                                        validatePassword();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (passwordError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.red[100],
                                          //   borderRadius: BorderRadius.circular(5),
                                          // ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  passwordError!,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 10.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPasswordPage()),);
                                          },
                                          child: Text(
                                            "Forgot password?",
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(fontSize: 12.sp,
                                                  fontWeight: FontWeight.normal,
                                                  color: HexColor('#f04949')),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30.sp),

                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 40.sp,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryColor2,
                                                  primaryColor,


                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              // borderRadius: BorderRadius.only(
                                              //   bottomLeft: Radius.circular(50.sp),
                                              //   bottomRight: Radius.circular(50.sp),
                                              // ),
                                            ),

                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // Make the button background transparent
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0)),// Remove the shadow (optional)
                                              ),

                                              child: Text(
                                                "Login",
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(fontSize: 17.sp,
                                                      fontWeight: FontWeight.normal,
                                                      color: whiteColor),
                                                ),
                                              ),

                                              onPressed: (){
                                                validateEmail();
                                                validatePassword();
                                                if ( validationMessage == null && passwordError == null  ) {
                                                  if (formKey.currentState!.validate()) {

                                                    loginTeacherApi(context);
                                                  }
                                                } else {
                                                  print('Validation failed: $validationMessage');
                                                }

                                              },

                                            ),
                                          ),
                                        ),
                                        isloading
                                            ? SizedBox(
                                            height: 40.sp,
                                            child: Center(
                                                child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )))
                                            : SizedBox()
                                      ],
                                    ),


                                    SizedBox(height: 10.sp),
                                    // Container(
                                    //   height: 25.sp,
                                    //   child: Stack(
                                    //     children: [
                                    //       Center(
                                    //         child: Container(
                                    //           height: 2,
                                    //           decoration: BoxDecoration(
                                    //             gradient: LinearGradient(
                                    //               colors: [
                                    //                 Colors.grey.shade100,
                                    //                 Colors.black54,
                                    //                 Colors.grey.shade100,
                                    //               ],
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Center(
                                    //         child: Container(
                                    //           color: Colors.white,
                                    //           height: 25.sp,
                                    //           width: 40.sp,
                                    //           child: Center(
                                    //             child: Text(
                                    //               "OR",
                                    //               style: GoogleFonts.poppins(
                                    //                 textStyle: TextStyle(fontSize: 17.sp,
                                    //                     fontWeight: FontWeight.normal,
                                    //                     color: Colors.black),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // SizedBox(height: 10.sp),
                                    //
                                    // Stack(
                                    //   children: [
                                    //     SizedBox(
                                    //       width: double.infinity,
                                    //       height: 40.sp,
                                    //       child: Container(
                                    //         decoration: BoxDecoration(
                                    //           borderRadius: BorderRadius.circular(8.0),
                                    //           gradient: LinearGradient(
                                    //             colors: [
                                    //               primaryColor2,
                                    //               primaryColor,
                                    //
                                    //
                                    //             ],
                                    //             begin: Alignment.topLeft,
                                    //             end: Alignment.bottomRight,
                                    //           ),
                                    //           // borderRadius: BorderRadius.only(
                                    //           //   bottomLeft: Radius.circular(50.sp),
                                    //           //   bottomRight: Radius.circular(50.sp),
                                    //           // ),
                                    //         ),
                                    //
                                    //         child: ElevatedButton(
                                    //
                                    //           style: ElevatedButton.styleFrom(
                                    //             backgroundColor: Colors.transparent, // Make the button background transparent
                                    //             shadowColor: Colors.transparent,
                                    //             shape: RoundedRectangleBorder(
                                    //                 borderRadius: BorderRadius.circular(0)),// Remove the shadow (optional)
                                    //           ),
                                    //
                                    //           child: Center(
                                    //             child: Row(
                                    //               crossAxisAlignment: CrossAxisAlignment.center,
                                    //               mainAxisAlignment: MainAxisAlignment.center,
                                    //               children: [
                                    //                 Image.asset(
                                    //                   'assets/google_icon.png',
                                    //                   // Replace with your image path
                                    //                   height: 20.sp
                                    //                       .sp, // Adjust the height as needed
                                    //                 ),
                                    //                 SizedBox(
                                    //                   width: 10.sp,
                                    //                 ),
                                    //                 Text(
                                    //                   "Gmail",
                                    //                   style: GoogleFonts.poppins(
                                    //                     textStyle: TextStyle(fontSize: 17.sp,
                                    //                         fontWeight: FontWeight.normal,
                                    //                         color: whiteColor),
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //
                                    //
                                    //
                                    //           onPressed: (){
                                    //             common.login(context);
                                    //
                                    //           },
                                    //
                                    //
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     isloading
                                    //         ? SizedBox(
                                    //         height: 40.sp,
                                    //         child: Center(
                                    //             child:
                                    //             const CircularProgressIndicator(
                                    //               color: Colors.white,
                                    //             )))
                                    //         : SizedBox()
                                    //   ],
                                    // ),

                                    SizedBox(height: 0.sp,),




                                  ],
                                ),
                              ),
                            ),
                          ),

                        ),
                        SizedBox(height: 30.sp,),

                        Text.rich(TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context,  RegisterPage());
                                  }),
                          ],
                        )),
                        // Transform.rotate(
                        //   angle: 3.14159, // Rotate by 180 degrees (PI radians)
                        //   child: ClipPath(
                        //     clipper: WaveClipper(),
                        //     child: Container(
                        //       width: double.infinity,
                        //       height: 130.sp,
                        //       decoration: BoxDecoration(
                        //         // borderRadius: BorderRadius.circular(8.0),
                        //         gradient: LinearGradient(
                        //           colors: [
                        //             primaryColor2,
                        //             primaryColor,
                        //
                        //
                        //           ],
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //         ),
                        //         // borderRadius: BorderRadius.only(
                        //         //   bottomLeft: Radius.circular(50.sp),
                        //         //   bottomRight: Radius.circular(50.sp),
                        //         // ),
                        //       ),
                        //         child: SizedBox(
                        //           height: 130.sp,
                        //           child: Align(
                        //             alignment: Alignment.bottomCenter,
                        //             child: Transform.rotate(
                        //               angle: 3.14159,
                        //               child: Center(
                        //                 child: Padding(
                        //                   padding:  EdgeInsets.only(top: 15.sp),
                        //                   child: Text.rich(TextSpan(
                        //                     text: "Don't have an account? ",
                        //                     style: const TextStyle(
                        //                         color: Colors.white, fontSize: 14),
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                           text: "Register here",
                        //                           style: const TextStyle(
                        //                               fontSize: 20,
                        //                               color: Colors.black,
                        //                               decoration: TextDecoration.underline),
                        //                           recognizer: TapGestureRecognizer()
                        //                             ..onTap = () {
                        //                               nextScreen(context,  RegisterPage());
                        //                             }),
                        //                     ],
                        //                   )),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //
                        //     ),
                        //   ),

                      ],
                    ),
                  ),
                ),
              ),





            ],
          ),
        ),
      ),
    );
  }
}






import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ChangePassword/change_password.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String otp;

  const OtpVerifyPage({super.key, required this.email, required this.otp});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";
  StreamController<ErrorAnimationType>? errorController;
  String email = "";
  String password = "";
  bool _isLoading = false;
  bool hasError = false;

  String currentText = "";


  Future<void> verifyOtpApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(
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

      String otp = textEditingController.text;

      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        String apiUrl = verifyOtp; // Replace with your API endpoint

        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'email': widget.email,
            'otp': otp,
            'device_id': deviceToken,
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
          // Save token using shared_preferences
          await prefs.setString('tokenForgot', token);

          print(responseData);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordPage(),
            ),
          );

          print('verify otp successfully!');
          // print(token);
          print(response.body);
        } else {
          // Registration failed
          // You may handle the error response here, e.g., show an error message
          print('otp failed!');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading =
        false; // Set loading state to false after registration completes
      });
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during login: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      ));
    }
  }



  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 300.sp,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF010071),
                          Color(0xFF0A1AFF),

                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50.sp),
                        bottomRight: Radius.circular(50.sp),
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: SizedBox(

                              height: 150.sp,
                              // child: Image.asset('assets/log_in.png')
                              child: Image.asset('assets/logo2.png')
                          )),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "OTP Verification",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),

                          SizedBox(height: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:10.sp,top: 40.sp),
                    child: IconButton(
                        onPressed: (){
                          Navigator.pop(context);

                        }, icon: Icon(Icons.arrow_back,color: Colors.white,size: 25.sp,)),
                  ),

                ],
              ),
            ),

            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 13.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "We have sent a verification code to",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.grey),
                          ),
                        ),
                        Text('')
                      ],
                    ),
                    SizedBox(height: 50.sp),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 30,
                        ),
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          obscuringWidget: Icon(Icons.star,size: 24,color: Colors.white,),

                          // const FlutterLogo(
                          //   size: 24,
                          // ),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "I'm from validator";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: primaryColor,
                          ),
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          boxShadows: const [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.black12,
                              blurRadius: 10,
                            )
                          ],
                          onCompleted: (v) {
                            debugPrint("Completed");
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        hasError ? "*Please fill up all the cells properly" : "",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 50.sp),

                    Container(
                      margin:
                      const EdgeInsets.symmetric(vertical: 16.0,),
                      child: ButtonTheme(
                        height: 50,
                        child: TextButton(
                          onPressed: () {

                            if (formKey.currentState!.validate()) {

                              verifyOtpApi(context);

                            }


                          },
                          child: Center(
                            child: Text(
                              "VERIFY".toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color:  Color(0xFF0A1AFF),
                          borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Didn't receive the code? ",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        TextButton(
                          onPressed: () => snackBar("OTP resend!!"),
                          child:  Text(
                            "RESEND",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),



                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

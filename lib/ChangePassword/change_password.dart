import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LoginPage/login_page.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';

class ChangePasswordPage extends StatefulWidget {


  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  Future<void> passwordChangeApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    try {




        setState(() {
          _isLoading = true;
        });

        final password = _newPasswordController.text;
        final confirmpassword = _confirmPasswordController.text;

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('tokenForgot');

        final response = await http.post(
          Uri.parse(changePassword),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'password': password,'confirm_password':confirmpassword }),
        );
        setState(() {
          _isLoading =
          false; // Set loading state to false after registration completes
        });
        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );

          print('Change Password successfully!');
          // print(token);
          print(response.body);
        } else {
          // Registration failed
          // You may handle the error response here, e.g., show an error message
          print('password failed!');
          Navigator.pop(context); // Close the progress dialog
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to log in. Please try again.'),
          ));
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
                            "Change Password?",
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
                          "New Password",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.normal, color: Colors.black),
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
                            color: Color(0xFF0A1AFF),
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
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.lock, color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextField(
                                      controller: _newPasswordController,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your New Password',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Confirm Password",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.normal, color: Colors.black),
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
                            color: Color(0xFF0A1AFF),
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
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.lock, color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Confirm Password',
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) {

                                        if(val!.isEmpty){
                                          return 'Please confirm new password';
                                        } else   if (val != _newPasswordController.text) {
                                          return 'Passwords do not match';
                                        }

                                        else if (val!.length < 6) {
                                          return "Password must be at least 6 characters";
                                        } else {
                                          return null;
                                        }
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
                    SizedBox(height: 10.sp),


                    SizedBox(height: 50.sp),
                    SizedBox(
                      width: double.infinity,
                      height: 50.sp,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text(
                          "Change Password",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal, color: Colors.white),
                          ),
                        ),
                        onPressed: () async {

                            passwordChangeApi(context);


                        },
                      ),
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

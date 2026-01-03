import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/chat_login_service.dart';
import '../ContainerShape/container.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../LoginPage/login_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../baseurl/baseurl.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? nameError;
  String? phoneError;
  int _selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  final AuthServiceChat _authService = AuthServiceChat();

  String? passwordError;

  String? validationMessage;

  final _focusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final TextEditingController examNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController highestqualificationController =
      TextEditingController();
  final TextEditingController teachingExperienceController =
      TextEditingController();

  String email = "";
  String password = "";
  String fullName = "";

  // List<String> dropdownItems = ['Option 1', 'Option 2', 'Option 3'];
  String? selectedValue;
  List<dynamic> dropdownItems = [];
  List<dynamic> subjectList = [];


  void _signUp() async {
    User? user = await _authService.signUp(
      emailController.text,
      passwordController.text,
      nameController.text,
    );
    // if (user != null) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => UserListScreen()),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign-up failed")));
    // }
  }


  Future<void> _registerUser(BuildContext context) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device id: $deviceToken');

    try {
      if (formKey.currentState!.validate()) {
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
                  // SizedBox(width: 16.0),
                  // Text("Logging in..."),
                ],
              ),
            );
          },
        );

        setState(() {
          _isLoading = true;
        });

        String apiUrl = register; // Replace with your API endpoint

        Map<String, dynamic> requestBody = {
          'name': nameController.text,
          'ref_id': referralController.text,
          'email': emailController.text,
          'contact': phoneController.text,
          'password': passwordController.text,
          'device_id': _deviceModel,
          'category_id': selectedValue,
          'standard': selectedValue1,
          'school_name': schoolController.text,
          'past_marks': marksController.text,
          'language': selectedValue3,
          'exam_name': examNameController.text,
          'state': selectedState,

        };

        // Add 'category_id' to the request body only if it's not null
        if (selectedValue != null) {
          requestBody['category_id'] = selectedValue;
        }

        final response = await http.post(
          Uri.parse(apiUrl),
          body: requestBody,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String token = responseData['token'];
          final String userId = responseData['data']['id'].toString();
          final String user = responseData['data'].toString();

          // Save token using shared_preferences
          await prefs.setString('token', token);
          await prefs.setString('id', userId);
          await prefs.setString('data', user);
          prefs.setBool('isLoggedIn', true);

          User? userchat = await _authService.signUp(
            responseData['data']['email'].toString(),
            passwordController.text.toString(),
            responseData['data']['name'].toString(),
          );



          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(
                initialIndex: 0,
              ),
            ),
          );

          print('User registered successfully!');
          print(token);
          print(response.body);
        } else {
          Navigator.pop(context);
          print('Registration failed!');
          Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context); // Close the progress dialog

      // Handle errors appropriately
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      ));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  Future<void> _registerTeacher(BuildContext context) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();

      if (formKey.currentState!.validate()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          },
        );

        setState(() {
          _isLoading = true;
        });

        final url = Uri.parse(registerTeacher);

        Map<String, dynamic> body = {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "contact": phoneController.text.trim(),
          "address": addressController.text.trim(),
          "experience": teachingExperienceController.text.trim().toString(),
          "qualification":highestqualificationController.text.trim(),
          "language": selectedValue3.toString(),
          "firebase_token":deviceToken,
          "category_ids": selectedCategoryIds ?? [],
          "subject_special":selectedValue
        };

        try {
          final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            print("Success: ${response.body}");
            final Map<String, dynamic> responseData = json.decode(response.body);
            User? userchat = await _authService.signUp(
              responseData['data']['email'].toString(),
              passwordController.text.toString(),
              responseData['data']['name'].toString(),
            );

            showSuccessDialog(context);


          } else {
            print("Failed: ${response.statusCode}");
          }
        } catch (e) {
          print("Error: $e");
        }
      }
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String _deviceModel = "Loading...";

  @override
  void initState() {
    hitAllcategory();
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
          TargetPlatform.windows =>
            (await deviceInfoPlugin.windowsInfo).productName,
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



  void validateEmail() {
    setState(() {
      String value = emailController.text;

      // Regular expression for validating an email
      String emailPattern =
          r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

      RegExp regex = RegExp(emailPattern);

      if (value.isEmpty) {
        validationMessage = 'Please enter your email id';
      }
      // Check if email matches the regex pattern
      else if (!regex.hasMatch(value)) {
        validationMessage = 'Please enter a valid email id';
      } else {
        validationMessage = null;
      }
    });
  }

  void validateName() {
    setState(() {
      String value = nameController.text;
      if (value.isEmpty) {
        nameError = 'Please enter your name';
      } else {
        nameError = null;
      }
    });
  }

  void validatePhone() {
    setState(() {
      String value = phoneController.text;
      if (value.isEmpty) {
        phoneError = 'Please enter your Mobile Number';
      } else {
        phoneError = null;
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
        passwordError = null; // Clear error if password is valid
      }
    });
  }

  void validateDropdown() {
    // Validation logic for the dropdown
    if (selectedValue == null || selectedValue!.isEmpty) {
      print("Dropdown cannot be empty");
    } else {
      print("Dropdown value: $selectedValue");
    }
  }

  List<bool> isSelected = [true, false]; // Default: Student selected

  // Function to fetch data from API
  Future<void> hitAllcategory() async {
    final response = await http.get(Uri.parse(categoryName));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          dropdownItems = responseData['data'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    }
  }
  Future<void> hitSubjectlist() async {
    final response = await http.get(Uri.parse('$subjectRegTeacher$selectedCategoryIds'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          subjectList = responseData['data'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    }
  }

  String? selectedValue2;
  String? selectedValue1;
  String? selectedAdditionalValue;
  List<String> selectedCategoryIds = [];

  List<Map<String, String>> dropdownItems1 = [
    {'id': '11th', 'name': '11th Grade'},
    {'id': '12th', 'name': '12th Grade'},
    {'id': 'dropout', 'name': 'Dropout'},
  ];

  List<String> additionalDropdownItems = ['Option 1', 'Option 2'];

  String? selectedValue4;
  String? selectedValue3;

  List<Map<String, String>> dropdownItems2 = [
    {'id': 'Hindi', 'name': 'Hindi'},
    {'id': 'English', 'name': 'English'},
  ];


  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];

  String? selectedState; // Holds the currently selected state





  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Rounded corners with radius 10
                  child: Image.asset(
                    'assets/Register_Successful_Transparent.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover, // Ensures the image covers the rounded area properly
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "You have successfully created your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Okay",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isSelected[0] ? primaryColor : Colors.blueGrey,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 230.sp,
                color: isSelected[0] ? primaryColor : Colors.blueGrey,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        height: 250.sp, // Adjust height according to your need
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isSelected[0] ? primaryColor : Colors.blueGrey,
                              isSelected[0] ? Colors.blueGrey : primaryColor,
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
                                          width: 150.sp,
                                          height: 100.sp,
                                          child: Image.asset(logo)),
                                      Text.rich(TextSpan(
                                        text: AppConstants.appLogoName,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: AppConstants.appLogoName2,
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      )),
                                    ],
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 28.sp),
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
                          width: (screenWidth * 0.9) / 2 - 4,
                          // Half of 80% minus spacing
                          alignment: Alignment.center,
                          child: Text(
                            'Student',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected[0] ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: (screenWidth * 0.9) / 2 - 4,
                          alignment: Alignment.center,
                          child: Text(
                            'Teacher',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected[0] ? Colors.white : Colors.black,
                              ),
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
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 1.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Course",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                hintText: 'Select Course',
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.book,
                                                    color: Colors.black),
                                              ),
                                              value: selectedValue,
                                              items: dropdownItems.map((item) {
                                                // Assuming the item contains 'id' and 'name' from API
                                                return DropdownMenuItem<String>(
                                                  value: item['id'].toString(),
                                                  // Use the ID as the value
                                                  child: Text(
                                                    item[
                                                        'name'], // Display the name
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedValue =
                                                      newValue; // Update selected value
                                                });
                                                validateDropdown(); // Validate the selection
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.sp),

                            SizedBox(height: 1.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Full Name",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: nameController,
                                              keyboardType: TextInputType.name,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your name',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(
                                                    Icons.account_circle,
                                                    color: Colors.black),
                                              ),
                                              onChanged: (val) {
                                                validateName();

                                                // setState(() {
                                                //   fullName = val;
                                                // });
                                              },

                                              // validator: (val) {
                                              //   if (val!.isNotEmpty) {
                                              //     return null;
                                              //   } else {
                                              //     return "Name cannot be empty";
                                              //   }
                                              // },
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (nameError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
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
                                          nameError!,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Email id",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,

                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your email',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.email,
                                                    color: Colors.black),
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
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
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

                            SizedBox(height: 10.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Contact Number",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: phoneController,
                                              keyboardType: TextInputType.phone,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Enter your mobile number',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.call,
                                                    color: Colors.black),
                                              ),
                                              onChanged: (val) {
                                                validatePhone();

                                                // setState(() {
                                                //   fullName = val;
                                                // });
                                              },

                                              // validator: (val) {
                                              //   if (val!.isNotEmpty) {
                                              //     return null;
                                              //   } else {
                                              //     return "Name cannot be empty";
                                              //   }
                                              // },
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (phoneError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
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
                                          phoneError!,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Password",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Text('')
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            // Remove GestureDetector from wrapping Scaffold

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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: passwordController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your password',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.lock,
                                                    color: Colors.black),
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

                            SizedBox(height: 1.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Class",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        // Ensures dropdown text and icon align correctly
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(0),
                                            // Prevent additional padding
                                            border: InputBorder.none,
                                            // Removes border to rely on container styling
                                            hintText: 'Select Class',
                                            hintStyle:
                                                TextStyle(color: Colors.black),
                                            icon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.class_),
                                            )),
                                        value: selectedValue2,
                                        items: dropdownItems1.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item['id'],
                                            child: Text(item['name']!),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedValue1 = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            if (selectedValue1 == '11th' ||
                                selectedValue1 == '12th')
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
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
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.sp),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: TextFormField(
                                                controller: schoolController,
                                                keyboardType:
                                                    TextInputType.name,
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter Your School Name',
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                      Icons.account_circle,
                                                      color: Colors.black),
                                                ),
                                                onChanged: (val) {
                                                  validateName();

                                                  // setState(() {
                                                  //   fullName = val;
                                                  // });
                                                },

                                                // validator: (val) {
                                                //   if (val!.isNotEmpty) {
                                                //     return null;
                                                //   } else {
                                                //     return "Name cannot be empty";
                                                //   }
                                                // },
                                                textInputAction:
                                                    TextInputAction.next,
                                                // This sets the keyboard action to "Next"
                                                onEditingComplete: () =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (selectedValue1 == 'dropout') ...[
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
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
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.sp),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: TextFormField(
                                                controller: examNameController,
                                                keyboardType:
                                                    TextInputType.name,
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Your Exam',
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                      Icons.account_circle,
                                                      color: Colors.black),
                                                ),
                                                onChanged: (val) {
                                                  validateName();

                                                  // setState(() {
                                                  //   fullName = val;
                                                  // });
                                                },

                                                // validator: (val) {
                                                //   if (val!.isNotEmpty) {
                                                //     return null;
                                                //   } else {
                                                //     return "Name cannot be empty";
                                                //   }
                                                // },
                                                textInputAction:
                                                    TextInputAction.next,
                                                // This sets the keyboard action to "Next"
                                                onEditingComplete: () =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
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
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.sp),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: TextFormField(
                                                controller: marksController,
                                                keyboardType:
                                                    TextInputType.name,
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Your Marks',
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                      Icons.account_circle,
                                                      color: Colors.black),
                                                ),
                                                onChanged: (val) {
                                                  validateName();

                                                  // setState(() {
                                                  //   fullName = val;
                                                  // });
                                                },

                                                // validator: (val) {
                                                //   if (val!.isNotEmpty) {
                                                //     return null;
                                                //   } else {
                                                //     return "Name cannot be empty";
                                                //   }
                                                // },
                                                textInputAction:
                                                    TextInputAction.next,
                                                // This sets the keyboard action to "Next"
                                                onEditingComplete: () =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            SizedBox(height: 1.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Language",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        // Ensures dropdown text and icon align correctly
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(0),
                                            // Prevent additional padding
                                            border: InputBorder.none,
                                            // Removes border to rely on container styling
                                            hintText: 'Select Language',
                                            hintStyle:
                                                TextStyle(color: Colors.black),
                                            icon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.language),
                                            )),
                                        value: selectedValue4,
                                        items: dropdownItems2.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item['id'],
                                            child: Text(item['name']!),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedValue3 = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 20.sp,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "State",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child:DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedState,
                                          hint: Text("Select a State"),
                                          isExpanded: true,
                                          items: states.map((String state) {
                                            return DropdownMenuItem<String>(
                                              value: state,
                                              child: Text(state),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedState = newValue;
                                            });
                                          },
                                        ),
                                      )

                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 20.sp,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Referral Code ",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
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
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
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
                                  padding:
                                  EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: referralController,
                                              keyboardType: TextInputType.name,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                    FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter Referral Code',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(
                                                    Icons.card_giftcard,
                                                    color: Colors.black),
                                              ),
                                              textInputAction:

                                              TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 10.sp,
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
                                        backgroundColor: Colors.transparent,
                                        // Make the button background transparent
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                0)), // Remove the shadow (optional)
                                      ),
                                      // style: ElevatedButton.styleFrom(
                                      //     backgroundColor: HexColor('#ffc107'),
                                      //     elevation: 0,
                                      //     shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(15))),
                                      child: Text(
                                        "Register",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.normal,
                                              color: whiteColor),
                                        ),
                                      ),

                                      onPressed: () {
                                        validateEmail();
                                        validateName();
                                        validatePhone();
                                        validatePassword();
                                        if (validationMessage == null &&
                                            nameError == null &&
                                            phoneError == null &&
                                            passwordError == null) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            _registerUser(context);
                                          }
                                        } else {
                                          print(
                                              'Validation failed: $validationMessage');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.sp),
                            Container(
                              height: 25.sp,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade100,
                                            Colors.black54,
                                            Colors.grey.shade100,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      color: Colors.white,
                                      height: 25.sp,
                                      width: 40.sp,
                                      child: Center(
                                        child: Text(
                                          "OR",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.sp),
                            Text.rich(TextSpan(
                              text: "Already have an account ? ",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('#9ba3aa')),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Sign in",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    },
                                ),
                              ],
                            )),
                            SizedBox(height: 20.sp),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.sp),
                        child: Column(
                          children: [

                            SizedBox(height: 1.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select Course",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Text('')
                                ],
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: dropdownItems.map((category) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                          child: FilterChip(
                                            label: Text(category['name']),
                                            selected: selectedCategoryIds.contains(category['id'].toString()),
                                            onSelected: (bool isSelected) {
                                              setState(() {
                                                if (isSelected) {
                                                  selectedCategoryIds.add(category['id'].toString());
                                                  hitSubjectlist();
                                                } else {
                                                  selectedCategoryIds.remove(category['id'].toString());
                                                  hitSubjectlist();
                                                }
                                              });
                                            },
                                            selectedColor: Colors.blueAccent.withOpacity(0.5),
                                            backgroundColor: Colors.grey[200],
                                            labelStyle: TextStyle(color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                SizedBox(height: 10,)
                                ],
                              ),
                            ),



                            // Subject

                            SizedBox(height: 1.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select Subject",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Text('')
                                ],
                              ),
                            ),
                            SizedBox(height: 10.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.sp),
                              child: Stack(
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
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(0.5),
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
                                    padding:
                                    EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child:
                                              DropdownButtonFormField<String>(
                                                decoration: InputDecoration(
                                                  hintText: 'Select Subject',
                                                  hintStyle: TextStyle(
                                                      color: Colors.black),
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(Icons.book,
                                                      color: Colors.black),
                                                ),
                                                value: selectedValue,
                                                items: subjectList.map((item) {
                                                  // Assuming the item contains 'id' and 'name' from API
                                                  return DropdownMenuItem<String>(
                                                    value: item['name'].toString(),
                                                    // Use the ID as the value
                                                    child: Text(
                                                      item['name'], // Display the name
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedValue = newValue; // Update selected value
                                                  });
                                                  validateDropdown(); // Validate the selection
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.sp),





                            SizedBox(height: 10.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [





                                  SizedBox(height: 1.sp),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Name",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding:
                                            EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller: nameController,
                                                    keyboardType: TextInputType.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter your name',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                          Icons.account_circle,
                                                          color: Colors.black),
                                                    ),
                                                    onChanged: (val) {
                                                      validateName();

                                                      // setState(() {
                                                      //   fullName = val;
                                                      // });
                                                    },

                                                    // validator: (val) {
                                                    //   if (val!.isNotEmpty) {
                                                    //     return null;
                                                    //   } else {
                                                    //     return "Name cannot be empty";
                                                    //   }
                                                    // },
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (nameError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: Container(
                                        // decoration: BoxDecoration(
                                        //   color: Colors.red[100],
                                        //   borderRadius: BorderRadius.circular(5),
                                        // ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 8),
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
                                                nameError!,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Email id",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller: emailController,
                                                    keyboardType:
                                                        TextInputType.emailAddress,

                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter your email',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(Icons.email,
                                                          color: Colors.black),
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
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
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

                                  SizedBox(height: 10.sp),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Contact Number",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding:
                                            EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller: phoneController,
                                                    keyboardType: TextInputType.phone,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Enter your mobile number',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(Icons.call,
                                                          color: Colors.black),
                                                    ),
                                                    onChanged: (val) {
                                                      validatePhone();

                                                      // setState(() {
                                                      //   fullName = val;
                                                      // });
                                                    },

                                                    // validator: (val) {
                                                    //   if (val!.isNotEmpty) {
                                                    //     return null;
                                                    //   } else {
                                                    //     return "Name cannot be empty";
                                                    //   }
                                                    // },
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (phoneError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: Container(
                                        // decoration: BoxDecoration(
                                        //   color: Colors.red[100],
                                        //   borderRadius: BorderRadius.circular(5),
                                        // ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1, horizontal: 8),
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
                                                phoneError!,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Password",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Text('')
                                    ],
                                  ),
                                  SizedBox(height: 10.sp),
                                  // Remove GestureDetector from wrapping Scaffold

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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller: passwordController,
                                                    keyboardType:
                                                        TextInputType.emailAddress,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter your password',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(Icons.lock,
                                                          color: Colors.black),
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

                                  SizedBox(height: 1.sp),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Address",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding:
                                            EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller: addressController,
                                                    keyboardType: TextInputType.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter your address',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                          Icons.account_circle,
                                                          color: Colors.black),
                                                    ),
                                                    onChanged: (val) {
                                                      // validateName();

                                                      // setState(() {
                                                      //   fullName = val;
                                                      // });
                                                    },

                                                    // validator: (val) {
                                                    //   if (val!.isNotEmpty) {
                                                    //     return null;
                                                    //   } else {
                                                    //     return "Name cannot be empty";
                                                    //   }
                                                    // },
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Highest Qualification",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding:
                                            EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller:
                                                        highestqualificationController,
                                                    keyboardType: TextInputType.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Enter your Highest Qualification',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                          Icons.account_circle,
                                                          color: Colors.black),
                                                    ),
                                                    onChanged: (val) {
                                                      // validateName();

                                                      // setState(() {
                                                      //   fullName = val;
                                                      // });
                                                    },

                                                    // validator: (val) {
                                                    //   if (val!.isNotEmpty) {
                                                    //     return null;
                                                    //   } else {
                                                    //     return "Name cannot be empty";
                                                    //   }
                                                    // },
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Teaching Experience",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding:
                                            EdgeInsets.only(left: 8.0, right: 8.sp),
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: TextFormField(
                                                    controller:
                                                        teachingExperienceController,
                                                    keyboardType: TextInputType.name,
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Enter your teaching experience ',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                          Icons.account_circle,
                                                          color: Colors.black),
                                                    ),
                                                    onChanged: (val) {
                                                      // validateName();

                                                      // setState(() {
                                                      //   fullName = val;
                                                      // });
                                                    },

                                                    // validator: (val) {
                                                    //   if (val!.isNotEmpty) {
                                                    //     return null;
                                                    //   } else {
                                                    //     return "Name cannot be empty";
                                                    //   }
                                                    // },
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    // This sets the keyboard action to "Next"
                                                    onEditingComplete: () =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Language",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 15.sp,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withOpacity(0.5),
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
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
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
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8.0),
                                            child: DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              // Ensures dropdown text and icon align correctly
                                              decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.all(0),
                                                  // Prevent additional padding
                                                  border: InputBorder.none,
                                                  // Removes border to rely on container styling
                                                  hintText: 'Select Language',
                                                  hintStyle:
                                                      TextStyle(color: Colors.black),
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(8.0),
                                                    child: Icon(Icons.language),
                                                  )),
                                              value: selectedValue4,
                                              items: dropdownItems2.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item['id'],
                                                  child: Text(item['name']!),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedValue3 = newValue;
                                                });
                                              },
                                            ),
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
                                              backgroundColor: Colors.transparent,
                                              // Make the button background transparent
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      0)), // Remove the shadow (optional)
                                            ),
                                            // style: ElevatedButton.styleFrom(
                                            //     backgroundColor: HexColor('#ffc107'),
                                            //     elevation: 0,
                                            //     shape: RoundedRectangleBorder(
                                            //         borderRadius: BorderRadius.circular(15))),
                                            child: Text(
                                              "Register",
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight: FontWeight.normal,
                                                    color: whiteColor),
                                              ),
                                            ),

                                            onPressed: () {
                                              validateEmail();
                                              validateName();
                                              validatePhone();
                                              validatePassword();
                                              if (validationMessage == null &&
                                                  nameError == null &&
                                                  phoneError == null &&
                                                  passwordError == null) {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  _registerTeacher(context);
                                                }
                                              } else {
                                                print(
                                                    'Validation failed: $validationMessage');
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20.sp),
                                  Container(
                                    height: 25.sp,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.shade100,
                                                  Colors.black54,
                                                  Colors.grey.shade100,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            color: Colors.white,
                                            height: 25.sp,
                                            width: 40.sp,
                                            child: Center(
                                              child: Text(
                                                "OR",
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontSize: 17.sp,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.sp),
                                  Text.rich(TextSpan(
                                    text: "Already have an account ? ",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: HexColor('#9ba3aa')),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Sign in",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => LoginPage()),
                                            );
                                          },
                                      ),
                                    ],
                                  )),
                                  SizedBox(height: 20.sp),
                                ],
                              ),
                            ),
                          ],
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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/Profile/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../Download/download.dart';
import '../Help/help.dart';
import '../HexColorCode/HexColor.dart';
import '../LoginPage/login_page.dart';
import '../OrderPage/orders.dart';
import '../ResetPassword/reset_password.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../WebView/webview.dart';
import '../baseurl/baseurl.dart';
import '../doubtStatusPage/doubt.dart';
import 'DoubtSessionTab/doubt_session_tab.dart';
import 'Invoice/Invoice.dart';
import 'MockTest/user_mock_test_list.dart';
import 'TransactionHistory/transaction_history.dart';

class UserActivityModel {
  final String title;
  final double value;

  UserActivityModel({
    required this.title,
    required this.value,
  });
}


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController amountController = TextEditingController();

  bool _isLoading = false;
  Razorpay _razorpay = new Razorpay();

  String? razorpayOrderId = '';
  String? razorpayKeyId = '';
  double userAllPerformance = 0.0;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';
  String wallet = '';
  double value = 80;
  List<dynamic> plan = [];
  List<dynamic> categoryPerformance = [];
  String walletBalance=''; // Initialize wallet balance

  final List<UserActivityModel> activtity = [
    UserActivityModel(
      title: 'Practice',
      value: 20,
    ),

    UserActivityModel(
      title: 'Mock Text',
      value: 30,
    ),
    UserActivityModel(
      title: 'Text Series',
      value: 40,
    ),
    UserActivityModel(
      title: 'Previous Paper',
      value: 65,
    ),

  ];
  var showDialogBox = false;


  @override
  void initState() {
    razorpayKeyData();
    super.initState();
    fetchProfileData();
    fetchPerformanceData();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 3).animate(_controller)
      ..addListener(() {
        setState(() {
          userAllPerformance;
        }); // Redraws the widget with the new needle position
      });

    _controller.repeat(reverse: true); // Makes the needle move back and forth
  }

  void _refresh() {
    setState(() {
      fetchProfileData();
      fetchPerformanceData();
    });
  }

  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
      false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData.containsKey('userPlan')) {
        setState(() {
          plan = jsonData['userPlan'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }


      setState(() {
        nickname = jsonData['user']['name'].toString();
        userEmail = jsonData['user']['email'].toString();
        contact = jsonData['user']['contact'].toString();
        // address = jsonData['user']['bio'];
        photoUrl = jsonData['user']['picture_data'].toString();
        walletBalance = jsonData['wallet']['balance'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }


  Future<void> fetchPerformanceData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(getPerformance);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
      false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() {
        userAllPerformance = jsonData['overall_performance'];
      });

      if (jsonData.containsKey('performance')) {
        setState(() {
          categoryPerformance = jsonData['performance'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load profile data');
    }
  }


  Future<void> logoutApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
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
      // Replace 'your_token_here' with your actual token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(logout);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await http.post(uri, headers: headers);

      Navigator.pop(context); // Close the progress dialog

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove(
          'isLoggedIn',
        );

        // If the server returns a 200 OK response, parse the data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load data');
      }
    } catch (e) {
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during logout: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log out. Please try again.'),
      ));
    }
  }
  Future<void> razorpayKeyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(razorpayKayId);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        razorpayKeyId = jsonData['razor_pay_id'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }


  Future<void> ordersCreateApi(String price) async {

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('id');
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "amount": (double.parse(price) * 100).toInt(), // Convert to paise
        "currency": "INR",
      };

      final response = await http.post(
        Uri.parse(ordersIdRazorpay), // Replace with your URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          razorpayOrderId = jsonData['data']['id'].toString();

          openCheckout(
            razorpayKeyId,
            double.parse(price) * 100,
          );


        });
        print("Order Created: $razorpayOrderId");
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to create order');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('An error occurred while creating the order');
    }
  }

  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homepageColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                children: [

                  Container(
                    height: 80.sp,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.sp),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.5),
                      //     spreadRadius: 1,
                      //     blurRadius: 1,
                      //     offset: Offset(0, 1),
                      //   ),
                      // ],
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10.sp,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40.sp),
                              child: SizedBox(
                                height: 60.sp,
                                width: 60.sp,
                                child: Image.network(
                                  photoUrl.toString(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Return a default image widget here
                                    return Container(
                                      color: Colors.grey,
                                      // Placeholder color
                                      // You can customize the default image as needed
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.sp,
                            ),
                            Container(
                              height: 80.sp,
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp),
                                      child: SizedBox(
                                        height: 20.sp,
                                        child: Text(
                                          '${nickname}',
                                          style: GoogleFonts.cabin(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp),
                                      child: Text(
                                        "${userEmail}",
                                        style: GoogleFonts.cabin(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ProfileUpdatePage(
                                                  onReturn: _refresh);
                                            },
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8.sp),
                                        child: Container(
                                          height: 20.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.purple,
                                            borderRadius: BorderRadius.circular(
                                                5.sp),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5.sp),
                                            child: Center(
                                                child: Text(
                                                  'View Profile',
                                                  style: GoogleFonts.cabin(
                                                    textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9.sp,
                                                        fontWeight: FontWeight
                                                            .normal),
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return DoubtSessionTabClass();
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#800000'),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.sp),
                                  // Top left corner radius
                                  // bottomLeft: Radius.circular(5.sp),  // Bottom left corner radius
                                  bottomRight: Radius.circular(5.sp),
                                  // Bottom left corner radius
                                  topRight: Radius.circular(
                                      5.sp), // Bottom left corner radius
                                ),
                                // border: Border.all(
                                //   color: greenColorQ, // Border color
                                //   width: 1.sp, // Border width
                                // ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(7.sp),
                                child: Text('Doubt Session',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Wallet',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: Container(
                      height: 60.sp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green,
                                  size: 30.sp,
                                ),
                                SizedBox(width: 10.sp),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Wallet Balance",
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    Text(
                                      "₹ ${walletBalance}", // Replace with actual data
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showAddBalanceBottomSheet(context); // Function to show input dialog
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5.sp),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
                                    child: Text(
                                      'Add Balance',
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.sp),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TransactionsScreen(), // Add a separate wallet page
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(5.sp),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
                                    child: Text(
                                      'View Transactions',
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Performance',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: Container(
                      height: 150.sp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 5.sp,
                            ),
                            SizedBox(
                                width: 120.sp,
                                child: Text(AppConstants.performance,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal),
                                  ),


                                )),


                            SizedBox(
                              width: 200.sp,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 100,
                                    showLabels: false,
                                    showTicks: false,
                                    axisLineStyle: AxisLineStyle(
                                      thickness: 0.3,
                                      thicknessUnit: GaugeSizeUnit.logicalPixel,
                                    ),
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 30,
                                        color: Colors.red,
                                        label: 'Poor',
                                        startWidth: 25.sp,
                                        endWidth: 25.sp,
                                      ),
                                      GaugeRange(
                                        startValue: 30,
                                        endValue: 60,
                                        color: Colors.orange,
                                        label: 'Average',
                                        startWidth: 25.sp,
                                        endWidth: 25.sp,
                                      ),
                                      GaugeRange(
                                        startValue: 60,
                                        endValue: 80,
                                        color: Colors.lightBlue,
                                        label: 'Good',
                                        startWidth: 25.sp,
                                        endWidth: 25.sp,
                                      ),
                                      GaugeRange(
                                        startValue: 80,
                                        endValue: 100,
                                        color: Colors.green,
                                        label: 'Excellent',
                                        startWidth: 25.sp,
                                        endWidth: 25.sp,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[

                                      // User performance pointer
                                      NeedlePointer(
                                        value: userAllPerformance,
                                        needleColor: Colors
                                            .black, // Different color for user performance
                                        // You can customize the appearance further if desired
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Container(
                                          child: Text(
                                            '${userAllPerformance} %',
                                            style: TextStyle(fontSize: 11.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Activity',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.all(3.sp),
                      child: Container(
                          height: 200.sp,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.sp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.sp),
                            child: Container(
                              height: 200.sp,
                              // Set an appropriate height for the ListView
                              child: GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                // Disable scrolling

                                crossAxisCount: 2,
                                // Number of columns
                                crossAxisSpacing: 10.0,
                                // Space between columns
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1.9,

                                padding: EdgeInsets.all(0),
                                children:
                                categoryPerformance.isNotEmpty ?
                                List.generate(
                                    categoryPerformance.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (index == 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserMockTestScreen(
                                                  title: 'Test Series',
                                                  subcategory: 14,),
                                          ),
                                        );
                                      } else if (index == 1) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserMockTestScreen(
                                                  title: 'Mock Test',
                                                  subcategory: 16,),
                                          ),
                                        );
                                      } else if (index == 2) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserMockTestScreen(
                                                  title: 'Quiz Test',
                                                  subcategory: 23,),
                                          ),
                                        );
                                      } else if (index == 3) {

                                      }
                                    },
                                    child: Container(
                                      height: 60.sp,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                            offset: Offset(0, 1),
                                          ),
                                        ],

                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.sp),
                                              child: categoryPerformance[index]['data'] !=
                                                  null &&
                                                  ((categoryPerformance[index]['category'] ==
                                                      'Practice' &&
                                                      categoryPerformance[index]['data']['performance'] !=
                                                          null) ||
                                                      (categoryPerformance[index]['category'] !=
                                                          'Practice' &&
                                                          categoryPerformance[index]['data']['performance'] !=
                                                              null))
                                                  ? CircularPercentIndicator(
                                                radius: 25.sp,
                                                lineWidth: 8.sp,
                                                animation: true,
                                                percent: (categoryPerformance[index]['category'] ==
                                                    'Practice'
                                                    ? (double.tryParse(
                                                    categoryPerformance[index]['data']["performance"]
                                                        .toString()) ?? 0.0) /
                                                    100
                                                    : (double.tryParse(
                                                    categoryPerformance[index]['data']["performance"]
                                                        .toString()) ?? 0.0) /
                                                    100)
                                                    .clamp(0.0, 1.0),
                                                center: Text(
                                                  categoryPerformance[index]['category'] ==
                                                      'Practice'
                                                      ? "${(double.tryParse(
                                                      categoryPerformance[index]['data']['performance']
                                                          .toString()) ?? 0.0)
                                                      .toStringAsFixed(1)}%"
                                                      : "${(double.tryParse(
                                                      categoryPerformance[index]['data']['performance']
                                                          .toString()) ?? 0.0)
                                                      .toStringAsFixed(1)}%",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 9.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                circularStrokeCap: CircularStrokeCap
                                                    .round,
                                                progressColor: categoryPerformance[index]['category'] ==
                                                    'Practice'
                                                    ? (double.tryParse(
                                                    categoryPerformance[index]['data']['performance']
                                                        .toString()) ?? 0.0) <
                                                    40
                                                    ? Colors.red
                                                    : (double.tryParse(
                                                    categoryPerformance[index]['data']['performance']
                                                        .toString()) ?? 0.0) <=
                                                    60
                                                    ? Colors.yellow
                                                    : Colors.green
                                                    : (double.tryParse(
                                                    categoryPerformance[index]['data']['performance']
                                                        .toString()) ?? 0.0) <
                                                    40
                                                    ? Colors.red
                                                    : (double.tryParse(
                                                    categoryPerformance[index]['data']['performance']
                                                        .toString()) ?? 0.0) <=
                                                    60
                                                    ? Colors.yellow
                                                    : Colors.green,
                                              )
                                                  : CircularPercentIndicator(
                                                radius: 25.sp,
                                                lineWidth: 8.sp,
                                                animation: true,
                                                percent: 0.0,
                                                center: Text(
                                                  "0.0%",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 9.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                circularStrokeCap: CircularStrokeCap
                                                    .round,
                                                progressColor: Colors.red,
                                              ),
                                            ),

                                            Text(
                                              categoryPerformance[index]['category']
                                                  .toString(),
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                    : List.generate(4, (index) {
                                  return Container(
                                    height: 60.sp,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: Offset(0, 1),
                                        ),
                                      ],

                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(8.sp),
                                              child: CircularPercentIndicator(
                                                radius: 25.sp,
                                                lineWidth: 8.sp,
                                                animation: true,
                                                percent: (0 / 100)
                                                    .clamp(0.0, 1.0),
                                                center: Text(
                                                  "${(0 < 0 ? 0 : 0)
                                                      .toStringAsFixed(1)}%",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontSize: 10.sp,
                                                      color: Colors.white),
                                                ),
                                                circularStrokeCap: CircularStrokeCap
                                                    .round,
                                                progressColor: 0 < 40
                                                    ? Colors.red
                                                    : 0 >= 40 &&
                                                    0 <= 60
                                                    ? Colors.yellow
                                                    : Colors.green,
                                              )
                                          ),

                                          // Text(
                                          //   categoryPerformance[index]['category'].toString(),
                                          //   style: GoogleFonts.roboto(
                                          //     textStyle: TextStyle(
                                          //         color: Colors.white,
                                          //         fontSize: 12.sp,
                                          //         fontWeight: FontWeight.bold),
                                          //   ),                                        ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                ),
                              ),
                            ),
                          )
                      )


                  ),


                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Current Plan',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: Container(
                      height: 100.sp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Container(
                              height: 70.sp,
                              // Set an appropriate height for the ListView
                              child: plan.isNotEmpty ?
                              ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // Make it scroll horizontally
                                itemCount: plan.length,
                                // Number of items in the list
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return InvoicePage(data: plan[index],);
                                            },
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(2.sp),
                                        child: Container(
                                          width: 90.sp,
                                          // Set the width of each item
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                10.sp), // Adjust for roundness
                                            border: Border.all(
                                              color: HexColor(
                                                  plan[index]['plan']['color']),
                                              // Border color
                                              width: 1.sp, // Border width
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 2.sp,
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius
                                                    .circular(10.sp),
                                                child: SizedBox(
                                                  height: 40.sp,
                                                  width: 40.sp,
                                                  child: Image.network(
                                                    '${baseUrlImage}${plan[index]['plan']['image']
                                                        .toString()}',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.sp,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Text(
                                                  '${plan[index]['plan']['category']['name']
                                                      .toString()} ${plan[index]['plan']['name']
                                                      .toUpperCase()}',
                                                  maxLines: 1,
                                                  style: GoogleFonts.cabin(
                                                    textStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight
                                                            .normal),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ) :
                              Center(child: Text('Plan not active',
                                style: TextStyle(color: Colors.black),))
                          )


                      ),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.only(top: 15.sp, right: 0.sp),
                    child: Row(
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.sp, right: 0.sp),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              title: Text(
                                'Download',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:   Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  color: primaryColor,
                                  child: Icon(Icons.download,
                                    color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DownloadPdf();
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),

                            ListTile(
                              title: Text(
                                'DoubtStatus',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:  Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset(
                                    doubt, color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DoubtStatusPage();
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),


                            ListTile(
                              title: Text(
                                'Orders',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:  Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset(
                                    checklist, color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OrdersPage();
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),

                            ListTile(
                              title: Text(
                                'Update Password',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:  Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset(
                                    changePass, color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ResetPasswordPage();
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),




                            ListTile(
                              title: Text(
                                'Help',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:  Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset(
                                    help, color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return HelpScreen(appBar: 'Help',);
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),




                            ListTile(
                              title: Text(
                                'Privacy',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing:       Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(Icons.privacy_tip,
                                    color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return WebViewExample(title: 'Privacy',
                                        url: 'https://ksadmission.in/privacy-policy',);
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),



                            ListTile(
                              title: Text(
                                'Terms & Condition',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),

                              trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(Icons.event_note_outlined,
                                    color: Colors.white,)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return WebViewExample(
                                        title: 'Terms & Condition',
                                        url: 'https://ksadmission.in/privacy-policy',);
                                    },
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
                              child: Divider(
                                height: 1.sp,
                                color: Colors.grey.shade300,
                                thickness: 1.sp,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Logout',
                                style: GoogleFonts.cabin(textStyle:
                                TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal),
                                ),
                              ),


                              trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(
                                    Icons.logout, color: Colors.white,)),

                              onTap: () {
                                logoutApi(context);
                              },
                            ),


                          ],
                        ),
                      ),

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showAddBalanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: BoxDecoration(
          color: homepageColor.withOpacity(.5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Add Balance",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Enter amount",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Minimum amount ₹1000",
                  style: TextStyle(
                    color:HexColor('#950606'),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      amountController.clear();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:HexColor('#950606'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      double? amount = double.tryParse(amountController.text);
                      if (amount != null && amount >= 1000) {
                        // _addBalance(amountController.text.toString());
                        ordersCreateApi(amountController.text.toString());
                        // amountController.clear();
                        Navigator.pop(context);
                        showLoadingDialog(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Enter a valid amount (minimum ₹1000)",
                          toastLength: Toast.LENGTH_LONG,  // or Toast.LENGTH_LONG
                          gravity: ToastGravity.CENTER,     // Position: TOP, CENTER, BOTTOM
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: homepageColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User manually dialog close na kar sake
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Please wait...")
            ],
          ),
        );
      },
    );
  }
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _addBalance(String amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri uri = Uri.parse(addWallet); // Replace with your actual API URL
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final Map<String, dynamic> body = {'amount': amount};

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        setState(() {
          walletBalance = jsonData['data']['new_balance'].toString(); // Update balance from response
        });

        _showPaymentSuccessDialog(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Balance updated successfully!"),
          backgroundColor: Colors.green,
        ));

        // if (jsonData['success'] == true) {
        //   setState(() {
        //     walletBalance = jsonData['data']['new_balance'].toString(); // Update balance from response
        //   });
        //
        //   _showPaymentSuccessDialog(context);
        //
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text("Balance updated successfully!"),
        //     backgroundColor: Colors.green,
        //   ));
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text(jsonData['message'] ?? "Failed to update wallet"),
        //     backgroundColor: Colors.red,
        //   ));
        // }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: Unable to add balance"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Network Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }



  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${nickname}',
        'order_id': '${razorpayOrderId}',
        'description': 'Subscription',
        'prefill': {
          'contact': '${contact}',
          'email': '${userEmail}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
        hideLoadingDialog(context); // Dialog Band Karega

      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Success callback
    print("Payment Successful: ${response.paymentId}");
    // Required fields
    String orderId = response.orderId ?? "";
    String paymentId = response.paymentId ?? "";
    String signature = response.signature ?? "";

    // Additional data
    String status = "success";
    String currency = "INR";
    String paymentMethod = "UPI"; // Example
    String txnDate = DateTime.now().toString();

    // // Send to server or next steps
    // print("Order ID: $orderId");
    // print("Payment ID: $paymentId");
    // print("Signature: $signature");
    // print("Amount: $amount");
    // print("Currency: $currency");
    // print("Status: $status");
    // print("Payment Method: $paymentMethod");
    // print("Transaction Date: $txnDate");

    // SubscriptionAPI();

      StorePaymnet(amountController.text.toString(),orderId,paymentId,currency,status,signature,paymentMethod,txnDate,null,'',null,);
      Navigator.pop(context);



    print(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });

    String orderId = '';
    String paymentId = '';
    String signature = '';

    // Additional data
    String status = "Failed";
    String currency = "INR";
    String paymentMethod = "UPI"; // Example
    String txnDate = DateTime.now().toString();
      StorePaymnet(amountController.text.toString(),orderId,paymentId,currency,status,signature,paymentMethod,txnDate,response.code,response.message,response.error);




    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }


  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Payment Successful',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Your payment has been processed successfully!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }



  void _showPaymentFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 50), // Failure Icon
              SizedBox(height: 10),
              Text(
                'Payment Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/payment_failed.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Your payment has been Failed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> StorePaymnet(
      String price,
      String orderId,
      String paymentId,
      String currency,
      String status,
      String signature,
      String paymentMethod,
      String txnDate,
      int? errorCode,
      String? errorDescription,
      Map<dynamic, dynamic>? failureReason,
      ) async {
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

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
      'id',
    );
    final String? token = prefs.getString(
      'token',
    );

    Map<String, dynamic> responseData = {
      "order_id": orderId,
      "payment_id": paymentId,
      "amount": price,
      "currency": currency,
      "status": status,
      "signature": signature,
      "payment_method": paymentMethod,
      "txn_date": txnDate,
      "error_code": errorCode,
      "error_description": errorDescription,
      "failure_reason": '',
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(paymentStore),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        _addBalance(amountController.text.toString());

      } else {
        Navigator.pop(context);
        _showPaymentFailedDialog(context);

        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }
}

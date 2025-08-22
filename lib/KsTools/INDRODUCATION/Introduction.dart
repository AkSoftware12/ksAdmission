import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // For animations
import '../../HexColorCode/HexColor.dart';
import '../../baseurl/baseurl.dart';
import '../Counselor/counselor_payment.dart';
import '../Main/stateallindia.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage>with SingleTickerProviderStateMixin {

late AnimationController _controller;
late Animation<double> _animation;
  bool isLoading = false;
  // Map<String, dynamic>? dataGuid;
List<dynamic> dataGuid = [];

Map<String, dynamic>? dataPlan;
  bool isPaid = false; // Set based on API response
  String? errorMessage;

  String subsid = "0";
  String planId = "";
  String price = "";
  String type = "";

  // String price = "";
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  dynamic currency = '';
  String _selectedPayment = 'Wallet'; // Default selected payment method

  Set<String> selectedVendorIds = Set<String>();

  // List<String> selectedIds = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;

  bool isDataLoading = true;

  String? razorpayOrderId = '';
  String? razorpayKeyId = '';
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';

  @override
  void initState() {
    planCheckApi();
    razorpayKeyData();
    super.initState();
    fetchProfileData();

    fetchData();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }


@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("token: $token");

      final response = await http.get(
        Uri.parse(counselingToolGuidPageData),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('categories')) {
          setState(() {
            dataGuid = responseData['categories'];
            dataPlan = responseData['plan'];
            isLoading = false;
          });
        } else {
          throw Exception('Invalid API response: Missing "plans" key');
        }

      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }


void _showPaymentSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.transparent, // Transparent to show background
          contentPadding: EdgeInsets.zero, // Remove default padding
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                ), // Replace with your background image URL
                fit: BoxFit.cover,
                // colorFilter: ColorFilter.mode(
                //   Colors.black.withOpacity(0.5), // Dark overlay for readability
                //   BlendMode.darken,
                // ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 80,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Successful',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your payment has been processed successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      hideLoadingDialog(context);
                      Navigator.pop(context);
                      planCheckApi();


                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Homepage(
                      //       initialIndex: 0,
                      //     ),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
  void _showPaymentFailedDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            '${'Payment Failed'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.asset('assets/payment failed.png')),
              ),
              SizedBox(height: 10),
              Text(
                'Your payment has been ${' Failed'}!',
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

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        nickname = jsonData['user']['name'];
        userEmail = jsonData['user']['email'];
        contact = jsonData['user']['contact'].toString();
        // address = jsonData['user']['bio'];
      });
    } else {
      throw Exception('Failed to load profile data');
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

  Future<void> createPlan() async {
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
      "plan_id": dataPlan?['id'],
      "user_id": userId.toString(),
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(planCreate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );
      hideLoadingDialog(context);

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        createPlan2();

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Homepage(
        //       initialIndex: 0,
        //     ),
        //   ),
        // );
      } else {
        Navigator.pop(context);
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> createPlan2() async {
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
      "plan_id": dataPlan?['id'],
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(counselingToolEntry),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );
      hideLoadingDialog(context);

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        _showPaymentSuccessDialog(context);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Homepage(
        //       initialIndex: 0,
        //     ),
        //   ),
        // );
      } else {
        Navigator.pop(context);
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> planCheckApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
      'id',
    );
    final String? token = prefs.getString(
      'token',
    );

    Map<String, dynamic> responseData = {
      "plan_id": dataPlan?['id'],
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(counselingToolCheck),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );
      // hideLoadingDialog(context);

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        isPaid = true;
      } else if (response.statusCode == 400) {
        isPaid = false;
      } else {
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
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
      "amount": price.toString(),
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
        // createPlan();
        createPlan2();
      } else {
        Navigator.pop(context);
        _showPaymentFailedDialog(context);

        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
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
        'prefill': {'contact': '${contact}', 'email': '${userEmail}'},
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


Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background Image
        Container(
          color: HexColor('#f2f5ff'),
          height: double.infinity,
          child: Opacity(
            opacity: 1,
            child: Image.asset(
              'assets/tools_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Sliver-based Scroll View
        CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.sp),
                    bottomRight: Radius.circular(20.sp),
                  ),
                  child: AppBar(
                    backgroundColor: HexColor('#5e19a1'),
                    elevation: 2,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Ks Counselling Tool',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
                        onPressed: () {
                          // Add info action
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main Content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 0.sp),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Counselor Card
                  CounselorCard(),
                  // Dynamic List of Expansion Items
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: HexColor('#5e19a1'),
                      ),
                    )
                  else if (errorMessage != null)
                    Center(
                      child: Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (dataGuid.isEmpty)
                      Center(
                        child: Text(
                          'No data available',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.blueGrey,
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        dataGuid.length,
                            (index) {
                          var item = dataGuid[index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            child: _buildExpansionItem(
                              icon: Icons.info,
                              text: item['title'],
                              children: [
                                _buildSubItem(context, item['description'].toString()),
                              ],
                            ),
                          );
                        },
                      ),
                ]),
              ),
            ),
          ],
        ),
        // Floating Pay/Go Button
        Align(
          alignment: Alignment.bottomCenter,
          child: FadeInUp(
            duration: Duration(milliseconds: 1000),
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.sp),
              child: GestureDetector(
                onTap: () {
                  if (isPaid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PredictionOptionsScreen(),
                      ),
                    );
                    print('Go button pressed');
                  } else {
                    _showPaymentBottomSheet(dataPlan?['price'].toString() ?? '0');
                    print('Pay button pressed');
                  }
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: Container(
                        height: 48.sp,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HexColor('#5e19a1'),
                              Colors.purple.shade200,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isPaid
                              ? Text(
                            'Go',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          )
                              : AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PAY ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      '₹ ${dataPlan?['originalPrice']?.toString() ?? '5000'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 3,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '₹ ${dataPlan?['discountedPrice']?.toString() ?? '3500'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'OFFER',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Future<void> walletBalancePayApi(String amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri uri =
        Uri.parse(payWalletBalance); // Replace with your actual API URL
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

        if (jsonData['success'] == true) {
          setState(() {
            // createPlan();
            createPlan2();
          });
        } else {
          hideLoadingDialog(context);
        }
      } else {
        hideLoadingDialog(context);

        Fluttertoast.showToast(
          msg: "Insufficient Balance",
          toastLength: Toast.LENGTH_LONG,
          // or Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM,
          // Position: TOP, CENTER, BOTTOM
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // _showInsufficientBalanceDialog(context);
      }
    } catch (e) {
      hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Network Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text("Insufficient Balance",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
            "You do not have enough balance to complete this transaction. Please add funds."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to the Add Funds page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Add Funds"),
          ),
        ],
      ),
    );
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

    StorePaymnet(
      '${dataPlan!['price'].toString()}',
      orderId,
      paymentId,
      currency,
      status,
      signature,
      paymentMethod,
      txnDate,
      null,
      '',
      null,
    );

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

    StorePaymnet(
        dataPlan!['price'].toString(),
        orderId,
        paymentId,
        currency,
        status,
        signature,
        paymentMethod,
        txnDate,
        response.code,
        response.message,
        response.error);

    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }

  void _showPaymentBottomSheet(String price) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Wallet Option with Card Style
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPayment = "Wallet");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedPayment == "Wallet"
                            ? Colors.blue.shade50
                            : Colors.white,
                        border: Border.all(
                          color: _selectedPayment == "Wallet"
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: Colors.blue, size: 28),
                          SizedBox(width: 15),
                          Expanded(
                              child: Text("Wallet",
                                  style: TextStyle(fontSize: 16))),
                          Icon(
                            _selectedPayment == "Wallet"
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: _selectedPayment == "Wallet"
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Razorpay Option with Card Style
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPayment = "Razorpay");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedPayment == "Razorpay"
                            ? Colors.green.shade50
                            : Colors.white,
                        border: Border.all(
                          color: _selectedPayment == "Razorpay"
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.green, size: 28),
                          SizedBox(width: 15),
                          Expanded(
                              child: Text("Razorpay",
                                  style: TextStyle(fontSize: 16))),
                          Icon(
                            _selectedPayment == "Razorpay"
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: _selectedPayment == "Razorpay"
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // Confirm Button with Gradient
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showLoadingDialog(context);
                      _handlePaymentSelection();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: homepageColor,
                    ),
                    child: Text(
                      "Confirm Payment",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handlePaymentSelection() {
    if (_selectedPayment == 'Wallet') {
      walletBalancePayApi(dataPlan!['price'].toString());
    } else {
      ordersCreateApi(dataPlan!['price'].toString());
    }
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


// Build the expansion item (no top/bottom lines)
  Widget _buildExpansionItem({
    required IconData icon,
    required String text,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(15)
      ),

      child: Padding(
        padding:  EdgeInsets.all(5.sp),
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent, // Remove ExpansionTile dividers
          ),
          child: Center(
            child: ExpansionTile(
              leading: Icon(
                icon,
                size: 24.sp,
                color:HexColor('#7209B7'),
              ),
              title: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: HexColor('#124559'),
                  fontWeight: FontWeight.w600,
                ),
              ),
              childrenPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  // Build the sub-item (renders HTML content)
  Widget _buildSubItem(BuildContext context, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),

        child: Padding(
          padding:  EdgeInsets.all(10.sp),
   child: SingleChildScrollView(
     child: Text(
          content != 'null' && content.toString().isNotEmpty
              ? content.toString()
              : 'No data found',
          style: GoogleFonts.notoSans(
            fontSize: 14.sp,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
   ),


        ),        // child: Html(
        //   data: content,
        //   style: {
        //     "p": Style(
        //       fontSize: FontSize(14.sp),
        //       margin: Margins.all(8),
        //     ),
        //     "h4": Style(
        //       fontSize: FontSize(16.sp),
        //       fontWeight: FontWeight.bold,
        //     ),
        //     "li": Style(
        //       fontSize: FontSize(14.sp),
        //       // margin: Margins(left: 16, top: 4, bottom: 4),
        //     ),
        //     "table": Style(
        //       fontSize: FontSize(12.sp),
        //       border: Border.all(color: Colors.grey),
        //     ),
        //     "td": Style(
        //       padding: HtmlPaddings.all(4),
        //       border: Border.all(color: Colors.grey),
        //     ),
        //   },
        //   onLinkTap: (url, _, __) {
        //     // Handle link taps (e.g., open in browser)
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text('Tapped link: $url')),
        //     );
        //   },
        // ),
      ),
    );
  }
}


class CounselorCard extends StatefulWidget {
  const CounselorCard({super.key});

  @override
  _CounselorCardState createState() => _CounselorCardState();
}

class _CounselorCardState extends State<CounselorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 12.sp),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12.r),
          shadowColor: Colors.black.withOpacity(0.2),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CounselorPaymentPage(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                  [

                    HexColor('#FF5F6D'),
                    HexColor('#FFC371')

                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(3.sp),
              child: Row(
                children: [
                  SizedBox(
                    height: 40.sp,
                    width: 40.sp,
                    child: Image.asset(
                      'assets/support.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error, size: 30.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect With Your Counselor',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          semanticsLabel: 'Connect with your counselor',
                        ),
                        Text(
                          'Get personalized guidance now',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CounselorPaymentPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.sp,
                              vertical: 0.sp,
                            ),
                          ),
                          child: Text(
                            'Click Here',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

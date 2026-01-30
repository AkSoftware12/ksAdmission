import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/CommonCalling/progressbarPrimari.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../ContainerShape/container.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../baseurl/baseurl.dart';

class PlanScreen extends StatefulWidget {
  final String appBar;

  const PlanScreen({super.key, required this.appBar});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String subsid = "0";
  String planId = "";
  String price = "";
  String type = "";
  Razorpay _razorpay = Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  dynamic currency = '';
  String _selectedPayment = 'Razorpay'; // Default selected payment method

  Set<String> selectedVendorIds = {};
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

  List<dynamic> allPlan = [];

  // ✅ FIX: loader stuck / double dialog prevent
  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    razorpayKeyData();
    hitPlan();
    fetchProfileData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> hitPlan() async {
    try {
      setState(() => isDataLoading = true);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? userId = preferences.getInt('user_id');
      String? token = preferences.getString('token');

      if (token == null) {
        throw Exception('Token not found!');
      }

      final Uri uri = Uri.parse(
        plan,
      ).replace(queryParameters: {'user_id': userId?.toString()});

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('plans')) {
          setState(() {
            allPlan = responseData['plans'];
            isDataLoading = false;
          });
        } else {
          throw Exception('Invalid API response: Missing "plans" key');
        }
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isDataLoading = false);
      Fluttertoast.showToast(
        msg: "Error loading plans: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(getProfile);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          nickname = jsonData['user']['name'];
          userEmail = jsonData['user']['email'];
          contact = jsonData['user']['contact'].toString();
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading profile: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  Future<void> razorpayKeyData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(razorpayKayId);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          razorpayKeyId = jsonData['razor_pay_company_id'].toString();
          print('razorPayId$razorpayKeyId');
          // razorpayKeyId = jsonData['razor_pay_id'].toString();
        });
      } else {
        throw Exception('Failed to load Razorpay key');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading Razorpay key: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  Future<void> ordersCreateApi(String price) async {
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('id');
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      Map<String, dynamic> requestBody = {
        "amount": (double.parse(price) * 100).toInt(),
        "currency": "INR",
      };

      final response = await http.post(
        Uri.parse(ordersCompanyIdRazorpay),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          razorpayOrderId = jsonData['data']['id'].toString();
          print('razorPayOrdersId$razorpayOrderId');
        });

        // ✅ FIX: order create success pe loader close karo, phir checkout open
        hideLoadingDialog(context);

        openCheckout(razorpayKeyId, double.parse(price) * 100);
      } else {
        hideLoadingDialog(context);
        Fluttertoast.showToast(
          msg: "Failed to create order: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.sp,
        );
      }
    } catch (e) {
      hideLoadingDialog(context);
      Fluttertoast.showToast(
        msg: "Error creating order: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  Future<void> createPlan() async {
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('id');
      final String? token = prefs.getString('token');

      Map<String, dynamic> responseData = {
        "plan_id": planId,
        "user_id": userId.toString(),
      };

      final response = await http.post(
        Uri.parse(planCreate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(responseData),
      );

      hideLoadingDialog(context);

      if (response.statusCode == 200) {
        if (type == '6') {
          _showPaymentSuccessDialog2(context);
        } else {
          _showPaymentSuccessDialog(context);
        }
      } else {
        _showPaymentFailedDialog(context);
      }
    } catch (e) {
      hideLoadingDialog(context);
      _showPaymentFailedDialog(context);
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
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

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

      final response = await http.post(
        Uri.parse(paymentStore),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(responseData),
      );

      if (response.statusCode == 200) {
        // ✅ (optional) loader close safe - createPlan me again show hota hai
        hideLoadingDialog(context);
        createPlan();
      } else {
        hideLoadingDialog(context);
        _showPaymentFailedDialog(context);
      }
    } catch (e) {
      hideLoadingDialog(context);
      _showPaymentFailedDialog(context);
    }
  }

  Future<void> walletBalancePayApi(String amount) async {
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final Uri uri = Uri.parse(payWalletBalance);
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final Map<String, dynamic> body = {'amount': amount};

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          // ✅ loader close safe
          hideLoadingDialog(context);
          createPlan();
        } else {
          hideLoadingDialog(context);
          _showInsufficientBalanceDialog(context);
        }
      } else {
        hideLoadingDialog(context);
        _showInsufficientBalanceDialog(context);
      }
    } catch (e) {
      hideLoadingDialog(context);
      Fluttertoast.showToast(
        msg: "Network Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  void openCheckout(keyRazorPay, amount) async {
    // ❌ yaha timer/loader close ki need nahi, but aapka flow same rakh raha hu
    Timer(const Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': keyRazorPay,
        'amount': amount,
        'name': nickname,
        'order_id': razorpayOrderId,
        'description': 'Subscription',
        'prefill': {'contact': contact, 'email': userEmail},
        'external': {
          'wallets': ['paytm'],
        },
      };

      try {
        _razorpay.open(options);

        // ✅ FIX: agar loader open hai to close kar do (safety)
        hideLoadingDialog(context);
      } catch (e) {
        hideLoadingDialog(context);
        Fluttertoast.showToast(
          msg: "Error initiating payment: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.sp,
        );
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // ✅ FIX: safety - agar loader chal raha ho to band
    hideLoadingDialog(context);

    String orderId = response.orderId ?? "";
    String paymentId = response.paymentId ?? "";
    String signature = response.signature ?? "";
    String status = "success";
    String currency = "INR";
    String paymentMethod = "UPI";
    String txnDate = DateTime.now().toString();

    StorePaymnet(
      price,
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
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // ✅ FIX: payment fail pe loader band zaroor hona chahiye
    hideLoadingDialog(context);

    setState(() => showDialogBox = false);
    String orderId = '';
    String paymentId = '';
    String signature = '';
    String status = "Failed";
    String currency = "INR";
    String paymentMethod = "UPI";
    String txnDate = DateTime.now().toString();

    StorePaymnet(
      price,
      orderId,
      paymentId,
      currency,
      status,
      signature,
      paymentMethod,
      txnDate,
      response.code,
      response.message,
      response.error,
    );

    Fluttertoast.showToast(
      msg: "Payment Error: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.sp,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // ✅ FIX: external wallet pe bhi safety close
    hideLoadingDialog(context);

    Fluttertoast.showToast(
      msg: "External Wallet: ${response.walletName}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.sp,
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
                SizedBox(height: 16.sp),
                Text(
                  'Payment Successful',
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Your payment has been processed successfully!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(initialIndex: 0),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 12.sp,
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.radioCanada(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSuccessDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
                SizedBox(height: 16.sp),
                Text(
                  'Payment Successful',
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Your payment has been successfully processed! Plan will be active within 24 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(initialIndex: 0),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 12.sp,
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.radioCanada(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/payment_failed.jpeg',
                  height: 80.sp,
                  width: 80.sp,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Payment Failed',
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Your payment could not be processed. Please try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 12.sp,
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.radioCanada(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 60.sp, color: Colors.red),
              SizedBox(height: 16.sp),
              Text(
                "Insufficient Balance",
                style: GoogleFonts.radioCanada(
                  textStyle: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 8.sp),
              Text(
                "You do not have enough balance to complete this transaction. Please add funds.",
                textAlign: TextAlign.center,
                style: GoogleFonts.radioCanada(
                  textStyle: TextStyle(fontSize: 15.sp, color: Colors.black54),
                ),
              ),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.radioCanada(
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.sp),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to Add Funds page (implement as needed)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.sp,
                        vertical: 12.sp,
                      ),
                    ),
                    child: Text(
                      "Add Funds",
                      style: GoogleFonts.radioCanada(
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.appBar.isEmpty ? homepageColor : Colors.white,
      appBar: widget.appBar.isEmpty
          ? null
          : AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF010071),
                Color(0xFF0A1AFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Subscription Plans',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Choose the plan that fits you",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationList()),
                );
              },
            ),
          ),
        ],
      ),
      body: isDataLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: 25,
              color: widget.appBar.isEmpty ? Colors.white : Colors.blue,
            ),
            SizedBox(height: 16.sp),
            Text(
              "Loading Plans...",
              style: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 5.sp,
                vertical: 0.sp,
              ),
              itemCount: allPlan.length,
              itemBuilder: (context, index) {
                final status = allPlan[index]['userPlanStatus'];

                final isClickable = status == 'Inactive' || status == 'Expired';

                String buttonText;
                if (status == 'Inactive') {
                  buttonText = 'Purchase';
                } else if (status == 'Expired') {
                  buttonText = 'Renew';
                } else {
                  buttonText = status; // Active
                }

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  child: PremiumPlanCard(
                    plan: allPlan[index],
                    buttonText: buttonText,
                    isClickable: isClickable,
                    onContinue: () {
                      if (!isClickable) return;

                      setState(() {
                        planId = allPlan[index]['id'].toString();
                        price = allPlan[index]['price'].toString();
                        type = allPlan[index]['type'].toString();
                      });

                      _showPaymentBottomSheet(price);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentBottomSheet(String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Payment Method",
                    style: GoogleFonts.radioCanada(
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  _buildPaymentOption(
                    icon: Icons.payment,
                    title: "Razorpay",
                    isSelected: _selectedPayment == "Razorpay",
                    onTap: () => setState(() => _selectedPayment = "Razorpay"),
                  ),
                  SizedBox(height: 20.sp),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      // ✅ FIX: yaha se showLoadingDialog hata diya (double dialog issue)
                      _handlePaymentSelection();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      backgroundColor: primaryColor,
                      elevation: 3,
                    ),
                    child: Text(
                      "Confirm Payment",
                      style: GoogleFonts.radioCanada(
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.sp),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.shade600,
              size: 28.sp,
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.radioCanada(
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? primaryColor : Colors.black87,
                  ),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : Colors.grey.shade600,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentSelection() {
    ordersCreateApi(price);
    // if (_selectedPayment == 'Wallet') {
    //   walletBalancePayApi(price);
    // } else {
    //   ordersCreateApi(price);
    // }
  }

  // ✅ FIXED showLoadingDialog/hideLoadingDialog (no crash, no stuck)
  void showLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShowing) return; // ✅ prevent stacking
    _isLoadingDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30.sp, child: PrimaryCircularProgressWidget()),
                SizedBox(width: 16.sp),
                Text(
                  "Processing...",
                  style: GoogleFonts.radioCanada(
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _isLoadingDialogShowing = false;
    });
  }

  void hideLoadingDialog(BuildContext context) {
    if (!_isLoadingDialogShowing) return;

    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    _isLoadingDialogShowing = false;
  }
}

class PremiumPlanCard extends StatelessWidget {
  final dynamic plan;
  final VoidCallback onContinue;
  final bool isClickable;
  final String buttonText;

  const PremiumPlanCard({
    super.key,
    required this.plan,
    required this.onContinue,
    required this.isClickable,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = HexColor(plan['color'].toString());
    final String imageUrl = plan['image_url'].toString();
    final String category = plan['category']['name'].toString();
    final String planName = plan['name'].toString();
    final String desc = (plan['desc'] ?? '').toString();
    final String price = plan['price'].toString();

    final bool isActive = plan['userPlanStatus'].toString() == "Active";

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: const Color(0xFF0A1AFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.sp),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                height: 170.sp,
                width: 170.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -70,
              child: Container(
                height: 190.sp,
                width: 190.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 54.sp,
                        width: 54.sp,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16.sp),
                          border: Border.all(
                            color: accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Image.network(
                            imageUrl,
                            color: accent,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.black45,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                            SizedBox(height: 6.sp),
                            Text(
                              planName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 10.sp,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.sp),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 2.sp),
                            Text(
                              "₹ $price",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  Container(height: 1, width: double.infinity, color: Colors.black12),
                  SizedBox(height: 10.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 20.sp,
                        width: 20.sp,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5.sp),
                          border: Border.all(
                            color: accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.check_rounded, size: 18.sp, color: accent),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          "Mock Test",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20.sp,
                          width: 20.sp,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5.sp),
                            border: Border.all(
                              color: accent.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.check_rounded, size: 18.sp, color: accent),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            "Test Series",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20.sp,
                          width: 20.sp,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5.sp),
                            border: Border.all(
                              color: accent.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.check_rounded, size: 18.sp, color: accent),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            "Previous Paper",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20.sp,
                          width: 20.sp,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5.sp),
                            border: Border.all(
                              color: accent.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.check_rounded, size: 18.sp, color: accent),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            "Duration: 180 days",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 20.sp,
                          width: 20.sp,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5.sp),
                            border: Border.all(
                              color: accent.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.check_rounded, size: 18.sp, color: accent),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Text(
                            desc.isEmpty ? "Premium access for your preparation." : desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.sp),
                  Padding(
                    padding: EdgeInsets.all(6.sp),
                    child: SizedBox(
                      height: 46.sp,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.sp),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: isClickable ? 1 : 0.55,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(18.sp),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: isClickable ? onContinue : null,
                              splashColor: Colors.white.withOpacity(0.12),
                              highlightColor: Colors.white.withOpacity(0.06),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.sp),
                                  gradient: LinearGradient(
                                    colors: isActive
                                        ? const [
                                      Color(0xFF22C55E),
                                      Color(0xFF16A34A),
                                    ]
                                        : [
                                      accent,
                                      accent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(isActive ? 0.28 : 0.22),
                                    width: 1,
                                  ),
                                  boxShadow: isClickable
                                      ? [
                                    BoxShadow(
                                      color: (isActive
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFF2563EB))
                                          .withOpacity(0.40),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(7.sp),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(14.sp),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.22),
                                          ),
                                        ),
                                        child: Icon(
                                          isActive ? Icons.verified : Icons.currency_rupee_rounded,
                                          size: 18.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10.sp),
                                      Text(
                                        isActive ? "ACTIVE" : "Pay ₹ $price",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12.sp,
              right: 12.sp,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8.sp,
                      width: 8.sp,
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 6.sp),
                    Text(
                      isActive ? "Active" : "Plan",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: accent,
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

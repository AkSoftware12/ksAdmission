import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  String _selectedPayment = 'Wallet'; // Default selected payment method

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

      final Uri uri = Uri.parse(plan).replace(queryParameters: {
        'user_id': userId?.toString(),
      });

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
          razorpayKeyId = jsonData['razor_pay_id'].toString();
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
        Uri.parse(ordersIdRazorpay),
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
          openCheckout(razorpayKeyId, double.parse(price) * 100);
        });
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
    Timer(const Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': keyRazorPay,
        'amount': amount,
        'name': nickname,
        'order_id': razorpayOrderId,
        'description': 'Subscription',
        'prefill': {'contact': contact, 'email': userEmail},
        'external': {'wallets': ['paytm']}
      };

      try {
        _razorpay.open(options);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
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
                    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
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
                    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/payment_failed.png',
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
                    padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
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
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                  ),
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
                      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
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
      backgroundColor: homepageColor,
      appBar: widget.appBar.isEmpty
          ? null
          : AppBar(
        backgroundColor: homepageColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Subscription Plans",
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: isDataLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
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
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      itemCount: allPlan.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        child: GestureDetector(
            onTap: () {
              // Add navigation or action if needed
            },
            child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.sp),
                    border: Border.all(
                      color: HexColor('#E0E0E0'),
                      width: 1.sp,
                    ),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  child: Image.network(
                                    allPlan[index]['image_url'].toString(),
                                    height: 40.sp,
                                    width: 40.sp,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Flexible(
                                  child: Text(
                                    '${allPlan[index]['category']['name']} ${allPlan[index]['name'].toUpperCase()}',
                                    style: GoogleFonts.radioCanada(
                                      textStyle: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor(allPlan[index]['color'].toString()),
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (allPlan[index]['userPlanStatus'] == 'Active')
                            Container(
                              padding: EdgeInsets.all(6.sp),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.sp),
                      _buildFeatureRow(
                        icon: Icons.check_circle,
                        text: 'Mock Test',
                        color: HexColor(allPlan[index]['color'].toString()),
                      ),
                      _buildFeatureRow(
                          icon: Icons.check_circle,
                          text: 'Test Series',
                        color: HexColor(allPlan[index]['color'].toString()),
                ),
                _buildFeatureRow(
                  icon: Icons.check_circle,
                  text: 'Previous Paper',
                  color: HexColor(allPlan[index]['color'].toString()),
                ),
                _buildFeatureRow(
                  icon: Icons.check_circle,
                  text: 'Duration: ${allPlan[index]['duration_in_days']} days',
                  color: HexColor(allPlan[index]['color'].toString()),
                ),
                if (allPlan[index]['desc'] != null)
            Padding(
        padding: EdgeInsets.only(top: 8.sp),
        child: Html(
          data: allPlan[index]['desc'] ?? '',
          style: {
            'body': Style(
              fontSize: FontSize(15.sp),
              fontWeight: FontWeight.w500,
              color: HexColor(allPlan[index]['color'].toString()),
            ),
          },
        ),
      ),
      SizedBox(height: 16.sp),
      Center(
        child: Text(
          '₹ ${(double.parse(allPlan[index]['price'].toString())).toStringAsFixed(2)}',
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: HexColor(allPlan[index]['color'].toString()),
            ),
          ),
        ),
      ),
      SizedBox(height: 16.sp),
      Center(
        child: _buildActionButton(index),
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
    ],
    ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.sp),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(int index) {
    final status = allPlan[index]['userPlanStatus'];

    // Check whether the button should be clickable
    final isClickable = status == 'Inactive' || status == 'Expired';

    // Determine button text based on status
    String buttonText;
    if (status == 'Inactive') {
      buttonText = 'Purchase';
    } else if (status == 'Expired') {
      buttonText = 'Renew';
    } else {
      buttonText = status; // e.g. 'Active'
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40.sp,
      width: 150.sp,
      child: GestureDetector(
        onTap: isClickable
            ? () {
          setState(() {
            planId = allPlan[index]['id'].toString();
            price = allPlan[index]['price'].toString();
            type = allPlan[index]['type'].toString();
          });
          _showPaymentBottomSheet(allPlan[index]['price'].toString());
        }
            : null,
        child: Card(
          elevation: 4,
          color: HexColor(allPlan[index]['color'].toString()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
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
                  SizedBox(height: 20.sp),
                  _buildPaymentOption(
                    icon: Icons.account_balance_wallet,
                    title: "Wallet",
                    isSelected: _selectedPayment == "Wallet",
                    onTap: () => setState(() => _selectedPayment = "Wallet"),
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
                      showLoadingDialog(context);
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
    if (_selectedPayment == 'Wallet') {
      walletBalancePayApi(price);
    } else {
      ordersCreateApi(price);
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
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
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
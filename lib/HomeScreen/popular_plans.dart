import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_colors.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../baseurl/baseurl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PopularPlanScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const PopularPlanScreen({super.key, required this.data});

  @override
  State<PopularPlanScreen> createState() => _PopularPlanScreenState();
}

class _PopularPlanScreenState extends State<PopularPlanScreen> {
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

  Set<String> selectedVendorIds = Set<String>();

  // List<String> selectedIds = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;
  bool _isLoading = false;

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
    razorpayKeyData();
    super.initState();
    // hitPlan();
    fetchProfileData();
    print(' Tpye : $type');
  }

  void _handlePayment(dynamic price) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ordersCreateApi(price);
      Navigator.pop(context); // Close bottom sheet
      print("Payment Initiated");
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Confirm Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "You are about to pay for ${widget.data['name']}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Amount: ₹${widget.data['price'] ?? '0'}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  _handlePayment('${widget.data['price']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? PrimaryCircularProgressWidget(
                      )
                    : Text(
                        "Proceed to Pay",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentSuccessDialog2(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              SizedBox(height: 12),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Your payment has been successfully processed.\n'
                '${widget.data['name']} will be provided within 7 days.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  'For assistance, contact:\nksadmission451@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homepage(initialIndex: 0),
                  ),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
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
                  child: Image.asset('assets/payment failed.png'),
                ),
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
    final String? token = prefs.getString('token');
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
    final String? token = prefs.getString('token');
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

  Future<void> ordersCreateApi(dynamic price) async {
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

          openCheckout(razorpayKeyId, double.parse(widget.data['price']) * 100);
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
              PrimaryCircularProgressWidget(),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? token = prefs.getString('token');

    Map<String, dynamic> responseData = {
      "plan_id": widget.data['id'],
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

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        _showPaymentSuccessDialog2(context);
      } else {
        Navigator.pop(context);
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
              PrimaryCircularProgressWidget(),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? token = prefs.getString('token');

    Map<String, dynamic> responseData = {
      "order_id": orderId,
      "payment_id": paymentId,
      "amount": widget.data['price'],
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
        createPlan();
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
          'wallets': ['paytm'],
        },
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              onTap: () {
                Navigator.of(context).pop();
              },
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data['name'].toString(), // ✅ dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                 'Access complete course bundles', // ✅ dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: CachedNetworkImage(
                  imageUrl: widget.data['image_url'].toString(),
                  fit: BoxFit.fill,
                  // Adjust this according to your requirement
                  placeholder: (context, url) => Center(
                    child: PrimaryCircularProgressWidget(
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/no_image.jpg',
                    // Path to your default image asset
                    // Adjust width as per your requirement
                    fit: BoxFit
                        .cover, // Adjust this according to your requirement
                  ),
                ),
              ),
            ),
            // Image Section
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.data['name'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Description (HTML)
                  Html(
                    data: widget.data['desc'] ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: Colors.grey[700],
                      ),
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color:  HexColor('#010071').withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showPaymentBottomSheet,
          elevation: 0,
          backgroundColor: Colors.transparent,
          splashColor: Colors.white24,
          label: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              gradient: LinearGradient(
                colors: [
                  HexColor('#010071'),
                  HexColor('#010071').withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                SizedBox(width: 10.w),
                Text(
                  "Pay ₹ ${widget.data['price'] ?? '0'}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

    StorePaymnet(
      '${widget.data['price']}',
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
      '${widget.data['price']}',
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

    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }
}

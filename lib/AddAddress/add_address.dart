import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/AddAddress/sucees.dart';
import 'package:realestate/CommonCalling/progressbarPrimari.dart';
import '../HomePage/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/color_constants.dart';
import '../Utils/textSize.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Utils/image.dart';
import '../baseurl/baseurl.dart';



class AddAddress extends StatefulWidget {
  final int categoryId;
  final int planId;
  final int isSubject;
  final String price;
  const AddAddress({super.key, required this.categoryId, required this.price, required this.planId, required this.isSubject});

  @override
  _ClassDataFormState createState() => _ClassDataFormState();
}

class _ClassDataFormState extends State<AddAddress> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  Razorpay _razorpay = new Razorpay();


  String? razorpayOrderId = '';
  String? razorpayKeyId = '';

  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';
  var showDialogBox = false;


  List<dynamic> subjects = [];
  int? selectedSubject;



  Future<void> hitSubjectApi(int categoryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${subject}${categoryId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          subjects = responseData['data'];
        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    razorpayKeyData();
    super.initState();
    hitSubjectApi(widget.categoryId);
    fetchProfileData();

  }




  void _showPaymentFailedDialog(BuildContext context,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title:  Text(
            '${'Payment Failed'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:  [

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
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      // Validate and parse price
      if (price.isEmpty || double.tryParse(price) == null) {
        throw Exception('Invalid price value');
      }

      double parsedPrice = double.parse(price);
      int amountInPaise = (parsedPrice * 100).toInt();

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "amount": amountInPaise,
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
          openCheckout(
            razorpayKeyId,
            amountInPaise.toDouble(), // Use paise here too if your checkout expects it
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
              PrimaryCircularProgressWidget()
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
      "category_id": widget.categoryId,
      "plan_id": widget.planId,
      "subject_id": selectedSubject,
      "address": _addressController.text.toString(),
      "city": _cityController.text.toString(),
      "state": _stateController.text.toString(),
      "pin": _pinCodeController.text.toString(),
      "contact": _contactNumberController.text.toString(),
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(offlineplanCreate),
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccesOrderPlaced(

            ),
          ),
        );
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
              PrimaryCircularProgressWidget()
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

  bool isFormFilled() {
    if (_addressController.text.trim().isEmpty) return false;
    if (_cityController.text.trim().isEmpty) return false;
    if (_stateController.text.trim().isEmpty) return false;
    if (_pinCodeController.text.trim().length != 6) return false;
    if (_contactNumberController.text.trim().length != 10) return false;

    if (widget.isSubject == 1 && selectedSubject == null) return false;

    return true;
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
                    'Address', // ✅ dynamic
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Enter your delivery address accurately',
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
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              // height: 150.sp,
              width: double.infinity,
              child: Opacity(
                opacity: 0.1, // Adjust the opacity value (0.0 to 1.0)
                child: Image.asset(logo),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 90.h), // bottom extra for bottomSheet
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Top card header
                  Container(
                    padding: EdgeInsets.all(14.sp),
                    margin: EdgeInsets.only(bottom: 14.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.sp),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2563EB).withOpacity(0.10),
                          const Color(0xFF0EA5E9).withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFE8EEF8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42.sp,
                          width: 42.sp,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14.sp),
                          ),
                          child: Icon(Icons.location_on_rounded, color: const Color(0xFF2563EB), size: 22.sp),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery Details",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2.sp),
                              Text(
                                "Fill correct address to receive your offline package.",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject Dropdown
                  if (widget.isSubject == 1)
                    _premiumDropdown(
                      subjects: subjects,
                      value: selectedSubject,
                      onChanged: (v) => setState(() => selectedSubject = v),
                      validator: (v) => v == null ? 'Please select a subject' : null,
                    ),

                  _premiumField(
                    label: "Address",
                    controller: _addressController,
                    prefixIcon: Icons.home_rounded,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your address" : null,
                  ),
                  _premiumField(
                    label: "Pin Code",
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_drop_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Please enter your pin code";
                      if (v.trim().length != 6) return "Pin code must be 6 digits";
                      return null;
                    },
                  ),

                  _premiumField(
                    label: "City",
                    controller: _cityController,
                    prefixIcon: Icons.location_city_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your city" : null,
                  ),
                  _premiumField(
                    label: "State",
                    controller: _stateController,
                    prefixIcon: Icons.map_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your state" : null,
                  ),
                  _premiumField(
                    label: "Contact Number",
                    controller: _contactNumberController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.call_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Please enter your contact number";
                      if (v.trim().length != 10) return "Contact number must be 10 digits";
                      return null;
                    },
                  ),

                  SizedBox(height: 10.sp),
                ],
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
            border: const Border(
              top: BorderSide(color: Color(0xFFE8EEF8), width: 1),
            ),
          ),
          child: SizedBox(
            height: 44.h,
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.isSubject == 1) {
                      ordersCreateApi(widget.price); // ✅ yahi sahi hai
                    } else {
                      // createPlan();
                    }
                  }
                },
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: const Color(0xFF010071), // ✅ visible
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A1AFF).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white.withOpacity(0.22)),
                        ),
                        child: Icon(Icons.lock_rounded,
                            color: Colors.white, size: 18.sp),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Pay  ₹ ${widget.price}",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )

        ),
      ),

    );
  }

  Widget _premiumField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 12.8.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 14.sp),
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: prefixIcon == null
              ? null
              : Padding(
            padding: EdgeInsets.only(left: 12.sp, right: 10.sp),
            child: Icon(prefixIcon, size: 18.sp, color: const Color(0xFF2563EB)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: const Color(0xFFE8EEF8), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: const Color(0xFF2563EB), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _premiumDropdown({
    required List<dynamic> subjects,
    required int? value,
    required void Function(int?) onChanged,
    String? Function(int?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        isExpanded: true,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 14.sp),
          labelText: 'Select Subject',
          labelStyle: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.sp, right: 10.sp),
            child: Icon(Icons.menu_book_rounded, size: 18.sp, color: const Color(0xFF2563EB)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: const Color(0xFFE8EEF8), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sp),
            borderSide: BorderSide(color: const Color(0xFF2563EB), width: 1.4),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 24.sp),
        items: subjects.map((s) {
          return DropdownMenuItem<int>(
            value: s['id'] as int,
            child: Text(
              s['name'].toString(),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
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
        'description': 'Offline Plan',
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



    StorePaymnet('${widget.price}',orderId,paymentId,currency,status,signature,paymentMethod,txnDate,null,'',null,);

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

    StorePaymnet('${widget.price}',orderId,paymentId,currency,status,signature,paymentMethod,txnDate,response.code,response.message,response.error);

    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }



}

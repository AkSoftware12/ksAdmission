import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/AddAddress/sucees.dart';
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
              CircularProgressIndicator(
                color: primaryColor,
              ),
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
              CircularProgressIndicator(
                color: primaryColor,
              ),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Address",
          style: TextStyle(color: Colors.white),
        ),
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Subject Dropdown

                  if(widget.isSubject==1)
                  Container(
                    decoration: BoxDecoration(
                      // color: HexColor('#800000'),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.sp),  // Top left corner radius
                        bottomLeft: Radius.circular(5.sp),  // Bottom left corner radius
                        bottomRight: Radius.circular(5.sp),  // Bottom left corner radius
                        topRight: Radius.circular(5.sp),  // Bottom left corner radius
                      ),
                      border: Border.all(
                        color: greenColorQ, // Border color
                        width: 1.sp, // Border width
                      ),
                    ),

                    child: Padding(
                      padding:  EdgeInsets.only(left: 5.sp,right: 5.sp),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Select Subject',
                          border: InputBorder.none, // Remove the underline
                        ),

                        value:  selectedSubject,
                        items: subjects.map((subject) {
                          return DropdownMenuItem<int>(
                            value: subject['id'] as int, // Ensure 'name' is accessed correctly
                            child: Text(subject['name'].toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubject = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a value' : null,

                      ),

                    ),
                  ),
                  SizedBox(height: 16),
                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your address" : null,
                  ),
                  SizedBox(height: 16),
                  // City Field
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your city" : null,
                  ),
                  SizedBox(height: 16),
                  // State Field
                  TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your state" : null,
                  ),
                  SizedBox(height: 16),
                  // Pin Code Field
                  TextFormField(
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your pin code";
                      } else if (value.length != 6) {
                        return "Pin code must be 6 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Contact Number Field
                  TextFormField(
                    controller: _contactNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your contact number";
                      } else if (value.length != 10) {
                        return "Contact number must be 10 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet:  widget.isSubject==1?
      Container(
        height: 50.sp,
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                // subsid = planlist[i].planId.toString();
                // planId = allPlan[index]['id'].toString();
                // price =  allPlan[index]['price'].toString();
              });


              ordersCreateApi((widget.price) * 100);


              // SubscriptionAPI();


              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         QRCodeOfflineScreen(
              //           categoryId: widget.categoryId,
              //           price: widget.price,
              //           planId: widget.planId,
              //           subjectId: selectedSubject!.toInt(),
              //           address: _addressController.text.toString(),
              //           city:  _cityController.text.toString(),
              //           state: _stateController.text.toString(),
              //           pin: _pinCodeController.text.toString(),
              //           contact: _contactNumberController.text.toString(),
              //         ),
              //   ),
              // );


            }
          },
          child: Padding(
            padding:  EdgeInsets.all(5.sp),
            child: Container(
              height: 40.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                // Adjust the radius to make it more or less rounded
                color: ColorConstants
                    .primaryColor, // Set your desired color
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 35.sp, right: 35.sp),
                  child: Text(
                    ' Pay  ${'₹ '}${widget.price}',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: TextSizes.textmedium,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ):
      Container(
        height: 50.sp,
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              // createPlan();
              //
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         QRCodeOfflineScreen(
              //           categoryId: widget.categoryId,
              //           price: widget.price,
              //           planId: widget.planId,
              //           subjectId: null,
              //           address: _addressController.text.toString(),
              //           city:  _cityController.text.toString(),
              //           state: _stateController.text.toString(),
              //           pin: _pinCodeController.text.toString(),
              //           contact: _contactNumberController.text.toString(),
              //         ),
              //   ),
              // );


            }
          },
          child: Padding(
            padding:  EdgeInsets.all(5.sp),
            child: Container(
              height: 40.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                // Adjust the radius to make it more or less rounded
                color: primaryColor, // Set your desired color
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 35.sp, right: 35.sp),
                  child: Text(
                    ' Pay  ${'₹ '}${widget.price}',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: TextSizes.textmedium,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      )
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // For animations
import 'package:url_launcher/url_launcher.dart';
import '../../HexColorCode/HexColor.dart';
import '../../baseurl/baseurl.dart';
import 'applied.dart';
class CounsellingToolFeature {
  final String title;
  final String description;
  final IconData icon;

  CounsellingToolFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}
class CounselorPaymentPage extends StatefulWidget {
  const CounselorPaymentPage({super.key});

  @override
  State<CounselorPaymentPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<CounselorPaymentPage>with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _marksController = TextEditingController();
  final _budgetController = TextEditingController();
  final _categoryController = TextEditingController();
  final _fatherNameController = TextEditingController();

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

  static List<CounsellingToolFeature> features = [
    CounsellingToolFeature(
      title: "All India Rank Wise College List",
      description: "Check colleges based on your All India Rank.",
      icon: Icons.list_alt,
    ),
    CounsellingToolFeature(
      title: "State Wise College List",
      description: "View colleges available in your state.",
      icon: Icons.location_on,
    ),
    CounsellingToolFeature(
      title: "Top 10 College List (Based on Rank)",
      description: "Get the top 10 colleges based on your rank.",
      icon: Icons.star,
    ),
    CounsellingToolFeature(
      title: "Filter Wise College List",
      description: "Filter colleges by course, fees, location, etc.",
      icon: Icons.filter_list,
    ),
    CounsellingToolFeature(
      title: "Category Wise College List",
      description: "View colleges based on category (Gen, OBC, SC, ST, EWS).",
      icon: Icons.category,
    ),
    CounsellingToolFeature(
      title: "Quota Wise College List",
      description: "View colleges based on quotas like All India, State, etc.",
      icon: Icons.group,
    ),
    CounsellingToolFeature(
      title: "Cutoff Based College List",
      description: "Check colleges based on previous year cutoffs.",
      icon: Icons.score,
    ),
    CounsellingToolFeature(
      title: "Round Wise College Allotment List",
      description: "Access allotment lists for each counselling round.",
      icon: Icons.event,
    ),
    CounsellingToolFeature(
      title: "Course Wise College List",
      description: "Search colleges by courses like MBBS, BDS, BAMS, etc.",
      icon: Icons.book,
    ),
    CounsellingToolFeature(
      title: "Rank Predictor & College Suggestion Tool",
      description: "Predict suitable colleges based on rank and category.",
      icon: Icons.psychology,
    ),
  ];


void _showPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side:  BorderSide(color: HexColor('#5e19a1'), width: 2),
          ),
          title:  Text(
            'Connect With Your Counselor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: HexColor('#5e19a1'),
              fontSize: 20,
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your 10-digit contact number',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your contact number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                        return 'Please enter a valid 10-digit number';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _fatherNameController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.language,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your father\'s full name',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your father\'s name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _marksController,
                    decoration: InputDecoration(
                      labelText: 'Marks',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your 10-digit contact number',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your contact number';
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _budgetController,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        color: HexColor('#5e19a1'),
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your 10-digit contact number',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: HexColor('#5e19a1'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your contact number';
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 00.sp),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 40.sp,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                HexColor('#5e19a1'),
                                Colors.redAccent.shade200
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30.sp),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.sp,
                ),




// Your existing widget code
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 0.sp),
                      child: GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            // Prepare the message with form data
                            String name = _nameController.text;
                            String contact = _contactController.text;
                            String fatherName = _fatherNameController.text;
                            String marks = _marksController.text;
                            String category = _categoryController.text;
                            String budget = _budgetController.text;
                            String message = "Name: $name\nContact: $contact\nState: $fatherName\nMarks: $marks\nCategory: $category\nBudget: $budget";

                            // WhatsApp phone number (replace with the target number, including country code)
                            String phoneNumber = "+916397199758"; // Example: +91 for India, followed by the number

                            // Construct WhatsApp URL
                            String whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

                            // Launch WhatsApp
                            if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                              await launchUrl(Uri.parse(whatsappUrl));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open WhatsApp'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }

                            // Show success snackbar
                            Navigator.of(context).pop();
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text('Submitted: $name!'),
                            //     backgroundColor: Colors.green,
                            //     duration: const Duration(seconds: 3),
                            //     action: SnackBarAction(
                            //       label: 'Undo',
                            //       textColor: Colors.white,
                            //       onPressed: () {
                            //         // Undo logic can be added here
                            //       },
                            //     ),
                            //   ),
                            // );

                            // Clear form fields
                            _nameController.clear();
                            _contactController.clear();
                            _fatherNameController.clear();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 40.sp,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                HexColor('#5e19a1'),
                                Colors.purple.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30.sp),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )



          ],
        ),
      );
    },
  );
}


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
            dataPlan = responseData['counsellor_plan'];
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
        Uri.parse(counsellorToolEntry),
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
        Uri.parse(counsellorToolCheck),
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

    body:

    Stack(
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
                      'Counselor'.toUpperCase(),
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

            isLoading
                ? SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,  // take full height
                child: const Center(
                  child:CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                ),
              ),
            )
                :SliverPadding(
              padding: EdgeInsets.all(8.sp),
              sliver: SliverList(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    var item = features[index];
                    return   FadeInUp(
                      duration:
                      Duration(milliseconds: 300 + (index * 100)),
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.sp),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 0.sp),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(0.sp),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius:
                                    BorderRadius.circular(8.sp),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: HexColor('#7209B7'),
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 16.sp),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 0.sp),
                                      Text(
                                        item.description,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade100,
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
                    );

                  },
                  childCount: features.length,
                ),
              ),
            ),

          ],
        ),
        // Floating Pay/Go Button
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: FadeInUp(
        //     duration: Duration(milliseconds: 1000),
        //     child: Padding(
        //       padding: EdgeInsets.only(bottom: 40.sp),
        //       child: GestureDetector(
        //         onTap: () {
        //           if (isPaid) {
        //             _showPopup();
        //             // Navigator.push(
        //             //   context,
        //             //   MaterialPageRoute(
        //             //     builder: (context) => PredictionOptionsScreen(),
        //             //   ),
        //             // );
        //             print('Go button pressed');
        //           } else {
        //             _showPaymentBottomSheet(dataPlan!['price'].toString());
        //             print('Pay button pressed');
        //           }
        //         },
        //         child: AnimatedBuilder(
        //           animation: _animation,
        //           builder: (context, child) {
        //             return Transform.translate(
        //               offset: Offset(0, _animation.value),
        //               child: Container(
        //                 height: 48.sp,
        //                 width: MediaQuery.of(context).size.width * 0.8,
        //                 decoration: BoxDecoration(
        //                   gradient: LinearGradient(
        //                     colors: [
        //                       HexColor('#5e19a1'),
        //                       Colors.purple.shade200
        //                     ],
        //                     begin: Alignment.topLeft,
        //                     end: Alignment.bottomRight,
        //                   ),
        //                   borderRadius: BorderRadius.circular(30.sp),
        //                   boxShadow: [
        //                     BoxShadow(
        //                       color: Colors.black.withOpacity(0.2),
        //                       blurRadius: 8,
        //                       offset: Offset(0, 4),
        //                     ),
        //                   ],
        //                 ),
        //                 child:Center(
        //                   child: isPaid
        //                       ? Text(
        //                     'Apply',
        //                     style: GoogleFonts.poppins(
        //                       fontSize: 16.sp,
        //                       color: Colors.white,
        //                       fontWeight: FontWeight.w700,
        //                       letterSpacing: 1.2,
        //                     ),
        //                   )
        //                       : AnimatedContainer(
        //                     duration: Duration(milliseconds: 500),
        //                     padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 8.h),
        //                     child: Row(
        //                       mainAxisSize: MainAxisSize.min,
        //                       children: [
        //                         Text(
        //                           'PAY ',
        //                           style: GoogleFonts.poppins(
        //                             fontSize: 16.sp,
        //                             color: Colors.white,
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //
        //                         Stack(
        //                           alignment: Alignment.center,
        //                           children: [
        //                             Text(
        //                               '₹ 30000',
        //                               style: GoogleFonts.poppins(
        //                                 fontSize: 12.sp,
        //                                 color: Colors.white70,
        //                                 fontWeight: FontWeight.w500,
        //                               ),
        //                             ),
        //                             Positioned(
        //                               left: 0,
        //                               right: 0,
        //                               child: Container(
        //                                 height: 3,
        //                                 color: Colors.redAccent,
        //                               ),
        //                             ),
        //
        //                           ],
        //                         ),
        //                         SizedBox(width: 6.w),
        //                         Text(
        //                           '₹ ${dataPlan?['discountedPrice']?.toString() ?? '30000'}',
        //                           style: GoogleFonts.poppins(
        //                             fontSize: 14.sp,
        //                             color: Colors.white,
        //                             fontWeight: FontWeight.w800,
        //                           ),
        //                         ),
        //                         SizedBox(width: 4.w),
        //                         Container(
        //                           padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        //                           decoration: BoxDecoration(
        //                             color: Colors.yellowAccent,
        //                             borderRadius: BorderRadius.circular(6.r),
        //                           ),
        //                           child: Text(
        //                             '50% OFF',
        //                             style: GoogleFonts.poppins(
        //                               fontSize: 10.sp,
        //                               color: Colors.purple,
        //                               fontWeight: FontWeight.w700,
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 )
        //               ),
        //             );
        //           },
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

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
                        builder: (context) => ApplyPage(),
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
                                      '₹ ${dataPlan?['originalPrice']?.toString() ?? '50000'}',
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
                                  '₹ ${dataPlan?['price']?.toString() ?? 'please wait'}',
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
        padding:  EdgeInsets.all(10.sp),
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



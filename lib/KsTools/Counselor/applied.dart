import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/KsTools/INDRODUCATION/Introduction.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../HexColorCode/HexColor.dart';
import 'package:http/http.dart' as http;

import '../../baseurl/baseurl.dart';


class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _FeatureToolsPageState();
}

class _FeatureToolsPageState extends State<ApplyPage>
    with SingleTickerProviderStateMixin {
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var mini = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  var selectedfABLocation = FloatingActionButtonLocation.endDocked;

  final Color primaryColor = const Color(0xFF5E19A1);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactController = TextEditingController();
  final _stateController = TextEditingController();
  final _marksController = TextEditingController();
  final _budgetController = TextEditingController();

  VideoPlayerController? _controller1;

  late AnimationController _controller;
  bool isLoading = false;
  bool isDataLoading = true;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isDataLoading = false;
      });
    });
  }



  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: HexColor('#f2f5ff'),
            height: double.infinity,
            width: double.infinity,

            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/tools_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView( // Wrap the entire Column in a SingleChildScrollView
            child: Column(
              children: [
                // AppBar
                PreferredSize(
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
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      centerTitle: true,
                      actions: [],
                    ),
                  ),
                ),
                // Main content
                isDataLoading
                    ? SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.purple,
                    ),
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: _buildForm(context),
                ),
                // Next Button
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.sp, top: 20.sp),
                    child: GestureDetector(
                      onTap: (){
                        sendDetailsApi(
                          name: _nameController.text,
                          rank: _marksController.text,
                          budget: _budgetController.text,
                          category: _categoryController.text,
                          state: _stateController.text,
                          phone: _contactController.text,
                        );
                      },
                      // onTap: () => _handleSubmit(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 40.sp,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [HexColor('#5e19a1'), Colors.purple.shade200],
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
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }



  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              hint: 'Enter your full name',
              keyboardType: TextInputType.name,
              validator: (value) => _validateText(value, 'Name', 2),
            ),
            SizedBox(height: 0.0.sh),
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              icon: Icons.category_outlined,
              hint: 'Enter category (e.g., General, OBC)',
              keyboardType: TextInputType.text,
              validator: (value) => _validateText(value, 'Category', 2),
            ),
            SizedBox(height: 0.0.sh),
            _buildTextField(
              controller: _contactController,
              label: 'Contact Number',
              icon: Icons.phone,
              hint: 'Enter your 10-digit contact number',
              keyboardType: TextInputType.phone,
              validator: _validateContact,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            SizedBox(height: 0.0.sh),
            _buildTextField(
              controller: _stateController,
              label: 'State',
              icon: Icons.language,
              hint: 'Enter your state',
              keyboardType: TextInputType.text,
              validator: (value) => _validateText(value, 'State', 2),
            ),
            SizedBox(height: 0.0.sh),
            _buildTextField(
              controller: _marksController,
              label: 'Marks',
              icon: Icons.numbers,
              hint: 'Enter your marks (e.g., 85%)',
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, 'Marks'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 0.0.sh),
            _buildTextField(
              controller: _budgetController,
              label: 'Budget',
              icon: Icons.currency_rupee,
              hint: 'Enter your budget (e.g., 500000)',
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, 'Budget'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            SizedBox(height: 0.02.sh),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
                children: const [
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: 'Our counselor will contact you within 24 hours via call or WhatsApp.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )


          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      // Set a fixed height for the TextFormField
      height: 60.h, // Adjust height as needed using ScreenUtil
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(icon, color: primaryColor, size: 24.sp),
          filled: true,
          fillColor: Colors.grey[100],
          // Consistent padding to avoid layout shift
          contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
          // Ensure error text doesn't increase height
          errorStyle: TextStyle(
            color: Colors.redAccent,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 0.1, // Minimize vertical space taken by error text
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          // Reserve space to prevent layout shift
          errorMaxLines: 1,
          helperText: ' ', // Reserve space for error text to avoid jump
        ),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: primaryColor,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40.h,
      width: 0.3.sw,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String? _validateText(String? value, String field, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
    }
    if (value.trim().length < minLength) {
      return '$field must be at least $minLength characters';
    }
    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your contact number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit number';
    }
    return null;
  }

  String? _validateNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Please enter a valid $field';
    }
    return null;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final message = 'Name: ${_nameController.text}\n'
          'Contact: ${_contactController.text}\n'
          'State: ${_stateController.text}\n'
          'Marks: ${_marksController.text}\n'
          'Category: ${_categoryController.text}\n'
          'Budget: ${_budgetController.text}';
      const phoneNumber = '+919103967493';
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

      try {
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar(context, 'Could not open WhatsApp', Colors.red);
        }
      } catch (e) {
        _showSnackBar(context, 'Error launching WhatsApp: $e', Colors.red);
      }

      Navigator.of(context).pop();
      _clearForm();
    }
  }

  Future<void> sendDetailsApi({
    required String name,
    required String rank,
    required String budget,
    required String category,
    required String state,
    required String phone,
  }) async {
    var url = Uri.parse(counsellorUserDetails);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var body = jsonEncode({
      'name': name,
      'rank': rank,
      'budget': budget,
      'category': category,
      'state': state,
      'phone_no': phone,
    });

    try {
      var response = await http.post(url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        _handleSubmit(context);
        print('Success: $responseData');
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _categoryController.clear();
    _contactController.clear();
    _stateController.clear();
    _marksController.clear();
    _budgetController.clear();
  }

  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _contactController.dispose();
    _stateController.dispose();
    _marksController.dispose();
    _budgetController.dispose();
    if (_controller1 != null && _controller1!.value.isPlaying) {
      _controller1!.pause();
    }
    _controller1?.dispose();
    _controller.dispose();
  }
}
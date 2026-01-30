import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realestate/HomePage/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../Utils/app_colors.dart';
import '../Utils/color_constants.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';


class DoubtSession extends StatefulWidget {
  const DoubtSession({super.key});

  @override
  State<DoubtSession> createState() => _DoubtSessionState();
}

class _DoubtSessionState extends State<DoubtSession> {
  // Category and Subject lists
  List<String> categories = ['Math', 'Science', 'History', 'English'];
  // List<String> subjects = ['Algebra', 'Physics', 'World War II', 'Grammar'];
  List<dynamic> category = [];
  List<dynamic> subjects = [];


  // Selected values for dropdown
  int? selectedCategory;
  int? selectedSubject;

  // Message text controller
  final TextEditingController messageController = TextEditingController();

  // Image file
  XFile? _image;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  // Function to capture an image using the camera
  Future<void> _captureImageFromCamera() async {
    final capturedImage = await _picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        _image = capturedImage;
      });
    }
  }
  Future<void> hitAllCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse(categorys),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('banners') && responseData.containsKey('data')) {
        setState(() {
          category = responseData['data'];
          // banner = responseData['banners'];
          // subcategory = responseData['subcategories'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
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
      // userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('data')) {
        setState(() {
          subjects = responseData['data'];
          // isDownloadingList = List<bool>.filled(subjects.length, false);
          // downloadProgressList = List<double>.filled(subjects.length, 0.0);
        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
  Future<void> _updateProfile(XFile? file) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget()

            ],
          ),
        );
      },
    );

    // setState(() {
    //   _isLoading = true;
    // });

    // Get user input data

    String message = messageController.text;

    // Get the selected image file

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // Your API endpoint for updating profile
    String apiUrl = doubtSession;

    try {
      // Create multipart request for image upload
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      // Add other fields to the request
      request.fields.addAll({
        'category_id': selectedCategory.toString(),
        'subject_id': selectedSubject.toString(),
        'message': message,
      });

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);





      // // Send the request
      // var response = await request.send();

      if (response.statusCode == 200) {

        final Map<String, dynamic> jsonData = json.decode(response.body);


        Navigator.pop(context);


        Fluttertoast.showToast(
          msg: " Create Doubt Successfully ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 22.0,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Homepage(
                  initialIndex: 0,
                ),
          ),
        );




        // You can navigate to another screen or show a success message
      } else {
        // Error occurred while updating profile
        print('Failed to update profile. Error: ${response.statusCode}');
        // Handle error accordingly, show error message, etc.
      }
    } catch (e) {
      print('Exception occurred: $e');
      // Handle exception, show error message, etc.
    }
  }


  @override
  void initState() {
    super.initState();
    hitAllCategory();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 110.h),
        child: Column(
          children: [
            // top info card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0A1AFF).withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 44.sp,
                    width: 44.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.sp),
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(Icons.help_outline, color: Colors.blue, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Tip",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Choose course, subject, write message & attach image (optional).",
                          style: GoogleFonts.poppins(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Course dropdown card
            _premiumCard(
              child: _premiumDropdown<int>(
                label: "Select Course",
                icon: Icons.school_outlined,
                value: selectedCategory,
                items: category
                    .where((c) => c['planstatus'] == 'unlocked')
                    .map((c) => DropdownMenuItem<int>(
                  value: c['id'] as int,
                  child: Text(
                    c['name'].toString(),
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedCategory = value;
                    selectedSubject = null;
                    subjects = [];
                  });
                  hitSubjectApi(value);
                },
              ),
            ),

            SizedBox(height: 12.h),

            // Subject dropdown card
            _premiumCard(
              child: _premiumDropdown<int>(
                label: "Select Subject",
                icon: Icons.menu_book_outlined,
                value: selectedSubject,
                items: subjects
                    .map((s) => DropdownMenuItem<int>(
                  value: s['id'] as int,
                  child: Text(
                    s['name'].toString(),
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSubject = value);
                },
              ),
            ),

            SizedBox(height: 12.h),

            // message box
            _premiumCard(
              child: TextFormField(
                controller: messageController,
                maxLines: 5,
                style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF111827)),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Icon(Icons.edit_note_rounded, color:  Colors.blue),
                  ),
                  labelText: "Enter your message",
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  hintText: "Explain your doubt clearly…",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.sp),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.sp),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.sp),
                    borderSide: BorderSide(color:  Colors.blue, width: 1.2),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // image preview
            if (_image != null) ...[
              _premiumCard(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.sp),
                      child: Image.file(
                        File(_image!.path),
                        height: 180.sp,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => setState(() => _image = null),
                        child: Container(
                          padding: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Upload buttons
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.photo_library_outlined,
                    text: "Upload",
                    onTap: _pickImageFromGallery,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _actionButton(
                    icon: Icons.camera_alt_outlined,
                    text: "Camera",
                    onTap: _captureImageFromCamera,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // bottom submit bar
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.sp),
            topRight: Radius.circular(18.sp),
          ),
        ),
        child: SafeArea(
          top: false,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.sp),
            onTap: () {
              if (messageController.text.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: "✍️ Please enter your message",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16,
                );
                return;
              }
              _updateProfile(_image);
              messageController.clear();
            },
            child: Container(
              height: 52.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.sp),
                gradient: LinearGradient(
                  colors: [

                    Color(0xFF010071),
                    Color(0xFF0A1AFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 10.w),
                  Text(
                    "Submit Doubt",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

// ---------- UI helpers (same file me niche add kar do) ----------

  Widget _premiumCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0A1AFF).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _premiumDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color:  Colors.blue),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(color: Colors.blue, width: 1.2),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.sp),
      onTap: onTap,
      child: Container(
        height: 52.sp,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.sp),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color:  Colors.blue, size: 18.sp),
            SizedBox(width: 10.w),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

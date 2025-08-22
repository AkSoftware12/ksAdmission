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
      body: Container(
        color: Colors.white,
        child: Stack(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
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

                    height: 60.sp,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.sp, right: 5.sp),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Select Course',
                          border: InputBorder.none,  // Remove the underline
                        ),
                        value: selectedCategory,
                        items: category.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'] as int,  // Assuming each category has an 'id' field as int
                            child:  category['planstatus']=='unlocked' ?Text(category['name'].toString()):SizedBox()

                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            selectedSubject = null; // Clear the selected subject
                            hitSubjectApi(value);
                          });
                        },
                      ),
                    )

                  ),

                  const SizedBox(height: 16),

                  // Subject dropdown
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
                      ),

                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message input field
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Buttons for gallery and camera
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     ElevatedButton.icon(
                  //       onPressed: _pickImageFromGallery,
                  //       icon: const Icon(Icons.photo),
                  //       label: const Text('Gallery'),
                  //     ),
                  //     ElevatedButton.icon(
                  //       onPressed: _captureImageFromCamera,
                  //       icon: const Icon(Icons.camera),
                  //       label: const Text('Camera'),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 16),

                  // Display selected/captured image
                  if (_image != null)
                    Container(
                      width: double.infinity,
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

                      height: 180.sp,
                      child: Image.file(
                        File(_image!.path),
                        height: 180.sp,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo,color: Colors.white,),
                        label: const Text('Upload',
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColorQ, // Change this to your preferred color
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _captureImageFromCamera,
                        icon: const Icon(Icons.camera,color: Colors.white,),
                        label: const Text('Camera',
                          style: TextStyle(
                              color: Colors.white
                          ),

                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColorQ, // Change this to your preferred color
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        height: 80.sp,
        color: Colors.white,
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),

                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                    onTap: (){
                      _updateProfile(_image);
                      messageController.clear();

                    },
                    child: Row(
                      children: [
                        Container(
                          height: 40.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp), // Adjust the radius to make it more or less rounded
                            color: ColorConstants.primaryColor, // Set your desired color
                          ),

                          child: Center(
                            child: Padding(
                              padding:  EdgeInsets.only(left: 35.sp,right: 35.sp),
                              child: Text('Submit',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: TextSizes.textmedium,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),

              ],
            ),
          ],
        ),

      ),

    );
  }
}

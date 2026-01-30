import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../CommonCalling/progressbarPrimari.dart';
import '../../HomePage/home_page.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';

class OMRUploader extends StatefulWidget {
  @override
  _OMRUploaderState createState() => _OMRUploaderState();
}

class _OMRUploaderState extends State<OMRUploader> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Future<void> _uploadImage() async {
    // if (_image == null) return;

    if (_image == null) {
      Fluttertoast.showToast(
        msg: "Please Capture OMR Sheet ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(
              ),

            ],
          ),
        );
      },
    );

    // setState(() {
    //   _isUploading = true;
    // });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token',);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(uploadOmr),
    );

    // Adding the authorization token to the headers
    request.headers['Authorization'] = 'Bearer $token';

    // Adding the image file to the request
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    // Handling the response

    // setState(() {
    //   _isUploading = false;
    // });

    if (response.statusCode == 200) {
      print('Image uploaded successfully');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage(initialIndex: 0,)),
      );
    } else {
      print('Image upload failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent the screen from going back
        return false;
      },
      child: Scaffold(
        backgroundColor:  Colors.black87,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: (){
                  _pickImage();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upload Your OMR SHEET',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 150,
                              color: primaryColor,
                            ),
                            // Positioned(
                            //   bottom: 50,
                            //   child: Icon(
                            //     Icons.arrow_upward,
                            //     size: 40,
                            //     color: Colors.white,
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Click Above icon to Capture Your OMR SHEET ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _image == null
                  ? GestureDetector(
                onTap: (){
                  _pickImage();
                },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black87,

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(child: Text('image '))),
                    ),
                  )
                  : GestureDetector(
                onTap: (){
                  _pickImage();
                },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                      height: 350.sp,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color:  Colors.black87,

                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: Image.file(_image!,fit: BoxFit.fill,))),
                    ),
                  ),
              SizedBox(height: 0),
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: Text('Capture OMR Sheet'),
              // ),
              // ElevatedButton(
              //   onPressed: _uploadImage,
              //   child: Text('UPLOAD OMR SHEET'),
              // ),
            ],
          ),
        ),


        bottomSheet:  Container(
          height: 60.sp,
          color: Colors.black,
          width: double.infinity,
          child:  Container(
            height: 40.sp,
            width: double.infinity,
            child: Padding(
              padding:  EdgeInsets.all(12.sp),
              child: GestureDetector(
                onTap: () {
                  _uploadImage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sp),
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: Padding(
                            padding:  EdgeInsets.only(left: 25.sp,right:25.sp),
                            child: Text(
                              'UPLOAD OMR SHEET',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: TextSizes.textsmall2,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
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
            ),
          ),

        ),
      ),
    );
  }
}

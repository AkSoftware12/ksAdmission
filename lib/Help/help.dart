import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../CommonCalling/progressbarPrimari.dart';
import '../HomePage/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/color_constants.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class HelpScreen extends StatefulWidget {
  final String appBar;

  const HelpScreen({super.key, required this.appBar});

  @override
  State<HelpScreen> createState() => _DoubtSessionState();
}

class _DoubtSessionState extends State<HelpScreen> {
  // Message text controller
  final TextEditingController messageController = TextEditingController();

  Future<void> _updateProfile() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(),
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
    String apiUrl = helpContact;

    try {
      // Create multipart request for image upload
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      // Add other fields to the request
      request.fields.addAll({'message': message});

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      // if (file != null) {
      //   request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      // }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // // Send the request
      // var response = await request.send();

      if (response.statusCode == 200) {
        messageController.clear();

        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: " Message Send Successfully  ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 22.0,
        );

        // You can navigate to another screen or show a success message
      } else {
        // Error occurred while updating profile
        if (kDebugMode) {
          print('Failed to update profile. Error: ${response.statusCode}');
        }
        // Handle error accordingly, show error message, etc.
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
      // Handle exception, show error message, etc.
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar.isEmpty
          ? null
          :   AppBar(
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
            onTap: (){
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Help',
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
                  "Get instant support & solutions",
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
          )


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
                  const SizedBox(height: 16),

                  // Message input field
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        height: 80.sp,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),

                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                    onTap: () {
                      _updateProfile();
                    },
                    child: Row(
                      children: [
                        Container(
                          // width: double.infinity,
                          height: 40.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            // Adjust the radius to make it more or less rounded
                            color: Color(0xFF0A1AFF), // Set your desired color
                          ),

                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 35.sp,
                                right: 35.sp,
                              ),
                              child: Text(
                                'Send',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: TextSizes.textmedium,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
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
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

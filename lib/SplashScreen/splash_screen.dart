import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../DashBoardTeacher/home_bootom_teacher.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../LoginPage/login_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../baseurl/baseurl.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isLoggedIn = false;
  String _imageUrl=''; // Stores the image URL


  @override
  void initState() {
    super.initState();
    postRequestWithToken();

    Future.delayed(Duration(seconds: 3), () {
      checkLoginStatus();
    });

  }

  Future<void> postRequestWithToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token',);
    try {
      // Define headers
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(logActivity),
        headers: headers,
      );

      // Check the status code and handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _imageUrl = responseData["data"]["picture_urls"];

        });
        // Handle success response
        print('Success: ${response.body}');
      } else {

        // Handle error response
        print('Failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
    }
  }
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if user credentials exist
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool loggedInTeacher = prefs.getBool('isLoggedInTeacher') ?? false;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage(initialIndex: 0,)),
      );

      if(_imageUrl !='')
        _showWelcomeDialog();

    } else if(loggedInTeacher){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeBottomTeacher(),
        ),
      );
    }

    else {
      // If user is not logged in, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return  Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _imageUrl, // Replace with your image path
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red,size: 30,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:homepageColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            ClipRRect(
              borderRadius: BorderRadius.circular(20.sp),

              child: Image.asset(
                logo,
                width: 130.sp,
                height: 130.sp,
              ),
            ),
            SizedBox(height: 10.sp), // Spacing between logo and app name
            // App name
            Text(
              AppConstants.appName2, // Replace with your app name
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),

            SizedBox(height: 20.sp), // Spacing before loader
            CupertinoActivityIndicator(
              radius: 25,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomUpgradeDialog extends StatelessWidget {
  final String androidAppUrl = 'https://play.google.com/store/apps/details?id=com.ksadmission&pcampaignid=web_share';
  final String iosAppUrl = 'https://apps.apple.com/app/idYOUR_IOS_APP_ID'; // Replace with your iOS app URL
  final String currentVersion; // Old version
  final String newVersion; // New version
  final List<String> releaseNotes; // Release notes

  const CustomUpgradeDialog({
    Key? key,
    required this.currentVersion,
    required this.newVersion,
    required this.releaseNotes,
  }) : super(key: key);

  Future<void> _launchStore() async {
    final Uri androidUri = Uri.parse(androidAppUrl);
    final Uri iosUri = Uri.parse(iosAppUrl);

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(iosUri)) {
          await launchUrl(
            iosUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch iOS App Store';
        }
      } else if (Platform.isAndroid) {
        if (await canLaunchUrl(androidUri)) {
          await launchUrl(
            androidUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch Play Store';
        }
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.sp)),
      elevation: 12,

      child: Container(
        constraints: BoxConstraints(maxWidth: 420),
        padding: EdgeInsets.all(25.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [homepageColor,homepageColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.sp),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      HexColor('#FFFFFF'),
                      homepageColor.withOpacity(0.9),
                    ],
                    radius: 0.55,
                    center: Alignment.center,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white60,
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10.sp),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 52.sp,
                  color:homepageColor,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                "🚀 New Update Available!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.sp),
              Center(
                child: Text(
                  "A new version of Upgrader is available! Version $newVersion is now available - you have $currentVersion",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.sp),

              Center(
                child: Text(
                  " Would you like to update it now?",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 5.sp),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New in Version $newVersion",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    ...releaseNotes.asMap().entries.map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 15.sp),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:homepageColor,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 28.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sp),
                    side: BorderSide(color: Colors.white, width: 1.sp),
                  ),
                ),
                icon: Icon(Icons.rocket_launch, size: 20.sp,color: Colors.white,),
                label: Text(
                  "Update Now".toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),
                ),
                onPressed: () async {
                  await _launchStore();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realestate/DashBoardTeacher/teacher_panal_profile.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/string.dart';
import '../../Utils/textSize.dart';
import '../CommonCalling/Common.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../Download/download.dart';
import '../FAQ/faq.dart';
import '../Help/help.dart';
import '../LoginPage/login_page.dart';
import '../OrderPage/orders.dart';
import '../Profile/DoubtSessionTab/doubt_session_tab.dart';
import '../ResetPassword/reset_password.dart';
import '../SplashScreen/splash_screen.dart';
import '../Utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../Utils/image.dart';
import '../WebView/webview.dart';
import '../baseurl/baseurl.dart';
import '../doubtStatusPage/doubt.dart';
import 'AppointmentTeacher/teacher_appointment.dart';
import 'LIveClassTeacher/teacher_live_class.dart';
import 'StudentList/student_list.dart';

class HomeBottomTeacher extends StatefulWidget {
  const HomeBottomTeacher({super.key});

  @override
  State<HomeBottomTeacher> createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<HomeBottomTeacher> {
  int _selectedIndex = 0;

  CommonMethod common = CommonMethod();
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String cityState = '';
  String pin = '';
  GlobalKey bottomNavigationKey = GlobalKey();
  bool _isLoading = false;
  String currentVersion = '';
  String release = "";
  bool _upgradeDialogShown = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    checkForVersion(context);

    final newVersion = NewVersionPlus(
      iOSId: 'com.ksadmission',
      androidId: 'com.ksadmission',
      androidPlayStoreCountry: "es_ES",
      androidHtmlReleaseNotes: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      advancedStatusCheck(newVersion); // ✅ now context is ready
    });
  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  Future<void> advancedStatusCheck(NewVersionPlus newVersion) async {
    try {
      final status = await newVersion.getVersionStatus();
      if (status == null) return;

      debugPrint("releaseNotes: ${status.releaseNotes}");
      debugPrint("appStoreLink: ${status.appStoreLink}");
      debugPrint("localVersion: ${status.localVersion}");
      debugPrint("storeVersion: ${status.storeVersion}");
      debugPrint("canUpdate: ${status.canUpdate}");

      if (!status.canUpdate) return;
      if (_upgradeDialogShown) return;
      if (!mounted) return;

      _upgradeDialogShown = true;

      showDialog(
        context: context, // ✅ yahi best hai
        barrierDismissible: false,
        builder: (dialogCtx) {
          return PopScope( // ✅ WillPopScope new replacement (Flutter 3.13+)
            canPop: false,
            onPopInvoked: (didPop) {
              SystemNavigator.pop();
            },
            child: CustomUpgradeDialog(
              currentVersion: status.localVersion,
              newVersion: status.storeVersion,
              releaseNotes: [
                (status.releaseNotes ?? "").trim().isEmpty
                    ? "New update available."
                    : status.releaseNotes!.trim(),
              ],
            ),
          );
        },
      );
    } catch (e, st) {
      debugPrint("advancedStatusCheck error: $e");
      debugPrint("$st");
    }
  }
  Future<void> checkForVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }

  Future<void> shareContent() async {
    // Replace with your image file path
    final ByteData bytes = await rootBundle.load(logo);
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/logo2.png');

    // Write the bytes to the file
    await file.writeAsBytes(bytes.buffer.asUint8List());

    // Construct the message
    final String message =
        'Ks Admission\nhttps://play.google.com/store/apps/details?id=com.ksadmission';

    // Share the message and image
    // await Share.shareFiles([file.path], text: message, subject: 'Ks Admission');
  }

  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
          false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        nickname = jsonData['user']['name'];
        userEmail = jsonData['user']['email'];
        contact = jsonData['user']['contact'].toString();
        bio = jsonData['user']['bio'].toString();
        photoUrl = jsonData['user']['picture_data'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> logoutApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(),

            ],
          ),
        );
      },
    );

    try {
      // Replace 'your_token_here' with your actual token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(teacherlogout);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await http.post(uri, headers: headers);
      Navigator.pop(context);

      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('isLoggedIn');
      prefs.remove('isLoggedInTeacher');
      prefs.clear(); // Close the progress dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          },
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during logout: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: primaryColor,
          drawerEnableOpenDragGesture: false,

          appBar: AppBar(
            leading: Builder(
              builder: (context) => Padding(
                padding: EdgeInsets.all(5.sp),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: SizedBox(
                    height: 15.sp,
                    width: 15.sp,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset(
                        'assets/drawer_icon.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ), // Ensure Scaffold is in context
            ),

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: '',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    children: <TextSpan>[
                      TextSpan(
                        // text: '${nickname}',
                        text: '${AppConstants.appName}',
                        // text: '${'Ravi'}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 30.sp),

                CircleAvatar(
                  radius: 20.0, // Set size of the circle
                  backgroundImage: AssetImage(
                    logo, // Replace with your image URL or use AssetImage for local assets
                  ),
                ),
              ],
            ),

            centerTitle: true,
            backgroundColor: Color(0xFF010071),
          ),

          body: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(color: homepageColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Expanded(child: _getPage(_selectedIndex))],
                ),
              ),
            ),
          ),

          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(20.sp),
              // topRight: Radius.circular(20.sp),
            ),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Doubt List',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Appointment',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv_outlined),
                  label: 'Live Class',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              backgroundColor: Color(0xFF010071),
              type: BottomNavigationBarType.fixed,
              // Ensures all items are shown
              selectedLabelStyle: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              unselectedLabelStyle: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              showUnselectedLabels: true,
              // Show unselected labels
              onTap: _onItemTapped,
            ),
          ),

          drawer: Drawer(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            width: MediaQuery.sizeOf(context).width * .65,
            // backgroundColor: Theme.of(context).colorScheme.background,
            backgroundColor:  Color(0xFF010071),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 58.sp, bottom: 10.sp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.sp),
                      child: SizedBox(
                        height: 80.sp,
                        width: 80.sp,
                        child: Image.network(
                          photoUrl.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Return a default image widget here
                            return Container(
                              color: Colors.grey,
                              // Placeholder color
                              // You can customize the default image as needed
                              child: Icon(Icons.image, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.sp, bottom: 20.sp),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Text(
                            nickname,
                            style: GoogleFonts.radioCanada(
                              // Replace with your desired Google Font
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: TextSizes.textmedium,
                                // Adjust font size as needed
                                fontWeight: FontWeight
                                    .bold, // Adjust font weight as needed
                                // Adjust font color as needed
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                    child: Divider(
                      color: Colors.grey.shade300,
                      // Set the color of the divider
                      thickness: 2.0,
                      // Set the thickness of the divider
                      height: 1, // Set the height of the divider
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ListTile(
                              //   title: Text(
                              //     'Download',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     color: primaryColor,
                              //     child: Icon(
                              //       Icons.download,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return DownloadPdf();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              //
                              // ListTile(
                              //   title: Text(
                              //     'Doubt Status',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     child: Image.asset(
                              //       doubt,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return DoubtStatusPage();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              //
                              // ListTile(
                              //   title: Text(
                              //     'Doubt Session',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     child: Image.asset(
                              //       doubt,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return DoubtSessionTabClass();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              //
                              // ListTile(
                              //   title: Text(
                              //     'Orders',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     child: Image.asset(
                              //       checklist,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return OrdersPage();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              //
                              // ListTile(
                              //   title: Text(
                              //     'Update Password',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     child: Image.asset(
                              //       changePass,
                              //       color: Colors.white,
                              //     ),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return ResetPasswordPage();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),

                              ListTile(
                                title: Text(
                                  'Share App',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(Icons.share, color: Colors.white),
                                ),
                                onTap: () {
                                  shareContent();

                                  Navigator.pop(context);
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              // ListTile(
                              //   title: Text(
                              //     'Help',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 15.sp,
                              //         fontWeight: FontWeight.normal,
                              //       ),
                              //     ),
                              //   ),
                              //
                              //   trailing: Container(
                              //     height: 20.sp,
                              //     width: 20.sp,
                              //     child: Image.asset(help, color: Colors.white),
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return HelpScreen(appBar: '');
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     left: 8.sp,
                              //     right: 8.sp,
                              //   ),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade300,
                              //     thickness: 1.sp,
                              //   ),
                              // ),

                              ListTile(
                                title: Text(
                                  'FAQs',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset(faqs),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return FaqScreen(appBar: 'appp');
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Privacy',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(
                                    Icons.privacy_tip,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return WebViewExample(
                                          title: 'Privacy',
                                          url:
                                              'https://ksadmission.in/privacy-policy',
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Terms & Condition',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(
                                    Icons.event_note_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return WebViewExample(
                                          title: 'Terms & Condition',
                                          url:
                                              'https://ksadmission.in/privacy-policy',
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Join facebook Page',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset('assets/facebook.png'),
                                ),
                                onTap: () async {
                                  const url =
                                      'https://www.facebook.com/profile.php?id=61560588287955'; // Replace with your Facebook page URL

                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Join Instagram  Page',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset('assets/instagram.png'),
                                ),
                                onTap: () async {
                                  const url =
                                      'https://www.instagram.com/ks_admission/'; // Replace with your Facebook page URL

                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Join Twitter  Page',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset('assets/twitter.png'),
                                ),
                                onTap: () async {
                                  const url =
                                      'https://x.com/KS_Admission'; // Replace with your Facebook page URL

                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Youtube Channel',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset('assets/youtube.png'),
                                ),
                                onTap: () async {
                                  const url =
                                      'https://www.youtube.com/@KSAdmission'; // Replace with your Facebook page URL

                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Official Website',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Image.asset('assets/site.png'),
                                ),
                                onTap: () async {
                                  const url =
                                      'https://ksadmission.in/'; // Replace with your Facebook page URL

                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sp,
                                  right: 8.sp,
                                ),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade300,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Logout',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),

                                trailing: Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                ),

                                onTap: () {
                                  logoutApi(context);
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(padding: EdgeInsets.only(bottom: 15.sp)),
                      ],
                    ),
                  ),

                  // Add more list items as needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return StudentListScreen();
      // case 1:
      //   return ProfileScreen();
      case 1:
        return TeacherScheduleScreen(data: {});
      case 2:
        return TeacherLiveClassScreen();
      case 3:
        return ProfileTeacherScreen();
      default:
        return Container(
          child: Center(
            child: Text(
              'Home',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
        );
    }
  }
}

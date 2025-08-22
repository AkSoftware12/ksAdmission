import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/string.dart';
import '../../Utils/textSize.dart';
import '../CommonCalling/Common.dart';
import '../Download/download.dart';
import '../FAQ/faq.dart';
import '../FAQ/faq_tab.dart';
import '../Help/help.dart';
import '../HomeScreen/home_screen.dart';
import '../Library/library.dart';
import '../LoginPage/login_page.dart';
import '../OrderPage/orders.dart';
import '../Plan/plan.dart';
import '../Profile/DoubtSessionTab/doubt_session_tab.dart';
import '../Profile/profile_screen.dart';
import '../ResetPassword/reset_password.dart';
import '../Utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../Utils/image.dart';
import '../WebView/webview.dart';
import '../baseurl/baseurl.dart';
import '../doubtStatusPage/doubt.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;

  const Homepage({super.key, required this.initialIndex});

  @override
  State<Homepage> createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<Homepage> {
  int _selectedIndex = 0;
  List<dynamic> popUp = [];

  CommonMethod common = CommonMethod();
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String cityState = '';
  String pin = '';
  String popUpImage = '';
  GlobalKey bottomNavigationKey = GlobalKey();
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    hitAllCategory();
    fetchProfileData();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 5), () {
        if (popUp != null && popUp.isNotEmpty) {
          checkAndShowDialog(context);
        }
      });
    });
  }

  void showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.sp),
            child: Stack(
              children: [
                Image.network(
                  popUp[0]['image_urls'].toString(),
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkAndShowDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the last shown date from SharedPreferences
    String? lastShownDate = prefs.getString('last_popup_date');

    // Get today's date as a string (e.g., "2023-10-25")
    DateTime now = DateTime.now();
    String todayDate = now.toIso8601String().split('T')[0];

    // Check if popup was already shown today
    if (lastShownDate == todayDate) {
      return; // Exit if popup was shown today
    }

    // Show the popup
    showImageDialog(context);

    // Save today's date as the last shown date
    await prefs.setString('last_popup_date', todayDate);
  }

  Future<void> hitAllCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(categorys),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('popups')) {
        setState(() {
          popUp = responseData['popups'];
          // popUpImage=responseData['popups'][0]['image_urls'].toString();

          print('image: $popUpImage');
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> shareContent() async {
    // Replace with your image file path
    final ByteData bytes = await rootBundle.load(logo);
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/logo.png');

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
              CircularProgressIndicator(color: primaryColor),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    try {
      // Replace 'your_token_here' with your actual token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(logout);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await http.post(uri, headers: headers);

      Navigator.pop(context); // Close the progress dialog

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('isLoggedIn');
        prefs.clear();

        // If the server returns a 200 OK response, parse the data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load data');
      }
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
      builder: (context, onInit, onDispose) => UpgradeAlert(
        showIgnore: true,
        showLater: true,
        showReleaseNotes: false,
        shouldPopScope: () => false,
        cupertinoButtonTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
        barrierDismissible: true,
        dialogStyle: UpgradeDialogStyle.cupertino,
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: homepageColor,
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
                ],
              ),
              actions: [
                Builder(
                  builder: (context) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.live_tv,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ), // Ensure Scaffold is in context
                ),

                Builder(
                  builder: (context) => Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return FaqTabScreen();
                            },
                          ),
                        );
                      },
                      child: Icon(Icons.help, color: Colors.white, size: 22.sp),
                    ),
                  ), // Ensure Scaffold is in context
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Builder(
                    builder: (context) => Padding(
                      padding: EdgeInsets.all(0.sp),
                      child: GestureDetector(
                        onTap: () {},
                        child: Stack(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NotificationList();
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ), // Ensure Scaffold is in context
                  ),
                ),
              ],
              centerTitle: true,
              backgroundColor: homepageColor,
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
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_sharp),
                    label: 'Library',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.subscriptions),
                    label: 'Subscriptions',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
                backgroundColor: homepageColor,
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
              backgroundColor: primaryColor,
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
                                ListTile(
                                  title: Text(
                                    'Download',
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
                                    color: primaryColor,
                                    child: Icon(
                                      Icons.download,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return DownloadPdf();
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
                                    'Doubt Status',
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
                                    child: Image.asset(
                                      doubt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return DoubtStatusPage();
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
                                    'Doubt Session',
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
                                    child: Image.asset(
                                      doubt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return DoubtSessionTabClass();
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
                                    'Orders',
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
                                    child: Image.asset(
                                      checklist,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OrdersPage();
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
                                    'Update Password',
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
                                    child: Image.asset(
                                      changePass,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ResetPasswordPage();
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
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
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
                                ListTile(
                                  title: Text(
                                    'Help',
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
                                    child: Image.asset(
                                      help,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return HelpScreen(appBar: 'Help');
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
                                          return FaqScreen(appBar: 'FAQ');
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
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return HomeScreen();
      case 1:
        return LibraryScreen();
      case 2:
        return ProfileScreen();
      case 3:
        return PlanScreen(appBar: '');
      default:
        return Container();
    }
  }
}

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#eeeeee'),
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
      ),
      body: Center(child: Image.asset('assets/notification.png')),
    );
  }
}

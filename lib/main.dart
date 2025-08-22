
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upgrader/upgrader.dart';
import 'DarkMode/dark_mode.dart';
import 'DashBoardTeacher/home_bootom_teacher.dart';
import 'HomePage/home_page.dart';
import 'LoginPage/login_page.dart';
import 'Notification/notification.dart';
import 'Utils/app_colors.dart';
import 'Utils/image.dart';
import 'Utils/string.dart';
import 'Utils/textSize.dart';
import 'baseurl/baseurl.dart';





class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background Notification: ${message.notification?.title}");
  if (message.notification?.title == 'Video Call') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => CallScreen()),
    );  }

}
Future main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  // setUpLocator();
  // Gemini.init(
  //   apiKey: 'AIzaSyAeiY-nqd8-gmnBHoyK3RVthCahU2rFvmw',
  // );

  Platform.isAndroid ? await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? const FirebaseOptions(
      apiKey: 'AIzaSyAX1mM7hNa8FlFFhac3oyaVk41z9FZlgtY',
      appId: '1:810800089497:android:4bbd3ee7b9cde99891ab08',
      messagingSenderId: '810800089497',
      projectId: 'ka-admission',
      storageBucket: "ka-admission.firebasestorage.app",
    )
        : null,
  ) : await Firebase.initializeApp();

  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await FirebaseAppCheck.instance.activate();
  NotificationService.initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child:  MyApp(),
    ),
  );

  // FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final RouteObserver<PageRoute> _routeObserver = RouteObserver();

   MyApp({super.key,});
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: primaryColor, // Set the color you want
    //     systemNavigationBarColor: Colors.blue, // Navigation bar color
    //     systemStatusBarContrastEnforced: false, // For contrast
    //   ),
    // );
    return   Portal(
      child: Provider.value(
        value: _routeObserver,
        child:ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          // Use builder only if you need to use library outside ScreenUtilInit context
          builder: (_ , child) {
            return MaterialApp(
              navigatorKey: navigatorKey, // Add this line
              debugShowCheckedModeBanner: false,
              home:  child,
            );
          },
          child:  AuthenticationWrapper(),
        ),

      ),
    );

  }
}






class AuthenticationWrapper extends StatefulWidget {


  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
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

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );

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
      backgroundColor:homepageColor, // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.only(top: 00.sp, bottom: 0.sp),
                child: Container(
                  height: 150.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,

                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(logo),
                ),
              ),
            ),

            SizedBox(height: 20.0),
            Text(AppConstants.appName2,
              style: GoogleFonts.radioCanada(
                // Replace with your desired Google Font
                textStyle: TextStyle(
                  color:  Colors.white,
                  fontSize: TextSizes.textlarge,
                  // Adjust font size as needed
                  fontWeight: FontWeight
                      .bold, // Adjust font weight as needed
                  // Adjust font color as needed
                ),
              ),),
          ],
        ),
      ),
    );
  }

}





class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// **🔹 Initialize Notifications**
  static Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Push Notifications Enabled");

      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      _initLocalNotifications();
    } else {
      print("❌ Push Notifications Denied");
    }
  }

  /// **🔹 Handle Foreground Notifications**
  static void _onMessage(RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");

    if (message.notification?.title == 'Video Call') {
      Future.delayed(Duration(seconds: 2), () {
        _openCallScreen();
      });
    } else {
      _showLocalNotification(message);
    }
  }

  /// **🔹 Handle Notification Click (When App is Opened by Clicking Notification)**
  static void _onMessageOpenedApp(RemoteMessage message) {
    print("📩 Notification Clicked: ${message.notification?.title}");

    if (message.notification?.title == 'Video Call') {
      _openCallScreen();
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => NotificationScreen()),
      );
    }
  }

  /// **🔹 Open Call Screen**
  static void _openCallScreen() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => CallScreen()),
    );
  }

  /// **🔹 Handle Background Notifications**
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print("📩 Background Notification: ${message.notification?.title}");

    if (message.notification?.title == 'Video Call') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => CallScreen()),
      );
    }
  }

  /// **🔹 Initialize Local Notifications**
  static void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == 'Video Call') {
          _openCallScreen();
        }
      },
    );
  }

  /// **🔹 Show Local Notification**
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const NotificationDetails generalNotificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      generalNotificationDetails,
      payload: message.notification?.title == 'Video Call' ? 'Video Call' : '',
    );
  }
}










class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  late Timer _autoDismissTimer;
  bool _isRingtonePlaying = false; // Track if ringtone is playing

  @override
  void initState() {
    super.initState();
    _playRingtone();

    // Auto close screen after 20 seconds if no action is taken
    _autoDismissTimer = Timer(Duration(seconds: 20), () async {
      if (mounted) {
        await _stopRingtone();
        Navigator.pop(context); // Close screen automatically
      }
    });
  }

  Future<void> _playRingtone() async {
    if (!_isRingtonePlaying) {  // Ensure ringtone is not already playing
      try {
        await _audioPlayer.setSource(AssetSource("phone_rington.mp3"));
        await _audioPlayer.play(AssetSource("phone_rington.mp3"));
        _isRingtonePlaying = true; // Mark as playing
      } catch (e) {
        print("Error playing ringtone: $e");
      }
    }
  }

  Future<void> _stopRingtone() async {
    if (_isRingtonePlaying) {
      await _audioPlayer.stop();
      _isRingtonePlaying = false; // Reset flag
    }
  }

  @override
  void dispose() {
    _autoDismissTimer.cancel();
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage("assets/user.png"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "John Doe",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Incoming Call...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      await _stopRingtone();
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => VideoCallScreen(id: '',),
                      //   ),
                      // );
                    },
                    child: Icon(Icons.call, size: 30, color: Colors.white),
                    backgroundColor: Colors.green,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      await _stopRingtone();
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.call_end, size: 30, color: Colors.white),
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



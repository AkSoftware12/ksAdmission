import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:realestate/Utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonCalling/Common.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../ContainerShape/container.dart';
import '../DashBoardTeacher/home_bootom_teacher.dart';
import '../ForgotPassword/forgot_password.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../RegisterPage/register_page.dart';
import '../RegisterPage/widgets/widgets.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../baseurl/baseurl.dart';

enum TeacherPopupType {
  pending,
  rejected,
  wrongPassword,
  emailNotFound,
  alreadyLoggedInOtherDevice,
  serverError,
  blocked,
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  CommonMethod common = CommonMethod();

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String _deviceModel = "Loading...";

  bool _isLoading = false;

  // UI validations
  String? validationMessage;
  String? passwordError;

  // UI state
  List<bool> isSelected = [true, false]; // Student, Teacher
  bool _obscure = true;
  
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String? deviceModel = "Unknown";

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceModel = webInfo.appName;
      } else {
        deviceModel = switch (defaultTargetPlatform) {
          TargetPlatform.android => (await deviceInfoPlugin.androidInfo).model,
          TargetPlatform.iOS => (await deviceInfoPlugin.iosInfo).model,
          TargetPlatform.linux => (await deviceInfoPlugin.linuxInfo).prettyName,
          TargetPlatform.windows => (await deviceInfoPlugin.windowsInfo).productName,
          TargetPlatform.macOS => (await deviceInfoPlugin.macOsInfo).model,
          TargetPlatform.fuchsia => "Fuchsia platform isn't supported",
        };
      }
    } on PlatformException {
      deviceModel = "Failed to get platform version.";
    }

    if (!mounted) return;
    setState(() => _deviceModel = deviceModel ?? "Unknown");
  }

  void validateEmail() {
    setState(() {
      String value = emailController.text.trim();
      String emailPattern =
          r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
      RegExp regex = RegExp(emailPattern);

      if (value.isEmpty) {
        validationMessage = 'Please enter your email id';
      } else if (!regex.hasMatch(value)) {
        validationMessage = 'Please enter a valid email id';
      } else {
        validationMessage = null;
      }
    });
  }

  void validatePassword() {
    setState(() {
      String value = passwordController.text;

      if (value.isEmpty) {
        passwordError = 'Please enter your password';
      } else if (value.length < 6) {
        passwordError = "Password must be at least 6 characters";
      } else {
        passwordError = null;
      }
    });
  }

  void _onRoleChange(int index) {
    setState(() {
      isSelected = [index == 0, index == 1];
      emailController.clear();
      passwordController.clear();
    });

    // optional: keyboard close + focus reset
    FocusScope.of(context).unfocus();
  }

  Future<void> _showLoader(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: PrimaryCircularProgressWidget()),
    );
  }

  void _hideLoader(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }


  Future<void> loginUser(BuildContext context) async {
    await _showLoader(context);

    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      final String? deviceToken = await firebaseMessaging.getToken();

      final response = await http.post(
        Uri.parse(login),
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'device_id': _deviceModel,
          'firebase_token': deviceToken ?? '',
        },
      );

      _hideLoader(context);

      // ✅ ADD: safe json decode for all cases
      Map<String, dynamic> body = {};
      try {
        body = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final int apiStatus =
          int.tryParse(body["status"]?.toString() ?? "") ?? response.statusCode;

      final String msg = (body["message"] ?? "").toString().toLowerCase();

      // ✅ ADD: 404 Email not found
      if (apiStatus == 404 || msg.contains("email not found")) {
        showMastTeacherPopup(context, type: TeacherPopupType.emailNotFound);
        return;
      }

      // ✅ ADD: 400 credentials not matched
      if (apiStatus == 400 || msg.contains("credentials not matched")) {
        showMastTeacherPopup(context, type: TeacherPopupType.wrongPassword);
        return;
      }

      if (response.statusCode == 200 && body.isNotEmpty) {
        // ✅ ADD: user block check (status 0 = blocked)
        final int userStatus =
            int.tryParse(body['data']?['status']?.toString() ?? '') ?? -1;

        if (userStatus == 0) {
          showMastTeacherPopup(
            context,
            type: TeacherPopupType.blocked, // ✅ add enum if not exists
            customMessage: "Your account is blocked. Please contact support.",
          );
          return;
        }

        // ✅ status 1 = allow login
        if (userStatus == 1) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String token = body['token']?.toString() ?? '';
          final String userId = body['data']['id'].toString();
          final String name = body['data']['name'].toString();
          final String userData = json.encode(body['data']); // ✅ safe

          await prefs.setString('token', token);
          await prefs.setString('name', name);
          await prefs.setString('id', userId);
          await prefs.setString('data', userData);
          await prefs.setBool('isLoggedIn', true);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Homepage(initialIndex: 0)),
          );
          return;
        }

        // ✅ if status neither 0 nor 1
        showMastTeacherPopup(
          context,
          type: TeacherPopupType.serverError,
          customMessage: "Invalid user status. Please contact support.",
        );
        return;
      } else {
        showMastTeacherPopup(
          context,
          type: TeacherPopupType.alreadyLoggedInOtherDevice, // ✅ new enum
          customMessage:
          "Login is restricted to the registered device only.Please use your registered device to continue.",
        );

      }
    } catch (e) {
      _hideLoader(context);
      emailController.clear();
      passwordController.clear();
      showMastTeacherPopup(
        context,
        type: TeacherPopupType.serverError,
        customMessage: "Failed to log in. Please try again.",
      );
    }
  }

  Future<void> loginTeacherApi(BuildContext context) async {
    await _showLoader(context);

    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      final String? deviceToken = await firebaseMessaging.getToken();

      final response = await http.post(
        Uri.parse(loginTeacher),
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'device_id': _deviceModel,
          'firebase_token': deviceToken ?? '',
        },
      );

      _hideLoader(context);

      Map<String, dynamic> body = {};
      try {
        body = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final int apiStatus =
          int.tryParse(body["status"]?.toString() ?? "") ?? response.statusCode;

      final String msg = (body["message"] ?? "").toString().toLowerCase();

      if (apiStatus == 404 || msg.contains("email not found")) {
        showMastTeacherPopup(context, type: TeacherPopupType.emailNotFound);
        return;
      }

      if (apiStatus == 400 || msg.contains("credentials not matched")) {
        showMastTeacherPopup(context, type: TeacherPopupType.wrongPassword);
        return;
      }

      if (response.statusCode == 200 && body.isNotEmpty) {
        final int status =
            int.tryParse(body['data']?['status']?.toString() ?? '') ?? -1;

        if (status == 1) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          final String token = body['token']?.toString() ?? '';
          final String userId = body['data']['id'].toString();
          final String userData = json.encode(body['data']);

          await prefs.setString('token', token);
          await prefs.setString('id', userId);
          await prefs.setString('data', userData);
          await prefs.setBool('isLoggedInTeacher', true);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeBottomTeacher()),
          );
          return;
        }

        if (status == 2 || status == 0) {
          showTeacherStatusPopup(context, status: status);
          return;
        }

        showMastTeacherPopup(
          context,
          type: TeacherPopupType.serverError,
          customMessage: "Invalid teacher status. Please contact support.",
        );
        return;
      }

      showMastTeacherPopup(
        context,
        type: TeacherPopupType.serverError,
        customMessage: body["message"]?.toString() ?? "Login failed. Try again.",
      );
    } catch (e) {
      _hideLoader(context);
      emailController.clear();
      passwordController.clear();

      showMastTeacherPopup(
        context,
        type: TeacherPopupType.serverError,
        customMessage: "Failed to log in. Please try again.",
      );
    }
  }

  // ---------------- POPUPS ----------------


  void showTeacherStatusPopup(
      BuildContext context, {
        required int status,
      }) {
    final bool isPending = status == 2;

    final String title = isPending ? "Verification Pending" : "Account Rejected";
    final String subTitle = isPending
        ? "Your profile is under verification.\nPlease wait for approval."
        : "Your request was rejected.\nPlease contact admin/support.";

    final IconData icon =
    isPending ? Icons.hourglass_top_rounded : Icons.cancel_rounded;

    final List<Color> gradient = isPending
        ? [ColorSelect.kBlue1, ColorSelect.kBlue2]
        : const [Color(0xFFB00020), Color(0xFFFF1744)];

    final Color accent = isPending ? ColorSelect.kBlue2 : const Color(0xFFFF1744);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "status",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, ___) {
        final curved = Curves.easeOutBack.transform(anim.value);

        return Transform.scale(
          scale: curved,
          child: Opacity(
            opacity: anim.value,
            child: Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(26),
                        // border: Border.all(color: Colors.white.withOpacity(0.55)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TOP GRADIENT HEADER (premium)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Gradient ring icon
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.65),
                                        Colors.white.withOpacity(0.20),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.28),
                                      ),
                                    ),
                                    child: Icon(icon, color: Colors.white, size: 30),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w800,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Status pill in header
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.25),
                                          ),
                                        ),
                                        child: Text(
                                          isPending ? "Status: Pending" : "Status: Rejected",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // close button
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.22),
                                      ),
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        color: Colors.white, size: 20),
                                  ),
                                )
                              ],
                            ),
                          ),

                          // BODY
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Column(
                              children: [
                                // subtle card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.06),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    subTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.74),
                                      fontSize: 14.8,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // accent info row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _miniInfoChip(
                                        icon: Icons.verified_user_rounded,
                                        label: isPending ? "Under review" : "Not approved",
                                        accent: accent,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _miniInfoChip(
                                        icon: Icons.schedule_rounded,
                                        label: isPending ? "Wait for admin" : "Try again later",
                                        accent: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ACTIONS
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: BorderSide(color: Colors.black.withOpacity(0.12)),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.pop(context);

                                      // ✅ yaha aap action laga do:
                                      // 1) WhatsApp open
                                      // 2) call/email open
                                      // 3) support screen open
                                      //
                                      // Example:
                                      // launchUrl(Uri.parse("https://wa.me/91XXXXXXXXXX?text=Hi%20Support..."));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accent.withOpacity(0.95),
                                            accent.withOpacity(0.78),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.28),
                                            blurRadius: 18,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isPending ? "Got it" : "Contact Support",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14.2,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // bottom safe space
                          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniInfoChip({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12.8,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void showMastTeacherPopup(
      BuildContext context, {
        required TeacherPopupType type,
        String? customMessage,
      }) {
    String title = "";
    String subTitle = "";
    IconData icon = Icons.info_rounded;
    List<Color> gradient = const [ColorSelect.kBlue1,ColorSelect.kBlue2];
    Color btnColor = ColorSelect.kBlue2;
    String badgeText = "";

    switch (type) {
      case TeacherPopupType.pending:
        title = "Verification Pending";
        subTitle = "Your profile is under verification.\nPlease wait for approval.";
        icon = Icons.hourglass_top_rounded;
        gradient = const [ColorSelect.kBlue1, ColorSelect.kBlue2];
        btnColor = ColorSelect.kBlue2;
        badgeText = "Status: Pending";
        break;

      case TeacherPopupType.rejected:
        title = "Account Rejected";
        subTitle = "Your request was rejected.\nPlease contact admin/support.";
        icon = Icons.cancel_rounded;
        gradient = const [Color(0xFFB00020), Color(0xFFFF1744)];
        btnColor = const Color(0xFFFF1744);
        badgeText = "Status: Rejected";
        break;

      case TeacherPopupType.wrongPassword:
        title = "Wrong Password";
        subTitle = customMessage ?? "The password you entered is incorrect.\nTry again.";
        icon = Icons.lock_rounded;
        gradient = const [Color(0xFFFF6A00), Color(0xFFFFB000)];
        btnColor = const Color(0xFFFF6A00);
        badgeText = "Auth: Failed";
        break;

      case TeacherPopupType.emailNotFound:
        title = "Email Not Found";
        subTitle = customMessage ??
            "This email is not registered.\nPlease check and try again.";
        icon = Icons.email_outlined;
        gradient = const [Color(0xFF11998E), Color(0xFF38EF7D)];
        btnColor = const Color(0xFF11998E);
        badgeText = "User: Not Found";
        break;

      case TeacherPopupType.alreadyLoggedInOtherDevice:
        title = "Login Blocked";
        subTitle = customMessage ??
            "You are already logged in on another device.\nPlease logout there first.";
        icon = Icons.phonelink_lock_rounded;
        gradient = const [Color(0xFF6A11CB), Color(0xFF2575FC)];
        btnColor = const Color(0xFF2575FC);
        badgeText = "Device: Conflict";
        break;
      case TeacherPopupType.blocked:
        title = "User Blocked";
        subTitle = customMessage ??
            "You are already logged in on another device.\nPlease logout there first.";
        icon = Icons.phonelink_lock_rounded;
        gradient = const [Color(0xFF6A11CB), Color(0xFF2575FC)];
        btnColor = const Color(0xFF2575FC);
        badgeText = "Device: Conflict";
        break;

      case TeacherPopupType.serverError:
        title = "Something went wrong";
        subTitle = customMessage ?? "Unable to login right now.\nPlease try again later.";
        icon = Icons.error_outline_rounded;
        gradient = const [Color(0xFF2C3E50), Color(0xFF4CA1AF)];
        btnColor = const Color(0xFF4CA1AF);
        badgeText = "Error";
        break;
    }

    showStatusDialogPremium(
      context,
      gradient: gradient,
      icon: icon,
      title: title,
      subTitle: subTitle,
      btnColor: btnColor,
      badgeText: badgeText,
    );

  }




  void showStatusDialogPremium(
      BuildContext context, {
        required List<Color> gradient,
        required IconData icon,
        required String title,
        required String subTitle,
        required Color btnColor,
        required String badgeText,
      }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "status",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, ___) {
        final v = Curves.easeOutBack.transform(anim.value);

        return Transform.scale(
          scale: v,
          child: Opacity(
            opacity: anim.value,
            child: Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(26),
                        // border: Border.all(color: Colors.white.withOpacity(0.55)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ===== HEADER =====
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon with premium ring
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.65),
                                        Colors.white.withOpacity(0.20),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.28),
                                      ),
                                    ),
                                    child: Icon(icon, color: Colors.white, size: 30),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w900,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Badge in header (small premium)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.25),
                                          ),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Close icon
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.22),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ===== BODY =====
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Column(
                              children: [
                                // inner soft card for subtitle
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.06),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    subTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.76),
                                      fontSize: 14.8,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Badge pill (body)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: btnColor.withOpacity(0.09),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: btnColor.withOpacity(0.18),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_rounded,
                                          size: 16, color: btnColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        badgeText,
                                        style: TextStyle(
                                          color: btnColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ===== ACTIONS =====
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: BorderSide(
                                        color: Colors.black.withOpacity(0.12),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            btnColor.withOpacity(0.95),
                                            btnColor.withOpacity(0.72),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: btnColor.withOpacity(0.28),
                                            blurRadius: 18,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14.2,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- PREMIUM UI HELPERS ----------------
  // ✅ SAME GRADIENT FOR BOTH ROLES
  LinearGradient get _bgGradient => const LinearGradient(
    colors: [ColorSelect.kBlue1, ColorSelect.kBlue2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Widget _roleToggle(double screenWidth) {
    final selectedBg = Colors.white;
    final unSelectedText = Colors.white.withOpacity(0.85);

    return Container(
      width: screenWidth * 0.90,
      padding: EdgeInsets.all(6.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => _onRoleChange(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(vertical: 12.sp),
                decoration: BoxDecoration(
                  color: isSelected[0] ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    "Student",
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected[0] ? Colors.black : unSelectedText,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 6.sp),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => _onRoleChange(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(vertical: 12.sp),
                decoration: BoxDecoration(
                  color: isSelected[1] ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    "Teacher",
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected[1] ? Colors.black : unSelectedText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          height: 52.sp,
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 38.sp,
                width: 38.sp,
                decoration: BoxDecoration(
                  // ✅ remove blueGrey, use same premium blue
                  color: ColorSelect.kBlue2.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  // ✅ remove blueGrey, use same premium blue
                  color: ColorSelect.kBlue2,
                ),
              ),
              SizedBox(width: 10.sp),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isPassword ? _obscure : false,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.35),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                  textInputAction:
                  isPassword ? TextInputAction.done : TextInputAction.next,
                  onEditingComplete: () => isPassword
                      ? FocusScope.of(context).unfocus()
                      : FocusScope.of(context).nextFocus(),
                ),
              ),
              if (isPassword)
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Padding(
                    padding: EdgeInsets.all(6.sp),
                    child: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black.withOpacity(0.55),
                      size: 20.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorLine(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 6.sp),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
          SizedBox(width: 6.sp),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginButton({required VoidCallback onPressed}) {
    return Container(
      height: 48.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        // ✅ SAME gradient for both roles
        gradient: const LinearGradient(
          colors: [ColorSelect.kBlue1, ColorSelect.kBlue2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            if (_isLoading) SizedBox(width: 10.sp),
            Text(
              "Login",
              style: GoogleFonts.poppins(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 18.sp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // ✅ SAME background for both roles
      backgroundColor: ColorSelect.kBlue1,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP HEADER (Wave + Logo)
            Container(
              height: 300.sp,
              color: Colors.transparent,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: _bgGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 98.sp,
                            width: 98.sp,
                            padding: EdgeInsets.all(0.sp),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: Image.asset(logo, fit: BoxFit.contain),
                          ),
                          SizedBox(height: 0.sp),
                          Text.rich(
                            TextSpan(
                              text: AppConstants.appLogoName,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: AppConstants.appLogoName2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.sp),
                          Text(
                            isSelected[0]
                                ? "Login to continue as Student"
                                : "Login to continue as Teacher",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(height: 10.sp),

            // PREMIUM TOGGLE
            _roleToggle(screenWidth),
            SizedBox(height: 14.sp),

            // GLASS CARD FORM
            _glassCard(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    _premiumField(
                      label: "Email Id",
                      hint: "Enter your email",
                      controller: emailController,
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => validateEmail(),
                    ),
                    if (validationMessage != null) _errorLine(validationMessage!),
                    SizedBox(height: 14.sp),
                    _premiumField(
                      label: "Password",
                      hint: "Enter your password",
                      controller: passwordController,
                      icon: Icons.lock_rounded,
                      keyboardType: TextInputType.text,
                      isPassword: true,
                      onChanged: (v) => validatePassword(),
                    ),
                    if (passwordError != null) _errorLine(passwordError!),
                    SizedBox(height: 10.sp),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: HexColor('#f04949'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    _loginButton(
                      onPressed: () async {
                        validateEmail();
                        validatePassword();

                        if (validationMessage != null || passwordError != null) {
                          return;
                        }
                        if (!formKey.currentState!.validate()) return;

                        setState(() => _isLoading = true);
                        try {
                          if (isSelected[0]) {
                            await loginUser(context);
                          } else {
                            await loginTeacherApi(context);
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 18.sp),

            // REGISTER LINE
            Padding(
              padding: EdgeInsets.only(bottom: 24.sp),
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Register here",
                      style: GoogleFonts.poppins(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                        
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          nextScreen(context, RegisterPage());
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/HomePage/home_page.dart';
import 'package:realestate/Notification/notification.dart';
import 'package:realestate/StudentTeacherUi/Chat/chat_screen_user.dart';
import 'package:realestate/StudentTeacherUi/schedule.dart';
import 'package:realestate/StudentTeacherUi/teacher_profile.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../HexColorCode/HexColor.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';
import '../baseurl/baseurl.dart';
class TeacherListScreen extends StatefulWidget {
  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  List<dynamic> teachersList = [];
  bool isLoading = true; // ✅ added

  @override
  void initState() {
    super.initState();
    hitTeacherList();
  }

  Future<void> hitTeacherList() async {
    setState(() => isLoading = true); // ✅ start loading
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      final response = await http.get(
        Uri.parse(teacherList),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          setState(() {
            teachersList = (responseData['data'] ?? []) as List<dynamic>;
          });
          print('List :- $teachersList');
        } else {
          throw Exception('Invalid API response: Missing "data" key');
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in hitTeacherList: $e");
    } finally {
      if (mounted) setState(() => isLoading = false); // ✅ stop loading
    }
  }

  // ✅ No Data Premium Card
  Widget _noDataCard() {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_off, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 12),
              const Text(
                "No Teachers Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Teachers list is currently empty.",
                style: TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // ✅ optional retry button
              InkWell(
                onTap: hitTeacherList,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 18, color: Color(0xFF1E3C72)),
                      SizedBox(width: 8),
                      Text(
                        "Retry",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3C72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : teachersList.isEmpty
          ? _noDataCard() // ✅ empty state card
          : ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: teachersList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(
                      url:
                      'https://apiweb.ksadmission.in/upload/banners/pdf/1767180621_ks_am-compressed.pdf',
                      title: 'All Teachers List',
                      category: '',
                      Subject: '',
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 8,
                margin: EdgeInsets.zero,
                shadowColor: Colors.blue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 80.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9506E8),
                        Color(0xFFCCAB21),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "All Teachers",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Manage & View Teachers",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ✅ dynamic count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: Color(0xFF1E3C72),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${teachersList.length}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3C72),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return TeacherCard(teacher: teachersList[index - 1]);
        },
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherCard({super.key, required this.teacher});

  String _safeText(dynamic v, {String fallback = ""}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    if (s.isEmpty || s == "null") return fallback;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final name = _safeText(teacher['name'], fallback: "Teacher");
    final qualification = _safeText(
      teacher['qualification'],
      fallback: "Qualification",
    );
    final language = _safeText(teacher['language'], fallback: "Language");
    final subject = _safeText(teacher['subject_special'], fallback: "Subject");
    final bio = _safeText(teacher['bio'], fallback: "No bio available");
    final rating = _safeText(teacher['avg_rating'], fallback: "0.0");
    final imageUrl = _safeText(teacher['picture_data'], fallback: "");

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: HexColor('#3A33FF'),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {},
            child: Stack(
              children: [
                // Top gradient strip (premium feel)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color(0xFF1F14E1),
                          Color(0xFFC8177B), // Soft Purple Blue
                          // HexColor('#3A33FF'),
                          // HexColor('#3A33FF'),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),

                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar with border glow
                          Column(
                            children: [
                              Container(
                                width: 80.sp,
                                height: 80.sp,
                                padding: EdgeInsets.all(2.2.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  color: Colors.grey.withOpacity(0.35),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(
                                    imageUrl,
                                    width: 60.sp,
                                    height: 60.sp,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Image.network(
                                        'https://i.postimg.cc/HjjPV3YB/Screenshot-2026-01-02-103653-removebg-preview.png',
                                        width: 60.sp,
                                        height: 60.sp,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 0.h,
                                ),
                                decoration: BoxDecoration(
                                  color: HexColor('#010071').withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 10.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      rating,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 10.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + chips
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    _chip(
                                      icon: Icons.translate_rounded,
                                      text: language,
                                      bg: Colors.white.withOpacity(0.18),
                                      fg: Colors.white,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 15.h),
                                Row(
                                  children: [
                                    // 🎓 Qualification
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HexColor(
                                          '#010071',
                                        ).withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                          color: HexColor(
                                            '#010071',
                                          ).withOpacity(0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.school_rounded,
                                            size: 13.sp,
                                            color: HexColor('#010071'),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            qualification ??
                                                'N/A',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5.sp,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: HexColor(
                                                '#010071',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 8.w),

                                    // 📘 Subject Specialization
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HexColor(
                                          '#010071',
                                        ).withOpacity(0.08),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                          color: HexColor(
                                            '#010071',
                                          ).withOpacity(0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 13.sp,
                                            color: HexColor('#010071'),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            subject ??
                                                'N/A',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5.sp,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: HexColor(
                                                '#010071',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),


                                SizedBox(height: 5.h),

                                // Bio (on white area)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F7FB),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.06),
                                    ),
                                  ),
                                  child: Text(
                                    bio,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blueGrey.shade700,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: _primaryButton(
                              icon: Icons.account_circle,
                              text: "Profile",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TeacherProfileScreen(data: teacher),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _primaryButton(
                              icon: Icons.schedule,
                              text: "Schedule",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ScheduleScreen(data: teacher),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // Chat (same logic, better UI)
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 40.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F7FB),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.06),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 18.sp,
                                      height: 18.sp,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                final users = snapshot.data!.docs.where((user) {
                                  return user['email'] ==
                                      _safeText(teacher['email']);
                                }).toList();

                                if (users.isEmpty) {
                                  return _softButton(
                                    icon: Icons.chat_rounded,
                                    text: "Chat",
                                    onTap: () => showCustomDialog(context),
                                  );
                                }

                                final user = users[0];

                                return _softButton(
                                  icon: Icons.chat_rounded,
                                  text: "Chat",
                                  onTap: () {
                                    final currentUser =
                                        FirebaseAuth.instance.currentUser;
                                    if (currentUser != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatUserScreen(
                                            chatId: '',
                                            userName: '',
                                            image: '',
                                            currentUser: currentUser,
                                            chatUser: user,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
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
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _chip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: fg),
          SizedBox(width: 5.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 90.w),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 25.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp, color: HexColor('#010071')),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            color: HexColor('#010071'),
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFF6F7FB),
          side: BorderSide(color: HexColor('#010071')),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _softButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 25.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp, color: HexColor('#010071')),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            color: HexColor('#010071'),
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF6F7FB),
          side: BorderSide(color: HexColor('#010071')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  // ---------- Dialog (same, just a bit premium) ----------
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.sp,
                  height: 56.sp,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 30.sp,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Teacher Not Found",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "No teachers are available for chat at the moment.\nPlease try again later.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: HexColor('#010071'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../CommonCalling/progressbarPrimari.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';
import '../baseurl/baseurl.dart';

class ProfileTeacherScreen extends StatefulWidget {
  const ProfileTeacherScreen({super.key});

  @override
  State<ProfileTeacherScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<ProfileTeacherScreen> {
  bool _isLoading = false;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String experience = '';
  String qualification = '';
  String language = '';
  String subjectSpecialization = '';
  String avg_rating = '';
  String happy_student = '';
  String Reviews = '';

  @override
  void initState() {
    super.initState();
    fetchTeacherProfileData();
  }

  Future<void> fetchTeacherProfileData() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse(teacherProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() => _isLoading = false);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        nickname = jsonData['data']['name'] ?? '';
        userEmail = jsonData['data']['email'] ?? '';
        contact = jsonData['data']['contact'] ?? '';
        address = jsonData['data']['address'] ?? '';
        bio = jsonData['data']['bio'] ?? '';
        photoUrl = jsonData['data']['picture_data'] ?? '';
        qualification = jsonData['data']['qualification'] ?? '';
        experience = jsonData['data']['experience'] ?? '';
        language = jsonData['data']['language'] ?? '';
        subjectSpecialization = jsonData['data']['subject_special'] ?? '';
        happy_student = jsonData['data']['happy_student'].toString() ?? '';
        avg_rating = jsonData['data']['avg_rating'].toString() ?? '';
        Reviews = jsonData['data']['review_Count'].toString() ?? '';
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  // ---------- UI Helpers ----------
  static const _g1 = Color(0xFF010071);
  static const _g2 = Color(0xFF0A1AFF);
  static const _surface = Color(0xFFFFFFFF);

  String _safe(String v, {String fallback = "—"}) {
    final x = v.trim();
    return x.isEmpty ? fallback : x;
  }

  TextStyle get _titleStyle => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF0B0F1A),
  );

  TextStyle get _subStyle => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF6B7280),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: _isLoading
          ? const Center(child: PrimaryCircularProgressWidget())
          : CustomScrollView(
        slivers: [

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
              child: Column(
                children: [
                  _buildProfileCard(),
                  SizedBox(height: 12.h),

                  _buildInfoSection("Contact", contact, Icons.phone),
                  _buildInfoSection(
                      "Address", address, Icons.location_on),
                  _buildInfoSection(
                      "Subject", subjectSpecialization, Icons.book),
                  _buildInfoSection(
                      "Languages", language, Icons.language),

                  SizedBox(height: 12.h),
                  _buildStatRow(),

                  SizedBox(height: 14.h),
                  _buildAboutSection(),
                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ---------- Card ----------
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.blue,width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Row(
              children: [
                // avatar with ring
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_g1, _g2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.r),
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 62.w,
                      height: 62.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                      const PrimaryCircularProgressWidget(),
                      errorWidget: (context, url, error) => Container(
                        width: 62.w,
                        height: 62.w,
                        color: const Color(0xFFE5E7EB),
                        child: Icon(Icons.person, size: 28.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 👤 Name
                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              _safe(nickname, fallback: "Teacher"),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0B0F1A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      /// 📧 Email
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              _safe(userEmail),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      /// 🎓 Qualification
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              _safe(qualification),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Buttons (same actions)
            Row(
              children: [
                // Expanded(
                //   child: _actionButton(
                //     bg: const Color(0xFF2563EB),
                //     icon: Icons.edit,
                //     title: "Edit Profile",
                //     sub: "Update info",
                //     onTap: () {
                //       // Handle edit profile action
                //     },
                //   ),
                // ),
                // SizedBox(width: 5.w),
                Expanded(
                  child: _actionButton(
                    bg: const Color(0xFF16A34A),
                    icon: Icons.account_balance_wallet,
                    title: "Wallet",
                    sub: "₹ 0.00",
                    onTap: () {
                      // Handle wallet action
                    },
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: _actionButton(
                    bg: const Color(0xFFFB923C),
                    icon: Icons.people_alt_rounded,
                    title: "All Teachers",
                    sub: "PDF List",
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required Color bg,
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(icon, color: Colors.white, size: 16.sp),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Stats ----------
  Widget _buildStatRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildStatItem(
              value: "${_safe(experience, fallback: "0")} Years",
              label: "Experience",
              icon: Icons.work_history_outlined,
            ),
          ),
          _vDivider(),
          Expanded(
            child: _buildStatItem(
              value: _safe(happy_student, fallback: "0"),
              label: "Happy",
              icon: Icons.emoji_emotions_rounded,
            ),
          ),
          _vDivider(),
          Expanded(
            child: _buildStatItem(
              value: _safe(avg_rating, fallback: "0"),
              label: "Rating",
              icon: Icons.star_rounded,
            ),
          ),
          _vDivider(),
          Expanded(
            child: _buildStatItem(
              value: _safe(Reviews, fallback: "0"),
              label: "Reviews",
              icon: Icons.reviews_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1.w,
      height: 42.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_g1.withOpacity(.10), _g2.withOpacity(.10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: const Color(0xFF0B2BFF), size: 18.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B0F1A),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ---------- Info Sections ----------
  Widget _buildInfoSection(String title, String value, IconData icon) {
    final v = _safe(value);
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          leading: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_g1.withOpacity(.10), _g2.withOpacity(.10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: const Color(0xFF0B2BFF), size: 20.sp),
          ),
          title: Text(title, style: _titleStyle),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              v,
              style: _subStyle,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded,
              color: Colors.black.withOpacity(.35)),
        ),
      ),
    );
  }

  // ---------- About ----------
  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_g1.withOpacity(.10), _g2.withOpacity(.10)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(Icons.info_outline_rounded,
                    size: 18.sp, color: const Color(0xFF0B2BFF)),
              ),
              SizedBox(width: 10.w),
              Text("About Me", style: _titleStyle),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _safe(bio, fallback: "No bio added yet."),
            style: _subStyle,
          ),
        ],
      ),
    );
  }
}

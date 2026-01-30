import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';

class HistoryAppointmentScreen extends StatefulWidget {
  const HistoryAppointmentScreen({super.key});

  @override
  State<HistoryAppointmentScreen> createState() => _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<HistoryAppointmentScreen> {

  bool isLoading = true;
  bool chatReady = false;
  String? chatError;

  List<dynamic> bookingList = [];

  @override
  void initState() {
    super.initState();
    hitBookingList();
  }


  Future<void> hitBookingList() async {
    if (mounted) setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(getBooking),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (mounted) {
          setState(() {
            bookingList = (responseData['bookings'] ?? []) as List<dynamic>;
          });
        }
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
        ? const Center(child: PrimaryCircularProgressWidget())
        : bookingList.isEmpty
        ? _noDataCard()
        : ListView.builder(
      padding: const EdgeInsets.all(5.0),
      itemCount: bookingList.length,
      itemBuilder: (context, index) {
        final item = bookingList[index];
        // ✅ safe cast
        final map = (item is Map<String, dynamic>) ? item : <String, dynamic>{};
        return TeacherCard(teacher: map);
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: body),
        ],
      ),
    );
  }

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
                "No Appointment Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Appointment list is currently empty.",
                style: TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: hitBookingList,
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
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
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

  Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final teacherMap = _safeMap(teacher['teacher']);
    final slotMap = _safeMap(teacher['slot']);

    final name = _safeText(teacherMap['name'], fallback: "Teacher");
    final qualification = _safeText(teacherMap['qualification'], fallback: "Qualification");
    final subject = _safeText(teacherMap['subject_special'], fallback: "Subject");
    final rating = _safeText(teacherMap['avg_rating'], fallback: "0.0");

    final date = _safeText(slotMap['date'], fallback: "-");
    final startTime = _safeText(slotMap['start_time'], fallback: "-");
    final tokenNo = _safeText(slotMap['token_no'] ?? slotMap['id'], fallback: "-"); // ✅ adjust as per API

    final statusText = _safeText(teacher['status_text'], fallback: "Complete");

    // ✅ image url safe
    final rawImage = _safeText(teacherMap['picture_data'], fallback: "");
    final imageUrl = rawImage.startsWith("http") ? rawImage : "";

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
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 38.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xFF1F14E1), Color(0xFFC8177B)],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 80.sp,
                              height: 70.sp,
                              padding: EdgeInsets.all(2.2.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                color: Colors.grey.withOpacity(0.35),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: imageUrl.isEmpty
                                    ? Image.network(
                                  'https://i.postimg.cc/HjjPV3YB/Screenshot-2026-01-02-103653-removebg-preview.png',
                                  fit: BoxFit.cover,
                                )
                                    : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Image.network(
                                      'https://i.postimg.cc/HjjPV3YB/Screenshot-2026-01-02-103653-removebg-preview.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 5.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    icon: Icons.star_rounded,
                                    text: rating,
                                    bg: Colors.white.withOpacity(0.15),
                                    fg: Colors.white,
                                  ),
                                ],
                              ),

                              SizedBox(height: 10.h),

                              Row(
                                children: [
                                  _miniTag(
                                    icon: Icons.school_rounded,
                                    text: qualification,
                                  ),
                                  SizedBox(width: 8.w),
                                  _miniTag(
                                    icon: Icons.menu_book_rounded,
                                    text: subject,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoChip(icon: Icons.calendar_today_rounded, label: date, color: Colors.indigo),
                          _infoChip(icon: Icons.access_time_rounded, label: startTime, color: Colors.green),
                          _infoChip(icon: Icons.confirmation_number_rounded, label: tokenNo, color: Colors.deepOrange),
                        ],
                      ),
                    ),

                    const Divider(),
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Expanded(
                          child: _primaryButton(
                            icon: statusText == "Pending"
                                ? Icons.hourglass_top
                                : statusText == "Cancelled"
                                ? Icons.cancel_outlined
                                : Icons.check_circle,
                            text: statusText,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _softButton(
                            icon: Icons.chat_rounded,
                            text: "Chat",
                            onTap: () {
                              // yaha tum stream chat open kar sakte ho
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
    );
  }

  Widget _miniTag({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: HexColor('#010071').withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HexColor('#010071').withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: HexColor('#010071')),
          SizedBox(width: 4.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: HexColor('#010071'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(color: color.withOpacity(.1), shape: BoxShape.circle),
            child: Icon(icon, size: 12.sp, color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _chip({required IconData icon, required String text, required Color bg, required Color fg}) {
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
          Icon(icon, size: 12.sp, color: Colors.amber),
          SizedBox(width: 5.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 90.w),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 9.5.sp, fontWeight: FontWeight.w500, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 25.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp, color: HexColor('#010071')),
        label: Text(
          text,
          style: GoogleFonts.poppins(color: HexColor('#010071'), fontSize: 10.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFF6F7FB),
          side: BorderSide(color: HexColor('#010071')),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _softButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 25.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp, color: HexColor('#010071')),
        label: Text(
          text,
          style: GoogleFonts.poppins(color: HexColor('#010071'), fontSize: 10.sp, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF6F7FB),
          side: BorderSide(color: HexColor('#010071')),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}


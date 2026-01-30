import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../CommonCalling/progressbarPrimari.dart';
import '../StudentProfile/student_profile.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  bool isLoading = true;
  List<dynamic> bookingList = [];

  @override
  void initState() {
    super.initState();
    hitBookingList();
  }

  Future<void> hitBookingList() async {
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(studentListBooking),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          bookingList = (responseData['bookings'] as List?) ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          bookingList = [];
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        bookingList = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: isLoading
            ? const Center(child: PrimaryCircularProgressWidget())
            : bookingList.isEmpty
            ? _DataNotFound(
          onRefresh: hitBookingList,
        )
            : RefreshIndicator(
          onRefresh: hitBookingList,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              final item = (bookingList[index] ?? {}) as Map<String, dynamic>;
              return AppointmentCard(booking: item);
            },
          ),
        ),
      ),
    );
  }
}

/// =====================
/// DATA NOT FOUND UI (MAST)
/// =====================
class _DataNotFound extends StatelessWidget {
  final VoidCallback onRefresh;

  const _DataNotFound({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: const LinearGradient(
              colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1AFF).withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -40,
                child: Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 36.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    "No bookings available right now",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '"No students or bookings available right now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onRefresh,
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded,
                                    size: 18.sp, color: const Color(0xFF010071)),
                                SizedBox(width: 8.w),
                                Text(
                                  "Refresh",
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF010071),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// CARD
/// =====================
class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const AppointmentCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final user = (booking['user'] ?? {}) as Map<String, dynamic>;
    final slot = (booking['slot'] ?? {}) as Map<String, dynamic>;

    final String name = (user['name'] ?? '').toString();
    final String district = (user['district'] ?? '').toString();
    final String state = (user['state'] ?? '').toString();
    final String bio = (user['bio'] ?? '').toString();
    final String pic = (user['picture_data'] ?? '').toString();

    final String date = (slot['date'] ?? '').toString();
    final String time = (slot['start_time'] ?? '').toString();
    final String uniqueId = (booking['unique_id'] ?? '').toString();

    final int userId = (user['id'] is int)
        ? user['id'] as int
        : int.tryParse((user['id'] ?? '0').toString()) ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A1AFF).withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _avatar(pic),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name.isEmpty ? "Student" : name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0B1B3A),
                                    ),
                                  ),
                                ),
                                _ratingPill(),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 16.sp, color: Colors.blueGrey),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    "${district.isEmpty ? "-" : district} / ${state.isEmpty ? "-" : state}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (bio.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Text(
                                bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                  color: Colors.blueGrey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6FF),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _infoItem(
                            icon: Icons.calendar_today_rounded,
                            label: "Date",
                            value: date.isEmpty ? "-" : date,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _infoItem(
                            icon: Icons.access_time_rounded,
                            label: "Time",
                            value: time.isEmpty ? "-" : time,
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _primaryBtn(
                          icon: Icons.remove_red_eye_rounded,
                          text: "View",
                          onTap: () {
                            if (userId == 0) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentProfileScreen(id: userId),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _gradientBtn(
                          icon: Icons.chat_bubble_rounded,
                          text: "Chat",
                          onTap: () {
                            // TODO: Your chat logic
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
    );
  }

  Widget _avatar(String pic) {
    return Container(
      width: 62.w,
      height: 62.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1AFF).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(2.2.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              pic,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Image.asset(
                  'assets/teacher_user.jpg',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            "4.7",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFE3EBFF)),
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF010071)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1B3A),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _primaryBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2F3A4A),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFF2F3A4A), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.green.shade700, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

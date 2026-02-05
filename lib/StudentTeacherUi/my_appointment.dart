import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../baseurl/baseurl.dart';
import 'ChatUsersListScreen/chat_user-screen.dart';

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
  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    hitBookingList();
  }

  Future<void> fetchProfileData() async {
    setState(() {});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() {
        userId = jsonData['user']['id'].toString();
      });
    }
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

        print('data $responseData');

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
        return TeacherCard(teacher: map,userId: userId,);
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
  final String? userId;

  const TeacherCard({super.key, required this.teacher, this.userId});

  // -------------------- SAFE HELPERS --------------------
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

  // -------------------- SLOT PARSING + CHAT LOGIC --------------------
  DateTime? _parseSlotDateTime(String date, String startTime) {
    // date examples: "2026-02-03" or "03-02-2026" or "03/02/2026"
    // time examples: "09:30", "9:30 AM", "09:30:00"
    if (date.trim().isEmpty || startTime.trim().isEmpty) return null;

    String d = date.trim();
    String t = startTime.trim().toUpperCase();

    // ---- Parse date ----
    DateTime? datePart;

    final iso = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // yyyy-MM-dd
    final dmy = RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$'); // dd-MM-yyyy or dd/MM/yyyy

    if (iso.hasMatch(d)) {
      final parts = d.split('-');
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (y != null && m != null && day != null) {
        datePart = DateTime(y, m, day);
      }
    } else if (dmy.hasMatch(d)) {
      final parts = d.contains('-') ? d.split('-') : d.split('/');
      final day = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (y != null && m != null && day != null) {
        datePart = DateTime(y, m, day);
      }
    }

    if (datePart == null) return null;

    // ---- Parse time ----
    int? hour;
    int? minute;

    // "09:30:00" -> "09:30"
    if (t.split(':').length >= 3) {
      t = t.split(':').take(2).join(':');
    }

    final isAm = t.contains('AM');
    final isPm = t.contains('PM');
    t = t.replaceAll('AM', '').replaceAll('PM', '').trim();

    final timeParts = t.split(':');
    if (timeParts.length >= 2) {
      hour = int.tryParse(timeParts[0].trim());
      minute = int.tryParse(timeParts[1].trim());
    } else {
      return null;
    }

    if (hour == null || minute == null) return null;

    // 12h -> 24h
    if (isAm || isPm) {
      if (hour == 12) hour = 0;
      if (isPm) hour = hour + 12;
    }

    return DateTime(datePart.year, datePart.month, datePart.day, hour, minute);
  }

  /// ✅ Strict 30 minute slot
  bool _isChatAllowed30Min(String date, String startTime) {
    final slotDT = _parseSlotDateTime(date, startTime);
    if (slotDT == null) return false;

    final now = DateTime.now();
    final endDT = slotDT.add(const Duration(minutes: 30));

    if (now.isBefore(slotDT)) return false;
    if (now.isAfter(endDT)) return false;

    return true;
  }

  String _prettySlot(String date, String startTime) => "$date • $startTime";

  // ✅ DAY : HOUR : MIN : SEC formatter
  String _formatDHMS(Duration d) {
    final totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;

    final days = totalSeconds ~/ (24 * 3600);
    final hours = (totalSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return "${days.toString().padLeft(2, '0')} : "
        "${hours.toString().padLeft(2, '0')} : "
        "${minutes.toString().padLeft(2, '0')} : "
        "${seconds.toString().padLeft(2, '0')}";
  }

  // -------------------- PREMIUM POPUP + LIVE COUNTDOWN --------------------
  Future<void> _showChatTimePopupSmart(
      BuildContext context,
      String date,
      String startTime,
      ) async {
    final slotDT = _parseSlotDateTime(date, startTime);
    final slotLabel = _prettySlot(date, startTime);

    // If slot invalid -> simple fallback dialog
    if (slotDT == null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text("Chat Unavailable"),
          content: Text("Slot details not found.\n$slotLabel"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "chat_slot_dialog",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) {
        Timer? timer;

        return StatefulBuilder(
          builder: (ctx, setState) {
            // ✅ start timer once
            timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
              // if dialog already closed, stop timer
              if (!Navigator.of(ctx).canPop()) {
                timer?.cancel();
                timer = null;
                return;
              }
              setState(() {});
            });

            // ✅ cancel when dialog closes
            Future.microtask(() {
              ModalRoute.of(ctx)?.popped.then((_) {
                timer?.cancel();
                timer = null;
              });
            });

            final now = DateTime.now();
            final endDT = slotDT.add(const Duration(minutes: 30));

            final bool before = now.isBefore(slotDT);
            final bool during = !before && !now.isAfter(endDT);
            final bool after = now.isAfter(endDT);

            String title;
            String subtitle;
            IconData icon;
            Color accent;

            if (before) {
              title = "Chat Locked";
              subtitle = "Chat will start at the scheduled time.\n(30 minutes slot)";
              icon = Icons.lock_outline_rounded;
              accent = const Color(0xFF2563EB);
            } else if (during) {
              title = "Chat Available";
              subtitle = "You can chat now. Slot will close automatically.";
              icon = Icons.chat_bubble_outline_rounded;
              accent = const Color(0xFF10B981);
            } else {
              title = "Slot Expired";
              subtitle = "This 30-minute chat slot is finished.";
              icon = Icons.timer_off_outlined;
              accent = const Color(0xFFEF4444);
            }

            // ✅ countdown
            Duration diff;
            String countdownTitle;

            if (before) {
              diff = slotDT.difference(now);
              countdownTitle = "Chat starts in";
            } else if (during) {
              diff = endDT.difference(now);
              countdownTitle = "Time remaining";
            } else {
              diff = Duration.zero;
              countdownTitle = "Slot expired";
            }

            final countdownText = after ? "00 : 00 : 00 : 00" : _formatDHMS(diff);

            Widget countdownChip() {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: accent.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countdownTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      countdownText, // DD : HH : MM : SS
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Days",
                            style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280))),
                        Text("Hours",
                            style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280))),
                        Text("Min",
                            style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280))),
                        Text("Sec",
                            style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 340.w,
                  margin: EdgeInsets.symmetric(horizontal: 18.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Stack(
                      children: [
                        // ✅ Top gradient header
                        Container(
                          height: 62.h,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [Color(0xFF1F14E1), Color(0xFFC8177B)],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 2.h),

                              // ✅ Icon circle
                              Container(
                                width: 54.sp,
                                height: 54.sp,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.20),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 42.sp,
                                    height: 42.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(icon, color: accent, size: 24.sp),
                                  ),
                                ),
                              ),

                              SizedBox(height: 12.h),

                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),

                              SizedBox(height: 6.h),

                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5.sp,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),

                              SizedBox(height: 14.h),

                              // ✅ countdown
                              countdownChip(),

                              SizedBox(height: 12.h),

                              // ✅ Slot info chip
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: accent.withOpacity(0.22)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.schedule_rounded, color: accent, size: 16.sp),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        slotLabel,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        side: BorderSide(
                                          color: const Color(0xFF111827).withOpacity(0.15),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.r),
                                        ),
                                        backgroundColor: const Color(0xFFF6F7FB),
                                      ),
                                      child: Text(
                                        "Close",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),

                                  // ✅ OK button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        backgroundColor: accent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      child: Text(
                                        "OK",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),

                        // ✅ close X
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                              ),
                              child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  // -------------------- UI WIDGETS --------------------
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

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12.sp, color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

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
          Icon(icon, size: 12.sp, color: Colors.amber),
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
      height: 35.h,
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

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final teacherMap = _safeMap(teacher['teacher']);
    final slotMap = _safeMap(teacher['slot']);

    final teacherId = _safeText(teacher['teacher_id']);
    final name = _safeText(teacherMap['name'], fallback: "Teacher");
    final qualification =
    _safeText(teacherMap['qualification'], fallback: "Qualification");
    final subject =
    _safeText(teacherMap['subject_special'], fallback: "Subject");
    final rating = _safeText(teacherMap['avg_rating'], fallback: "0.0");

    final date = _safeText(slotMap['date'], fallback: "-");
    final startTime = _safeText(slotMap['start_time'], fallback: "-");
    final tokenNo =
    _safeText(slotMap['token_no'] ?? slotMap['id'], fallback: "-");

    final statusText = _safeText(teacher['status_text'], fallback: "Complete");

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
                              'https://img.freepik.com/free-vector/purple-man-with-blue-hair_24877-82003.jpg',
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
                              SizedBox(height: 15.h),
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
                          _infoChip(
                            icon: Icons.calendar_today_rounded,
                            label: date,
                            color: Colors.indigo,
                          ),
                          _infoChip(
                            icon: Icons.access_time_rounded,
                            label: startTime,
                            color: Colors.green,
                          ),
                          _infoChip(
                            icon: Icons.confirmation_number_rounded,
                            label: tokenNo,
                            color: Colors.deepOrange,
                          ),
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
                        // Expanded(
                        //   child: _softButton(
                        //     icon: Icons.chat_rounded,
                        //     text: "Chat",
                        //     onTap: () async {
                        //       if (date == "-" || startTime == "-") {
                        //         await _showChatTimePopupSmart(context, date, startTime);
                        //         return;
                        //       }
                        //
                        //       final allowed = _isChatAllowed30Min(date, startTime);
                        //
                        //       if (allowed) {
                        //
                        //         print('cureentUser$userId');
                        //         print('chatUser$teacherId');
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (_) => ChatUserScreen(
                        //               chatId: "",
                        //               userName: name,
                        //               image: imageUrl,
                        //               currentUser: userId.toString(),
                        //               chatUser: teacherId,
                        //             ),
                        //           ),
                        //         );
                        //       } else {
                        //
                        //         await _showChatTimePopupSmart(context, date, startTime);
                        //       }
                        //     },
                        //   ),
                        // ),
                        Expanded(
                          child: ChatSlotButton(
                            date: date,
                            startTime: startTime,

                            // same helpers reuse
                            parseSlotDateTime: _parseSlotDateTime,
                            formatDHMS: _formatDHMS,

                            onAllowedTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatUserScreen(
                                    chatId: "",
                                    userName: name,
                                    image: imageUrl,
                                    currentUser: userId.toString(),
                                    chatUser: teacherId,
                                    canSend: true, // ✅ during -> send allowed
                                  ),
                                ),
                              );
                            },

                            onNotAllowedTap: () async {
                              final slotDT = _parseSlotDateTime(date, startTime);
                              if (slotDT == null) {
                                await _showChatTimePopupSmart(context, date, startTime);
                                return;
                              }

                              final endDT = slotDT.add(const Duration(minutes: 30));
                              final now = DateTime.now();

                              final bool expired = now.isAfter(endDT);

                              if (expired) {
                                // ✅ expired -> open chat, but send disabled
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatUserScreen(
                                      chatId: "",
                                      userName: name,
                                      image: imageUrl,
                                      currentUser: userId.toString(),
                                      chatUser: teacherId,
                                      canSend: false, // ❌ expired -> no sending
                                    ),
                                  ),
                                );
                              } else {
                                // locked (before start) -> show popup
                                await _showChatTimePopupSmart(context, date, startTime);
                              }
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
}




class ChatSlotButton extends StatefulWidget {
  final String date;
  final String startTime;

  final VoidCallback onAllowedTap; // slot active -> open chat
  final VoidCallback onNotAllowedTap; // locked/expired -> show popup

  final DateTime? Function(String date, String startTime) parseSlotDateTime;
  final String Function(Duration d) formatDHMS;

  const ChatSlotButton({
    super.key,
    required this.date,
    required this.startTime,
    required this.onAllowedTap,
    required this.onNotAllowedTap,
    required this.parseSlotDateTime,
    required this.formatDHMS,
  });

  @override
  State<ChatSlotButton> createState() => _ChatSlotButtonState();
}

class _ChatSlotButtonState extends State<ChatSlotButton> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotDT = widget.parseSlotDateTime(widget.date, widget.startTime);

    // slot invalid -> normal chat button
    if (slotDT == null || widget.date == "-" || widget.startTime == "-") {
      return SizedBox(
        height: 30.h,
        child: OutlinedButton.icon(
          onPressed: widget.onNotAllowedTap,
          icon: Icon(Icons.chat_rounded, size: 16.sp, color: const Color(0xFF010071)),
          label: Text(
            "Chat",
            style: GoogleFonts.poppins(
              color: const Color(0xFF010071),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF6F7FB),
            side: const BorderSide(color: Color(0xFF010071)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final endDT = slotDT.add(const Duration(minutes: 30));

    final bool before = now.isBefore(slotDT);
    final bool during = !before && !now.isAfter(endDT);
    final bool after = now.isAfter(endDT);

    String statusText;
    IconData statusIcon;
    Color borderColor;
    Color bgColor;
    Color fgColor;

    if (before) {
      statusText = "Chat Locked";
      statusIcon = Icons.lock_outline_rounded;
      borderColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFF2563EB).withOpacity(0.06);
      fgColor = const Color(0xFF1E40AF);
    } else if (during) {
      statusText = "Chat Start";
      statusIcon = Icons.chat_bubble_outline_rounded;
      borderColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withOpacity(0.08);
      fgColor = const Color(0xFF047857);
    } else {
      statusText = "Slot Expired";
      statusIcon = Icons.timer_off_outlined;
      borderColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFEF4444).withOpacity(0.06);
      fgColor = const Color(0xFFB91C1C);
    }

    Duration diff;
    String countdownTitle;

    if (before) {
      diff = slotDT.difference(now);
      countdownTitle = "Starts in :";
    } else if (during) {
      diff = endDT.difference(now);
      countdownTitle = "Time left :";
    } else {
      diff = Duration.zero;
      countdownTitle = "";
    }

    final countdown = after ? "You can view messages only." : widget.formatDHMS(diff);

    return SizedBox(
      height: 35.h, // ✅ a bit bigger so text never clips
      child: OutlinedButton(
        onPressed: during ? widget.onAllowedTap : widget.onNotAllowedTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor.withOpacity(0.95)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        ),
        child: Row(
          children: [
            Icon(statusIcon, size: 16.sp, color: fgColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status line
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ✅ Countdown line (FIXED: never hides seconds)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$countdownTitle $countdown",
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: fgColor,
                        height: 1.0,
                        // ✅ digits stable width => seconds never "jump/hide"
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded, size: 18.sp, color: fgColor.withOpacity(0.85)),
          ],
        ),
      ),
    );
  }
}


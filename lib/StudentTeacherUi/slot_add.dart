import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../baseurl/baseurl.dart';
import '../CommonCalling/progressbarPrimari.dart';

class AddSlotScreen extends StatefulWidget {
  const AddSlotScreen({super.key});

  @override
  State<AddSlotScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<AddSlotScreen> {
  int selectedTimeIndex = -1;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  TimeOfDay? _selectedTime; // Store selected time
  TimeOfDay? _selectedTime2; // Store selected time

  bool isLoading = true;
  int? selectedSlotId;

  /// Generates a list of days for the selected month, including only 2 days before today
  List<DateTime> getFilteredMonthDays(DateTime month) {
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    List<DateTime> allDays = List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );

    // Filter: Show only 2 days before today and the rest of the month
    return allDays
        .where(
          (date) =>
              date.isAfter(DateTime.now().subtract(Duration(days: 1))) ||
              date.isAtSameMomentAs(DateTime.now()),
        )
        .toList();
  }

  /// Moves to the next month
  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  /// Moves to the previous month (only if not in the current month)
  void _previousMonth() {
    if (_selectedDate.month > _currentDate.month ||
        _selectedDate.year > _currentDate.year) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          1,
        );
      });
    }
  }

  List<dynamic> slot = [];

  /// Function to show time picker
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickTime2(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime2 ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime2 = pickedTime;
      });
    }
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final formattedTime = DateFormat(
      "HH:mm",
    ).format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    return formattedTime;
  }

  String displayTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final formattedTime = DateFormat(
      "h:mm a",
    ).format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    return formattedTime;
  }

  bool get _isFormValid {
    // date always set hai, but past date block already hai
    if (_selectedTime == null || _selectedTime2 == null) return false;

    final start = _toMinutes(_selectedTime!);
    final end = _toMinutes(_selectedTime2!);

    // end must be strictly greater than start
    if (end <= start) return false;

    // selected date should not be past (safety)
    final now = DateTime.now();
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (selected.isBefore(today)) return false;

    return true;
  }

  int _toMinutes(TimeOfDay t) => (t.hour * 60) + t.minute;

  @override
  void initState() {
    super.initState();
  }

  Future<void> hitSlotBook(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: PrimaryCircularProgressWidget());
        },
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final response = await http.post(
        Uri.parse(addSlots),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "date": DateFormat("dd-MM-yyyy").format(_selectedDate),
          "start_time": formatTime(_selectedTime), // Use 24-hour format
          "end_time": formatTime(_selectedTime2), // Use 24-hour format
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        Navigator.pop(context);
        print("Booking successful: $responseData");
        Fluttertoast.showToast(
          msg: "Create successful!",
          toastLength: Toast.LENGTH_SHORT,
          // or Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM,
          // TOP, CENTER, BOTTOM
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        throw Exception('Failed to book slot: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error booking slot: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthDays = getFilteredMonthDays(_selectedDate);
    final monthName = DateFormat.yMMMM().format(_selectedDate);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ---------- Header ----------
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 5.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 42.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                  // SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Add Slot",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Pick date & time, then create slot",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---------- Body ----------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
                // bottom space for button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month switch row
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: _cardDeco(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Select Date",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _iconCircle(
                            enabled:
                                (_selectedDate.month > _currentDate.month ||
                                _selectedDate.year > _currentDate.year),
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: _previousMonth,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          _iconCircle(
                            enabled: true,
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: _nextMonth,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Date chips
                    SizedBox(
                      height: 70.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: monthDays.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final now = DateTime.now();
                          final date = monthDays[index];

                          final isPastDate = date.isBefore(
                            DateTime(now.year, now.month, now.day),
                          );
                          final isSelected =
                              date.day == _selectedDate.day &&
                              date.month == _selectedDate.month &&
                              date.year == _selectedDate.year;

                          final bg = isPastDate
                              ? Colors.grey.shade200
                              : (isSelected ? homepageColor : Colors.white);

                          final border = isSelected
                              ? Colors.transparent
                              : Colors.black.withOpacity(0.07);

                          final txt = isPastDate
                              ? Colors.black.withOpacity(0.35)
                              : (isSelected ? Colors.white : Colors.black87);

                          return GestureDetector(
                            onTap: isPastDate
                                ? null
                                : () => setState(() => _selectedDate = date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 74.w,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: border),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: homepageColor.withOpacity(
                                            0.25,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E().format(date),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: txt,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "${date.day}",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w900,
                                      color: txt,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Time section title
                    Text(
                      "Select Time",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // Time cards (Start / End)
                    Row(
                      children: [
                        Expanded(
                          child: _timeCard(
                            title: "Start Time",
                            value: displayTime(_selectedTime),
                            icon: Icons.access_time_rounded,
                            onTap: () => _pickTime(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _timeCard(
                            title: "End Time",
                            value: displayTime(_selectedTime2),
                            icon: Icons.timelapse_rounded,
                            onTap: () => _pickTime2(context),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Summary card
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: _cardDeco(),
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: homepageColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.event_available_rounded,
                              color: homepageColor,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Summary",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "${DateFormat("dd MMM yyyy").format(_selectedDate)}  •  ${displayTime(_selectedTime)} - ${displayTime(_selectedTime2)}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Sticky Bottom Button ----------
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  if (!_isFormValid) {
                    Fluttertoast.showToast(
                      msg: (_selectedTime == null || _selectedTime2 == null)
                          ? "Please select start & end time"
                          : "End time must be after start time",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    return;
                  }
                  hitSlotBook(context);
                },
                child: Opacity(
                  opacity: _isFormValid ? 1.0 : 0.45,
                  child: Container(
                    height: 30.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isFormValid
                            ? [Color(0xFF010071), Color(0xFF0A1AFF)]
                            : [Colors.grey, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Center(
                      child: Text(
                        "ADD SLOT",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5.r),
    border: Border.all(color: Colors.blue),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
    ],
  );

  Widget _iconCircle({
    required bool enabled,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled ? Colors.black87 : Colors.black26,
        ),
      ),
    );
  }

  Widget _timeCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18.sp, color: homepageColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black38,
                  size: 22.sp,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Tap to choose",
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black.withOpacity(0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

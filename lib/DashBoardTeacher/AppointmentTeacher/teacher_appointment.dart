import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../CommonCalling/progressbarPrimari.dart';
import '../../StudentTeacherUi/slot_add.dart';
import '../../baseurl/baseurl.dart';

class TeacherScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const TeacherScheduleScreen({super.key, required this.data});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherScheduleScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  int selectedTimeIndex = -1;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();

  bool isLoading = true;
  int? selectedSlotId;
  String _apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

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

  // Function to format time
  String formatTime(String time) {
    try {
      final parsedTime = DateFormat(
        "HH:mm",
      ).parse(time); // Parse 24-hour format
      return DateFormat(
        "h:mm a",
      ).format(parsedTime); // Convert to 12-hour format
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();
    hitTeacherSlotList();
  }

  Future<void> hitTeacherSlotList() async {
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) throw Exception("Authorization token is missing.");

      final String dateStr = _apiDate(_selectedDate); // ✅ only yyyy-MM-dd

      final response = await http.get(
        Uri.parse('${teacherSlots}?date=$dateStr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          slot = (responseData['data'] ?? []) as List<dynamic>;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching teacher slots: $e");
      setState(() => slot = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> selectedIndicesSlotAdd = [];

  void toggleSelection(String slotId) {
    setState(() {
      if (selectedIndicesSlotAdd.contains(slotId)) {
        selectedIndicesSlotAdd.remove(slotId);
        print(selectedIndicesSlotAdd);
      } else {
        selectedIndicesSlotAdd.add(slotId);
        print(selectedIndicesSlotAdd);
      }
    });
  }

  Future<void> deleteSelected() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final Uri apiUrl = Uri.parse(
        teacherCancelSlots,
      ); // Adjust API URL accordingly

      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': selectedIndicesSlotAdd, // Sending slot IDs as an array
        }),
      );

      if (response.statusCode == 200) {
        selectedIndicesSlotAdd.clear();
        hitTeacherSlotList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected slots deleted successfully")),
        );
      } else {
        throw Exception('Failed to delete slots: ${response.body}');
      }
    } catch (e) {
      print("Error deleting slots: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting slots: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> monthDays = getFilteredMonthDays(_selectedDate);
    final String monthName = DateFormat.yMMMM().format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _premiumHeader(monthName),
            ),

            /// Date strip
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
                child: _sectionTitle(
                  title: "Select Date",
                  sub: "Choose a day to manage your slots",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96.h,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: monthDays.length,
                  itemBuilder: (context, index) {
                    final DateTime now = DateTime.now();
                    final DateTime date = monthDays[index];

                    final bool isPastDate = date.isBefore(
                      DateTime(now.year, now.month, now.day),
                    );

                    final bool isCurrentDate =
                        date.day == now.day &&
                            date.month == now.month &&
                            date.year == now.year;

                    final bool isSelected =
                        date.day == _selectedDate.day &&
                            date.month == _selectedDate.month &&
                            date.year == _selectedDate.year;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.r),
                        onTap: isPastDate
                            ? null
                            : () {
                          setState(() {
                            _selectedDate = date;
                            isLoading = true;
                            selectedIndicesSlotAdd.clear();
                          });
                          hitTeacherSlotList();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 78.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.r),
                            gradient: isSelected
                                ? const LinearGradient(
                              colors: [Color(0xFF0A1AFF), Color(0xFF010071)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : isCurrentDate
                                ? const LinearGradient(
                              colors: [Color(0xFF00B2FF), Color(0xFF0077FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: (!isSelected && !isCurrentDate)
                                ? Colors.white
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: isPastDate
                                  ? Colors.redAccent.withOpacity(0.35)
                                  : isSelected
                                  ? Colors.white.withOpacity(0.18)
                                  : const Color(0xFFE6E9F6),
                              width: 1,
                            ),
                          ),
                          child: Opacity(
                            opacity: isPastDate ? 0.55 : 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat.E().format(date),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: (isSelected || isCurrentDate)
                                        ? Colors.white.withOpacity(0.95)
                                        : const Color(0xFF2A2F45),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: (isSelected || isCurrentDate)
                                        ? Colors.white
                                        : isPastDate
                                        ? Colors.redAccent
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Container(
                                  height: 6.h,
                                  width: 22.w,
                                  decoration: BoxDecoration(
                                    color: (isSelected || isCurrentDate)
                                        ? Colors.white.withOpacity(0.85)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// Time section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
                child: _sectionTitle(
                  title: "Select Time",
                  sub: "Tap slots to select & delete",
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: _legendRow(),
              ),
            ),

            /// Body
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 12.h, 5.w, 100.h),
                child: _bodySlots(),
              ),
            ),
          ],
        ),
      ),

      /// Premium FAB stack
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selectedIndicesSlotAdd.isNotEmpty ? 1 : 0.0,
            child: selectedIndicesSlotAdd.isNotEmpty
                ? FloatingActionButton.extended(
              heroTag: "deleteFab",
              onPressed: deleteSelected,
              backgroundColor: const Color(0xFF950606),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                "Delete (${selectedIndicesSlotAdd.length})",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700,color: Colors.white),
              ),
            )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 12.h),
          FloatingActionButton(
            heroTag: "addFab",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent, // premium look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                ),
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                    ),
                    child: const AddSlotScreen(),
                  );
                },
              );

            },
            backgroundColor: const Color(0xFF0A1AFF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// ---------- UI HELPERS (paste inside class) ----------

  Widget _premiumHeader(String monthName) {
    return Container(
      margin: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 0.h),
      padding: EdgeInsets.fromLTRB(14.w, 5.h, 14.w, 5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1AFF).withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Teacher Schedule",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  monthName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          _monthSwitcher(monthName),
        ],
      ),
    );
  }

  Widget _monthSwitcher(String monthName) {
    final bool canGoBack = _selectedDate.month > _currentDate.month ||
        _selectedDate.year > _currentDate.year;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: canGoBack ? _previousMonth : null,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: canGoBack ? Colors.white : Colors.white.withOpacity(0.35),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            DateFormat.MMM().format(_selectedDate),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: _nextMonth,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({required String title, required String sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          sub,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _legendRow() {
    Widget pill(Color c, String t) => Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6E9F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4.r))),
          SizedBox(width: 8.w),
          Text(t, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2A2F45))),
        ],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          pill(Colors.grey.shade500, "Cancel"),
          SizedBox(width: 10.w),
          pill(Colors.redAccent.shade100, "Slot Booked"),
          SizedBox(width: 10.w),
          pill(Colors.white, "Available"),
        ],
      ),
    );
  }

  Widget _bodySlots() {
    if (isLoading) {
      return Container(
        height: 260.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFE6E9F6)),
        ),
        child: const Center(child: PrimaryCircularProgressWidget()),
      );
    }

    if (slot.isEmpty) {
      return Container(
        height: 260.h,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFE6E9F6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 110.w,
              height: 110.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset('assets/NO_SLOT_AVAILABLE_IMG.png', fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "No Slots Available",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF111827)),
            ),
            SizedBox(height: 6.h),
            Text(
              "Try another date or add new slots",
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE6E9F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: slot.map((slotItem) {
          final String slotId = slotItem['id'].toString();
          final bool isSelected = selectedIndicesSlotAdd.contains(slotId);

          final int booked = (slotItem['is_booked'] ?? 0) as int;

          Color bg;
          Color fg;

          if (booked == 1) {
            bg = Colors.redAccent.shade100;
            fg = const Color(0xFF8A0B0B);
          } else if (booked == 2) {
            bg = Colors.grey.shade700;
            fg = Colors.white;
          } else if (isSelected) {
            bg = const Color(0xFF0A1AFF);
            fg = Colors.white;
          } else {
            bg = const Color(0xFFF3F5FF);
            fg = const Color(0xFF111827);
          }

          return InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => toggleSelection(slotId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? Colors.white.withOpacity(0.7) : const Color(0xFFE6E9F6),
                  width: isSelected ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.12 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                '${formatTime(slotItem['start_time'])} - ${formatTime(slotItem['end_time'])}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

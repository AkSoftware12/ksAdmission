import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final response = await http.get(
        Uri.parse('${teacherSlots}?date=$_selectedDate'),
        // Ensure teacherList is a valid API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          setState(() {
            slot = responseData['data'];
            isLoading = false;

            print(
              ' Slot Data : $slot',
            ); // Ensure teachersList is properly defined
          });
        } else {
          throw Exception('Invalid API response: Missing "data" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching teacher list: $e");
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
    List<DateTime> monthDays = getFilteredMonthDays(_selectedDate);
    String monthName = DateFormat.yMMMM().format(
      _selectedDate,
    ); // Example: "February 2025"
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: homepageColor,
                        ),
                      ),
                    ],
                  ),
                  Card(
                    elevation: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Show back arrow only if the user is ahead of the current month
                        if (_selectedDate.month > _currentDate.month ||
                            _selectedDate.year > _currentDate.year)
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 20),
                            onPressed: _previousMonth,
                          )
                        else
                          SizedBox(width: 8),

                        // Placeholder for spacing
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 20,
                          ),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// **Month Selector**

            /// **Horizontal Month Calendar**
            SizedBox(
              height: 100,
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: monthDays.length,
                  itemBuilder: (context, index) {
                    final DateTime currentDate = DateTime.now();
                    final DateTime date = monthDays[index];

                    final bool isPastDate = date.isBefore(
                      DateTime(
                        currentDate.year,
                        currentDate.month,
                        currentDate.day,
                      ),
                    );
                    final bool isCurrentDate =
                        date.day == currentDate.day &&
                        date.month == currentDate.month &&
                        date.year == currentDate.year;
                    final bool isSelected =
                        date.day == _selectedDate.day &&
                        date.month == _selectedDate.month &&
                        date.year == _selectedDate.year;

                    Color getColor() {
                      if (isCurrentDate) return Colors.blue;
                      if (isSelected) return Colors.green;
                      if (isPastDate) return Colors.red;
                      return Colors.grey[200]!;
                    }

                    return GestureDetector(
                      onTap: isPastDate
                          ? null
                          : () {
                              setState(() {
                                _selectedDate = date;
                                hitTeacherSlotList();
                                selectedIndicesSlotAdd.clear();
                              });
                            },
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: getColor(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(date),
                              // Short day name (Mon, Tue)
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCurrentDate || isSelected || isPastDate
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              date.day.toString(), // Day number
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: isCurrentDate || isSelected || isPastDate
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: homepageColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(width: 12.sp, height: 12.sp, color: Colors.grey),
                  Text(
                    ' Cancel',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: homepageColor,
                    ),
                  ),
                  SizedBox(width: 10.sp),

                  Container(
                    width: 12.sp,
                    height: 12.sp,
                    color: Colors.redAccent.shade100,
                  ),
                  Text(
                    ' Slot Booked',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: homepageColor,
                    ),
                  ),

                  SizedBox(width: 10.sp),

                  Container(width: 12.sp, height: 12.sp, color: Colors.white),
                  Text(
                    ' Available',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: homepageColor,
                    ),
                  ),
                ],
              ),
            ),

            isLoading
                ? Container(
                    height: 300.sp,
                    child: Center(child: CircularProgressIndicator()),
                  ) // Show loading indicator
                : slot.isEmpty
                ? SingleChildScrollView(
                    child: Container(
                      height: 300.sp,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/NO_SLOT_AVAILABLE_IMG.png',
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No Slots Available",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        // height: 300.sp,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: slot.map((slotItem) {
                              String slotId = slotItem['id']
                                  .toString(); // Get slot ID as String
                              bool isSelected = selectedIndicesSlotAdd.contains(
                                slotId,
                              ); // Check selection by slot ID

                              return GestureDetector(
                                onTap: () => toggleSelection(slotId),
                                // Pass slot ID instead of index
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: slotItem['is_booked'] == 1
                                        ? Colors.red.shade100
                                        : slotItem['is_booked'] == 2
                                        ? Colors.grey.shade500
                                        : isSelected
                                        ? Colors.indigoAccent
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    '${formatTime(slotItem['start_time'])} To ${formatTime(slotItem['end_time'])}',
                                    style: TextStyle(
                                      fontSize: 12,

                                      color: slotItem['is_booked'] == 1
                                          ? Colors.red
                                          : slotItem['is_booked'] == 2
                                          ? Colors.white
                                          : isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (selectedIndicesSlotAdd.isNotEmpty)
            FloatingActionButton(
              onPressed: deleteSelected,
              child: Icon(Icons.delete, color: Colors.white),
              backgroundColor: HexColor('#950606'),
            ),
          SizedBox(height: 20.sp),
          FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => AddSlotScreen(),
              );
            },
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}

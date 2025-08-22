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

class AddSlotScreen extends StatefulWidget {
  const AddSlotScreen({super.key, });

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
        daysInMonth, (index) => DateTime(month.year, month.month, index + 1));

    // Filter: Show only 2 days before today and the rest of the month
    return allDays
        .where((date) =>
    date.isAfter(DateTime.now().subtract(Duration(days: 1))) ||
        date.isAtSameMomentAs(DateTime.now()))
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
        _selectedDate =
            DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
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
    final formattedTime = DateFormat("HH:mm").format(DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ));
    return formattedTime;
  }

  String displayTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final formattedTime = DateFormat("h:mm a").format(DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ));
    return formattedTime;
  }


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
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
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
          toastLength: Toast.LENGTH_SHORT,  // or Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM,  // TOP, CENTER, BOTTOM
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    List<DateTime> monthDays = getFilteredMonthDays(_selectedDate);
    String monthName = DateFormat.yMMMM().format(_selectedDate); // Example: "February 2025"
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                                    color: homepageColor),
                              )
                            ],
                          ),
                          Card(
                            elevation: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (_selectedDate.month > _currentDate.month ||
                                    _selectedDate.year > _currentDate.year)
                                  IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        size: 20,
                                      ),
                                      onPressed: _previousMonth)
                                else
                                  SizedBox(width: 8),
                                Text(monthName,
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.bold)),
                                IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 20,
                                    ),
                                    onPressed: _nextMonth),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: monthDays.length,
                        itemBuilder: (context, index) {
                          final DateTime currentDate = DateTime.now();
                          final DateTime date = monthDays[index];

                          final bool isPastDate = date.isBefore(DateTime(
                              currentDate.year, currentDate.month, currentDate.day));
                          final bool isCurrentDate = date.day == currentDate.day &&
                              date.month == currentDate.month &&
                              date.year == currentDate.year;
                          final bool isSelected = date.day == _selectedDate.day &&
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
                              });
                            },
                            child: Container(
                              width: 80,
                              margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                color: getColor(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E().format(date),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentDate ||
                                          isSelected ||
                                          isPastDate
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentDate ||
                                          isSelected ||
                                          isPastDate
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Select Time',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: homepageColor),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => _pickTime(context),
                            child: Text( formatTime(_selectedTime)), // Display in 12-hour format
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => _pickTime2(context),
                            child: Text(formatTime(_selectedTime2)), // Display in 12-hour format
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Spacer to push button to bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: GestureDetector(
                  onTap: (){
                    hitSlotBook(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50, // Fixed height
                    decoration: BoxDecoration(
                      color: homepageColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'ADD',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )

    );
  }
}

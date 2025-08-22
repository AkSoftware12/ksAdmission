import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../HomePage/home_page.dart';
import '../baseurl/baseurl.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ScheduleScreen({super.key, required this.data});

  @override
  State<ScheduleScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<ScheduleScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  int selectedTimeIndex = -1;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  bool isLoading = true;
  int? selectedSlotId;
  bool isChecked1 = false; // User can toggle this
  bool isChecked2 = true; // Always checked and disabled
  bool isChecked3 = false;

  String subsid = "0";
  String planId = "";
  String price = "";
  String type = "";

  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  dynamic currency = '';

  String? razorpayOrderId = '';
  String? razorpayKeyId = '';
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';


  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;

  bool isDataLoading = true;

  String _selectedPayment = 'Wallet'; // Default selected payment method


  /// Generates a list of days for the selected month, including only 2 days before today
  List<DateTime> getFilteredMonthDays(DateTime month) {
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    List<DateTime> allDays = List.generate(
        daysInMonth, (index) => DateTime(month.year, month.month, index + 1));

    // Filter: Show only 2 days before today and the rest of the month
    return allDays.where((date) =>
    date.isAfter(DateTime.now().subtract(Duration(days: 1))) ||
        date.isAtSameMomentAs(DateTime.now())).toList();
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


  final List<String> times = [
    "9:00 AM  To 9:15 AM",
    "9:30 AM To 9:45 AM",
    "10:00 AM To 10:15 AM",
    "10:30 AM To 10:45 AM",
    "11:00 AM To 11:15 AM",
    "11:30 AM To 11:45 AM",
    "9:00 AM  To 9:15 AM",
    "9:30 AM To 9:45 AM",
    "10:00 AM To 10:15 AM",
    "10:30 AM To 10:45 AM",
    "11:00 AM To 11:15 AM",
    "11:30 AM To 11:45 AM",
  ];
  final List<bool> disabledTimes = [
    false,
    true,
    true,
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    true,
    false
  ];

  List<dynamic> slot = [];

// Function to format time
  String formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm").parse(
          time); // Parse 24-hour format
      return DateFormat("h:mm a").format(
          parsedTime); // Convert to 12-hour format
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();
    razorpayKeyData();
    super.initState();

    print(' Tpye : $type');
    hitTeacherList(DateFormat('yyyy-MM-dd').format(_selectedDate));
  }

  void _refresh() {
    setState(() {
      hitTeacherList(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }

  Future<void> hitTeacherList(dynamic date) async {
    try {

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final response = await http.post(
        Uri.parse('$studentCheckSlot${widget.data['id']}'),
        // Ensure teacherList is a valid API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
          // Replace with actual parameters
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          setState(() {
            slot = responseData['data'];
            isLoading = false;

            print(
                ' Slot Data : $slot'); // Ensure teachersList is properly defined
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


  Future<void> hitSlotBook(BuildContext context, int? id) async {
    try {
      // Show loading dialog
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return const Center(
      //       child: CircularProgressIndicator(color: Colors.orange,),
      //     );
      //   },
      // );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final response = await http.post(
        Uri.parse('$bookSlot$id'), // Ensure bookSlot is a valid API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // "date": DateFormat('yyyy-MM-dd').format(_selectedDate), // Replace with actual parameters
        }),
      );

      // Close the loading dialog
      // Navigator.pop(context);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Booking successful: $responseData");
        hideLoadingDialog(context);

        _showPaymentSuccessDialog3(context);

      } else {
        // hideLoadingDialog(context);
        Navigator.pop(context);

        throw Exception('Failed to book slot: ${response.statusCode}');
      }
    } catch (e) {
      // Ensure loading dialog is dismissed in case of error
      Navigator.pop(context);
      print("Error booking slot: $e");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showPaymentSuccessDialog3(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  'Booking  Successful',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Your solt has been booked successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _refresh();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> monthDays = getFilteredMonthDays(_selectedDate);
    String monthName = DateFormat.yMMMM().format(
        _selectedDate); // Example: "February 2025"
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(59),
        child: Column(
          children: [
            AppBar(
              elevation: 4,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Appointment ",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              flexibleSpace: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [homepageColor, primaryColor],
                    begin: Alignment.topCenter,
                    // Horizontal gradient starts from left
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              actions: [
                // Container(
                //   margin: EdgeInsets.only(right: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.2),
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: Icon(Icons.search, color: Colors.white),
                //     onPressed: () {
                //       // Future search functionality
                //     },
                //   ),
                // ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
            ),
            Container(
              height: 0,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, homepageColor],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 0),
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      widget.data['picture_data'].toString(),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) {
                                        return Image.asset(
                                          'assets/teacher_user.jpg',
                                          // Ensure this image exists in your assets folder
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              widget.data['name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          widget.data['subject_special'] ??
                                              'N/A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(height: 5),

                                        Text(
                                          widget.data['language'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          widget.data['qualification'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8,
                                  vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber,
                                      size: 15),
                                  SizedBox(width: 3),
                                  Text(
                                    // teacher.rating.toString(),
                                    widget.data['avg_rating'].toString() ??
                                        'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Select Date',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: homepageColor
                            ),
                          )
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
                              IconButton(icon: Icon(Icons.arrow_back_ios,
                                size: 20,), onPressed: _previousMonth)
                            else
                              SizedBox(width: 8),
                            // Placeholder for spacing

                            Text(monthName, style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),

                            IconButton(icon: Icon(
                              Icons.arrow_forward_ios_outlined, size: 20,),
                                onPressed: _nextMonth),
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: monthDays.length,
                    itemBuilder: (context, index) {
                      final DateTime currentDate = DateTime.now();
                      final DateTime date = monthDays[index];

                      final bool isPastDate = date.isBefore(DateTime(
                          currentDate.year, currentDate.month,
                          currentDate.day));
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
                            hitTeacherList(widget.data['id']);
                            selectedTimeIndex=-1;

                          });
                        },
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
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

                                  color: isCurrentDate || isSelected ||
                                      isPastDate ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                date.day.toString(), // Day number
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentDate || isSelected ||
                                      isPastDate ? Colors.white : Colors.black,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Select Time',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: homepageColor
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
                      Container(
                        width: 12.sp,
                        height: 12.sp,
                        color: Colors.grey,
                      ),
                      Text(' Not Available',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: homepageColor
                        ),
                      ),
                      SizedBox(width: 10.sp,),

                      Container(
                        width: 12.sp,
                        height: 12.sp,
                        color: Colors.redAccent.shade100,
                      ),
                      Text(' Slot Booked',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: homepageColor
                        ),
                      ),

                      SizedBox(width: 10.sp,),

                      Container(
                        width: 12.sp,
                        height: 12.sp,
                        color: Colors.white,
                      ),
                      Text(' Available',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: homepageColor
                        ),
                      ),
                    ],
                  ),
                ),


                isLoading
                    ? Container(
                    height: 300.sp,
                    child: Center(
                        child: CircularProgressIndicator())) // Show loading indicator
                    : slot.isEmpty
                    ? Container(
                    height: 300.sp,
                    child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              // width: 120,
                                height: 180,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                        'assets/NO_SLOT_AVAILABLE_IMG.png'))),
                            SizedBox(height: 10,),
                            // Text("No Slots Available", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                          ],
                        )))
                    : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 300.sp,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(slot.length, (index) {
                            return GestureDetector(
                              onTap: slot[index]['is_booked'] != null && slot[index]['is_booked'] != 0
                                  ? null
                                  : () {
                                setState(() {
                                  selectedTimeIndex = index;
                                  selectedSlotId = slot[index]['id'];
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12,
                                    horizontal: 5),
                                decoration: BoxDecoration(
                                  color: slot[index]['is_booked'] == 1
                                      ? Colors.red.shade100
                                      : slot[index]['is_booked'] == 2
                                      ? Colors.grey.shade400
                                      : selectedTimeIndex == index
                                      ? Colors.indigoAccent
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${formatTime(
                                      slot[index]['start_time'])} To ${formatTime(
                                      slot[index]['end_time'])}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: slot[index]['is_booked'] == 1
                                        ? Colors.red
                                        : slot[index]['is_booked'] == 2
                                        ? Colors.white
                                        : selectedTimeIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    )

                ),


              ])),

      bottomSheet: Container(
        height: 70,
        color: Colors.green.shade100,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              if (selectedSlotId != null)

                setState(() {
                  // subsid = planlist[i].planId.toString();
                  planId = selectedSlotId.toString();
                  price = '50';
                  type =  '';
                });

              print(' Tpye : $type');


              _showPaymentBottomSheet('50');


              // hitSlotBook(context, selectedSlotId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: homepageColor, // Added button color
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Pay ', // Price text
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  WidgetSpan(
                    child: Icon(
                      Icons.currency_rupee, // Rupee icon
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '50', // Price text
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // TextSpan(
                  //   text: '\nper session', // Price text
                  //   style: TextStyle(
                  //     fontSize: 9,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.green.shade900,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),

      ),
    );
  }

  void _showPaymentBottomSheet(String price) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Wallet Option with Card Style
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPayment = "Wallet");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedPayment == "Wallet" ? Colors.blue.shade50 : Colors.white,
                        border: Border.all(
                          color: _selectedPayment == "Wallet" ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.blue, size: 28),
                          SizedBox(width: 15),
                          Expanded(child: Text("Wallet", style: TextStyle(fontSize: 16))),
                          Icon(
                            _selectedPayment == "Wallet" ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: _selectedPayment == "Wallet" ? Colors.blue : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Razorpay Option with Card Style
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPayment = "Razorpay");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedPayment == "Razorpay" ? Colors.green.shade50 : Colors.white,
                        border: Border.all(
                          color: _selectedPayment == "Razorpay" ? Colors.green : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.green, size: 28),
                          SizedBox(width: 15),
                          Expanded(child: Text("Razorpay", style: TextStyle(fontSize: 16))),
                          Icon(
                            _selectedPayment == "Razorpay" ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: _selectedPayment == "Razorpay" ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // Confirm Button with Gradient
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showLoadingDialog(context);
                      _handlePaymentSelection();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: homepageColor,
                    ),
                    child: Text(
                      "Confirm Payment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handlePaymentSelection() {

    if(_selectedPayment=='Wallet'){
      walletBalancePayApi(price);
    }else{
      ordersCreateApi(price);
    }

  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User manually dialog close na kar sake
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Please wait...")
            ],
          ),
        );
      },
    );
  }
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> walletBalancePayApi(String amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri uri = Uri.parse(payWalletBalance); // Replace with your actual API URL
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final Map<String, dynamic> body = {'amount': amount};

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          setState(() {
            hitSlotBook(context, selectedSlotId);

            // createPlan();
          });

        } else {
          hideLoadingDialog(context);


        }
      } else {
        hideLoadingDialog(context);

        Fluttertoast.showToast(
          msg: "Insufficient Balance",
          toastLength: Toast.LENGTH_LONG,  // or Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM,     // Position: TOP, CENTER, BOTTOM
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // _showInsufficientBalanceDialog(context);


      }
    } catch (e) {
      hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Network Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> createPlan() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id',);
    final String? token = prefs.getString('token',);

    Map<String, dynamic> responseData = {
      "plan_id": planId,
      "user_id": userId.toString(),
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(planCreate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );
      hideLoadingDialog(context);

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if(type=='6'){
          _showPaymentSuccessDialog2(context);

        }else{
          _showPaymentSuccessDialog(context);

        }



        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Homepage(
        //       initialIndex: 0,
        //     ),
        //   ),
        // );
      } else {
        Navigator.pop(context);
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }



  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Payment Successful',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Your payment has been processed successfully!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homepage(
                      initialIndex: 0,
                    ),
                  ),
                );              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSuccessDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Payment Successful',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Your payment has been  successfully! Plan  will  be Active with in 24 Hours ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homepage(
                      initialIndex: 0,
                    ),
                  ),
                );              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> ordersCreateApi(String price) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('id');
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "amount": (double.parse(price) * 100).toInt(), // Convert to paise
        "currency": "INR",
      };

      final response = await http.post(
        Uri.parse(ordersIdRazorpay), // Replace with your URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          razorpayOrderId = jsonData['data']['id'].toString();

          openCheckout(
            razorpayKeyId,
            double.parse(price) * 100,
          );


        });
        print("Order Created: $razorpayOrderId");
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to create order');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('An error occurred while creating the order');
    }
  }
  Future<void> razorpayKeyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(razorpayKayId);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        razorpayKeyId = jsonData['razor_pay_id'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }




  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Success callback
    print("Payment Successful: ${response.paymentId}");
    // Required fields
    String orderId = response.orderId ?? "";
    String paymentId = response.paymentId ?? "";
    String signature = response.signature ?? "";

    // Additional data
    String status = "success";
    String currency = "INR";
    String paymentMethod = "UPI"; // Example
    String txnDate = DateTime.now().toString();

    // // Send to server or next steps
    // print("Order ID: $orderId");
    // print("Payment ID: $paymentId");
    // print("Signature: $signature");
    // print("Amount: $amount");
    // print("Currency: $currency");
    // print("Status: $status");
    // print("Payment Method: $paymentMethod");
    // print("Transaction Date: $txnDate");

    // SubscriptionAPI();



    StorePaymnet('${price}',orderId,paymentId,currency,status,signature,paymentMethod,txnDate,null,'',null,);

    print(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });

    String orderId = '';
    String paymentId = '';
    String signature = '';

    // Additional data
    String status = "Failed";
    String currency = "INR";
    String paymentMethod = "UPI"; // Example
    String txnDate = DateTime.now().toString();

    StorePaymnet('${price}',orderId,paymentId,currency,status,signature,paymentMethod,txnDate,response.code,response.message,response.error);

    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }


  Future<void> StorePaymnet(
      String price,
      String orderId,
      String paymentId,
      String currency,
      String status,
      String signature,
      String paymentMethod,
      String txnDate,
      int? errorCode,
      String? errorDescription,
      Map<dynamic, dynamic>? failureReason,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
      'id',
    );
    final String? token = prefs.getString(
      'token',
    );

    Map<String, dynamic> responseData = {
      "order_id": orderId,
      "payment_id": paymentId,
      "amount": price.toString(),
      "currency": currency,
      "status": status,
      "signature": signature,
      "payment_method": paymentMethod,
      "txn_date": txnDate,
      "error_code": errorCode,
      "error_description": errorDescription,
      "failure_reason": '',
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(paymentStore),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);
        // createPlan();

        hitSlotBook(context, selectedSlotId);


      } else {
        Navigator.pop(context);
        _showPaymentFailedDialog(context);

        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${nickname}',
        'order_id': '${razorpayOrderId}',
        'description': 'Subscription',
        'prefill': {
          'contact': '${contact}',
          'email': '${userEmail}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
        hideLoadingDialog(context); // Dialog Band Karega

      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }
  void _showPaymentFailedDialog(BuildContext context,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title:  Text(
            '${'Payment Failed'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:  [

              Center(
                child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.asset('assets/payment failed.png')),
              ),




              SizedBox(height: 10),
              Text(
                'Your payment has been ${' Failed'}!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}







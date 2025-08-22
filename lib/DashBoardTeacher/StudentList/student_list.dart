import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../StudentTeacherUi/Chat/chat_screen_user.dart';
import '../../Utils/app_colors.dart';
import '../StudentProfile/student_profile.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<StudentListScreen> {
  List<dynamic> bookingList = [];

  @override
  void initState() {
    super.initState();
    hitBookingList();
  }

  Future<void> hitBookingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(studentListBooking),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('bookings')) {
        setState(() {
          bookingList = responseData['bookings'];
          print('List :-  $bookingList');
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: bookingList.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                return AppointmentCard(booking: bookingList[index]);
              },
            ),
    );
  }
}

// Appointment Card Widget
class AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> booking;

  AppointmentCard({required this.booking});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                        widget.booking['user']['picture_data'].toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/teacher_user.jpg',
                            // Ensure this image exists in your assets folder
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking['user']['name'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '',
                            // widget.booking['user']['category']['name'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.booking['user']['district'].toString()} ${'/'} ${widget.booking['user']['state'].toString()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.booking['user']['bio'].toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(widget.booking['slot']['date'].toString()),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(widget.booking['slot']['start_time'].toString()),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(widget.booking['unique_id'].toString()),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // Align items properly
                  children: [
                    Expanded(
                      // Ensures button takes up remaining space
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(100, 40), // Set reasonable size
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentProfileScreen(
                                id: widget.booking['user']['id'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Prevents unnecessary stretching
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Aligns content properly
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                              size: 20,
                            ),
                            // Your chosen icon
                            SizedBox(width: 8),
                            // Adds spacing between icon and text
                            Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var users = snapshot.data!.docs.where((user) {
                            return user['email'] ==
                                widget.booking['user']['email']
                                    .toString(); // Filter users by email
                          }).toList();

                          if (users.isEmpty) {
                            return GestureDetector(
                              onTap: () {
                                showCustomDialog(context);
                              },
                              child: Card(
                                color: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Chat ${widget.booking['user']['email'].toString()}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 5.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            // Important for nested lists
                            physics: NeverScrollableScrollPhysics(),
                            // Prevents scrolling conflict
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              var user = users[0];
                              return GestureDetector(
                                onTap: () {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (currentUser != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatUserScreen(
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
                                child: Card(
                                  color: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Chat",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (widget.booking['video_link'] != null) Divider(),
                if (widget.booking['video_link'] != null)
                  /// Mark as Complete Checkbox
                  SizedBox(
                    height: 20.sp,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              isCompleted = value ?? false;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        Text(
                          "Mark as Complete",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),
                SizedBox(height: 10),
                Text(
                  "Student  Not Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                // Text(
                //   "No teachers are available for chat at the moment. Please try again later.",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("OK", style: TextStyle(color: Colors.white)),
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

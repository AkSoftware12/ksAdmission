import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/StudentTeacherUi/Chat/chat_screen_user.dart';
import 'package:realestate/StudentTeacherUi/schedule.dart';
import 'package:realestate/StudentTeacherUi/teacher_profile.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../baseurl/baseurl.dart';






class TeacherListScreen extends StatefulWidget {
  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {

  List<dynamic> teachersList = [];


  @override
  void initState() {
    super.initState();
    hitTeacherList();
  }

  Future<void> hitTeacherList() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      final response = await http.get(
        Uri.parse(teacherList), // teacherList should be a valid URL string
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // ensure JSON response
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          setState(() {
            teachersList = responseData['data'];
          });
          print('List :- $teachersList');
        } else {
          throw Exception('Invalid API response: Missing "data" key');
        }
      } else {
        // Debug response if not 200
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in hitTeacherList: $e");
      rethrow; // optionally handle with UI error message
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar:AppBar(
        backgroundColor: primaryColor,
        // elevation: 4,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Online DashBoard",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // flexibleSpace: Container(
        //   height: 100,
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [homepageColor,primaryColor],
        //       begin: Alignment.topCenter,  // Horizontal gradient starts from left
        //       end: Alignment.bottomCenter,
        //     ),
        //   ),
        // ),
        // actions: [
        //   // Container(
        //   //   margin: EdgeInsets.only(right: 10),
        //   //   decoration: BoxDecoration(
        //   //     color: Colors.white.withOpacity(0.2),
        //   //     shape: BoxShape.circle,
        //   //   ),
        //   //   child: IconButton(
        //   //     icon: Icon(Icons.search, color: Colors.white),
        //   //     onPressed: () {
        //   //       // Future search functionality
        //   //     },
        //   //   ),
        //   // ),
        // ],
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        // ),
      ),

      body: teachersList.isEmpty? Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      )


      :ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: teachersList.length,
        itemBuilder: (context, index) {
          return TeacherCard(teacher: teachersList[index],);
        },
      ),
    );
  }
}


class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;

  TeacherCard({required this.teacher});

  Color getStatusColor(String status) {
    switch (status) {
      case "Online":
        return Colors.green;
      case "Offline":
        return Colors.red;
      case "Busy":
        return Colors.orange.shade500;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: (){

          },
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
                          teacher['picture_data'].toString(),
                          width: 60.sp,
                          height: 60.sp,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/teacher_user.jpg', // Ensure this image exists in your assets folder
                              width: 60.sp,
                              height: 60.sp,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  teacher['name'].toString(),
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 5.sp,),
                                Container(
                                  width: 10.sp,
                                  height: 10.sp,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                    // color: getStatusColor(teacher.status),
                                    border: Border.all(color: Colors.white, width: 2.sp),
                                  ),
                                ),
                                Text(
                                  ' Online',
                                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold,color: Colors.green, ),
                                ),

                              ],
                            ),
                            // SizedBox(height: 5),
                            // Text(
                            //   teacher['subject'].toString(),
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w600,
                            //     color: Colors.blueGrey,
                            //   ),
                            // ),
                            // SizedBox(height: 5),
                            Text(
                              teacher['qualification'].toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            SizedBox(height: 5.sp),
                            Text(
                              teacher['language'].toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            SizedBox(height: 5.sp),
                            Text(
                              teacher['bio'].toString()??'',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.blueGrey,
                              ),                          ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherProfileScreen(data: teacher),
                              ),
                            );
                          },
                          icon: Icon(Icons.account_circle, size: 15.sp, color: Colors.white),
                          label: Text("Profile", style: TextStyle(color: Colors.white ,fontSize: 11.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp), // Space between buttons
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleScreen(data: teacher),
                              ),
                            );
                          },
                          icon: Icon(Icons.schedule, size: 15.sp, color: Colors.white),
                          label: Text("Schedule", style: TextStyle(color: Colors.white,fontSize: 11.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),

                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var users = snapshot.data!.docs.where((user) {
                              return user['email'] == teacher['email'].toString(); // Filter users by email
                            }).toList();

                            if (users.isEmpty) {
                              return GestureDetector(
                                onTap: () {
                                  showCustomDialog(context);

                                },
                                child: Card(
                                  color: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child:  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.chat, size: 15.sp, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("Chat", style: TextStyle(color: Colors.white,fontSize: 11.sp)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true, // Important for nested lists
                              physics: NeverScrollableScrollPhysics(), // Prevents scrolling conflict
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                var user = users[0];
                                return GestureDetector(
                                  onTap: () {
                                    final currentUser = FirebaseAuth.instance.currentUser;
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Icon(Icons.chat, size: 15.sp, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text("Chat", style: TextStyle(color: Colors.white,fontSize: 11.sp)),
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
                ],
              ),


              Positioned(
                top: 0,
                right:0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star,
                          color:Colors.amber,
                          size: 12.sp),
                      SizedBox(width: 3),
                      Text(
                        // teacher.rating.toString(),
                        teacher['avg_rating'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
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
                  "Teacher Not Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "No teachers are available for chat at the moment. Please try again later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
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

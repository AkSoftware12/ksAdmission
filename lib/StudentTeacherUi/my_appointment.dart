import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../Utils/app_colors.dart';


class HistoryAppointmentScreen extends StatefulWidget {
  const HistoryAppointmentScreen({super.key});

  @override
  State<HistoryAppointmentScreen> createState() => _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<HistoryAppointmentScreen> {
  List<dynamic> bookingList = [];


  @override
  void initState() {
    super.initState();
    hitBookingList();
  }


  Future<void> hitBookingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse("${getBooking}"),
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

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: Column(
          children: [
            AppBar(
              elevation: 4,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "My Appointment",
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
                    colors: [homepageColor,primaryColor],
                    begin: Alignment.topCenter,  // Horizontal gradient starts from left
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              actions: [

              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
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
      body: bookingList.isEmpty? Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ):



      ListView.builder(
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
class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> booking;


  AppointmentCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                        booking['teacher']['picture_data'].toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/teacher_user.jpg', // Ensure this image exists in your assets folder
                            width: 100,
                            height: 100,
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
                            booking['teacher']['name'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            booking['teacher']['qualification'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            booking['teacher']['language'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            booking['teacher']['bio'].toString()??'',
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
                    // appointment.isOnline
                    //     ? Text(
                    //   "Online",
                    //   style: TextStyle(
                    //     color: Colors.green,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // )
                    //     : Text(
                    //   "At Clinic",
                    //   style: TextStyle(
                    //     color: Colors.blue,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(booking['slot']['date'].toString(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(booking['slot']['start_time'].toString(),),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(booking['slot']['start_time'].toString(),),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              booking['status_text'].toString() == "Pending"
                    ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "This Appointment is Pending...",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                )
                    : booking['status_text'].toString() == "Cancelled"
                    ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "This Appointment is Cancelled",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  child: Text("Complete Appointment"),
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
                        size: 15),
                    SizedBox(width: 3),
                    Text(
                      // teacher.rating.toString(),
                      '4.7',
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
    );
  }
}

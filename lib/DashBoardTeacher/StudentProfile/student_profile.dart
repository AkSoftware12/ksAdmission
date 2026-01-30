import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/Profile/update_profile.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../HexColorCode/HexColor.dart';
import '../../HomePage/home_page.dart';
import '../../Utils/image.dart';
import '../../Utils/string.dart';
import '../../WebView/webview.dart';
import '../../baseurl/baseurl.dart';



class StudentProfileScreen extends StatefulWidget {
  final int id;
  const StudentProfileScreen({super.key,  required this.id});

  @override
  State<StudentProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double userAllPerformance = 0.0;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';
  double value = 80;
  List<dynamic> categoryPerformance = [];



  @override
  void initState() {
    super.initState();
    fetchProfileData(widget.id);
    fetchPerformanceData(widget.id);

  }


  Future<void> fetchProfileData( int? id) async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse('$studentViewProfile$id');
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
      false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        nickname = jsonData['user']['name'].toString();
        userEmail = jsonData['user']['email'].toString();
        contact = jsonData['user']['contact'].toString();
        // address = jsonData['user']['bio'];
        photoUrl = jsonData['user']['picture_data'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> fetchPerformanceData(int id) async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse('$studentPerformanceProfile$id');
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
      false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      // final jsonData = jsonDecode(response.body);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() {
        userAllPerformance = jsonData['overall_performance'];
      });

      if (jsonData.containsKey('performance')) {
        setState(() {
          categoryPerformance = jsonData['performance'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load profile data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF010071),
              Color(0xFF0A1AFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back,
                  size: 25, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student Profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'View performance, attendance & learning progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ---------------- PROFILE CARD (Premium) ----------------
                  Card(
                    color: Colors.blue,
                    // padding: EdgeInsets.all(8.sp),
                    // decoration: BoxDecoration(
                    //   color: Colors.blue,
                    //   borderRadius: BorderRadius.circular(5.sp),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.blueAccent.withOpacity(0.18),
                    //       blurRadius: 18,
                    //       offset: const Offset(0, 10),
                    //     ),
                    //   ],
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.sp),
                            child: Container(
                              height: 78.sp,
                              width: 78.sp,
                              color: Colors.white.withOpacity(0.12),
                              child: Image.network(
                                photoUrl.toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person_rounded,
                                  size: 34.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.sp),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (nickname.isEmpty) ? "Student Name" : nickname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  (userEmail.isEmpty) ? "student@email.com" : userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                Row(
                                  children: [
                                    _chip("Profile", Icons.badge_rounded),
                                    SizedBox(width: 8.w),
                                    _chip("Progress", Icons.trending_up_rounded),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 0.h),
                  /// ---------------- PERFORMANCE ----------------
                  ///
                  Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          _sectionTitle("Performance", "Overall learning performance overview"),
                          SizedBox(height: 5.h),
                          Padding(
                            padding: EdgeInsets.all(0.sp),
                            child: Container(
                              height: 150.sp,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.sp),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.sp),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 5.sp,
                                    ),
                                    SizedBox(
                                        width: 120.sp,
                                        child: Text(AppConstants.performance,
                                          style: GoogleFonts.cabin(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.normal),
                                          ),


                                        )),


                                    SizedBox(
                                      width: 200.sp,
                                      child: SfRadialGauge(
                                        axes: <RadialAxis>[
                                          RadialAxis(
                                            minimum: 0,
                                            maximum: 100,
                                            showLabels: false,
                                            showTicks: false,
                                            axisLineStyle: AxisLineStyle(
                                              thickness: 0.3,
                                              thicknessUnit: GaugeSizeUnit.logicalPixel,
                                            ),
                                            ranges: <GaugeRange>[
                                              GaugeRange(
                                                startValue: 0,
                                                endValue: 30,
                                                color: Colors.red,
                                                label: 'Poor',
                                                startWidth: 25.sp,
                                                endWidth: 25.sp,
                                              ),
                                              GaugeRange(
                                                startValue: 30,
                                                endValue: 60,
                                                color: Colors.orange,
                                                label: 'Average',
                                                startWidth: 25.sp,
                                                endWidth: 25.sp,
                                              ),
                                              GaugeRange(
                                                startValue: 60,
                                                endValue: 80,
                                                color: Colors.lightBlue,
                                                label: 'Good',
                                                startWidth: 25.sp,
                                                endWidth: 25.sp,
                                              ),
                                              GaugeRange(
                                                startValue: 80,
                                                endValue: 100,
                                                color: Colors.green,
                                                label: 'Excellent',
                                                startWidth: 25.sp,
                                                endWidth: 25.sp,
                                              ),
                                            ],
                                            pointers: <GaugePointer>[

                                              // User performance pointer
                                              NeedlePointer(
                                                value: userAllPerformance,
                                                needleColor: Colors
                                                    .black, // Different color for user performance
                                                // You can customize the appearance further if desired
                                              ),
                                            ],
                                            annotations: <GaugeAnnotation>[
                                              GaugeAnnotation(
                                                widget: Container(
                                                  child: Text(
                                                    '${userAllPerformance} %',
                                                    style: TextStyle(fontSize: 11.sp,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                angle: 90,
                                                positionFactor: 0.5,
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
                          ),
                        ],
                      ),
                    ),
                  ),



                  /// ---------------- ACTIVITY ----------------
                  Card(
                    color: Colors.blue,
                    child: Column(
                      children: [
                        _sectionTitle("Activity", "Category-wise performance details"),
                        SizedBox(height: 8.h),
                        Padding(
                            padding: EdgeInsets.all(3.sp),
                            child: Container(
                                height: 200.sp,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.sp),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.sp),
                                  child: Container(
                                    height: 200.sp,
                                    // Set an appropriate height for the ListView
                                    child: GridView.count(
                                      physics: NeverScrollableScrollPhysics(),
                                      // Disable scrolling

                                      crossAxisCount: 2,
                                      // Number of columns
                                      crossAxisSpacing: 10.0,
                                      // Space between columns
                                      mainAxisSpacing: 10.0,
                                      childAspectRatio: 1.9,

                                      padding: EdgeInsets.all(0),
                                      children:
                                      categoryPerformance.isNotEmpty ?
                                      List.generate(
                                          categoryPerformance.length, (index) {
                                        return GestureDetector(
                                          child: Container(
                                            height: 60.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],

                                            ),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.sp),
                                                    child: categoryPerformance[index]['data'] !=
                                                        null &&
                                                        ((categoryPerformance[index]['category'] ==
                                                            'Practice' &&
                                                            categoryPerformance[index]['data']['performance'] !=
                                                                null) ||
                                                            (categoryPerformance[index]['category'] !=
                                                                'Practice' &&
                                                                categoryPerformance[index]['data']['performance'] !=
                                                                    null))
                                                        ? CircularPercentIndicator(
                                                      radius: 25.sp,
                                                      lineWidth: 8.sp,
                                                      animation: true,
                                                      percent: (categoryPerformance[index]['category'] ==
                                                          'Practice'
                                                          ? (double.tryParse(
                                                          categoryPerformance[index]['data']["performance"]
                                                              .toString()) ?? 0.0) /
                                                          100
                                                          : (double.tryParse(
                                                          categoryPerformance[index]['data']["performance"]
                                                              .toString()) ?? 0.0) /
                                                          100)
                                                          .clamp(0.0, 1.0),
                                                      center: Text(
                                                        categoryPerformance[index]['category'] ==
                                                            'Practice'
                                                            ? "${(double.tryParse(
                                                            categoryPerformance[index]['data']['performance']
                                                                .toString()) ?? 0.0)
                                                            .toStringAsFixed(1)}%"
                                                            : "${(double.tryParse(
                                                            categoryPerformance[index]['data']['performance']
                                                                .toString()) ?? 0.0)
                                                            .toStringAsFixed(1)}%",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 9.sp,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      circularStrokeCap: CircularStrokeCap
                                                          .round,
                                                      progressColor: categoryPerformance[index]['category'] ==
                                                          'Practice'
                                                          ? (double.tryParse(
                                                          categoryPerformance[index]['data']['performance']
                                                              .toString()) ?? 0.0) <
                                                          40
                                                          ? Colors.red
                                                          : (double.tryParse(
                                                          categoryPerformance[index]['data']['performance']
                                                              .toString()) ?? 0.0) <=
                                                          60
                                                          ? Colors.yellow
                                                          : Colors.green
                                                          : (double.tryParse(
                                                          categoryPerformance[index]['data']['performance']
                                                              .toString()) ?? 0.0) <
                                                          40
                                                          ? Colors.red
                                                          : (double.tryParse(
                                                          categoryPerformance[index]['data']['performance']
                                                              .toString()) ?? 0.0) <=
                                                          60
                                                          ? Colors.yellow
                                                          : Colors.green,
                                                    )
                                                        : CircularPercentIndicator(
                                                      radius: 25.sp,
                                                      lineWidth: 8.sp,
                                                      animation: true,
                                                      percent: 0.0,
                                                      center: Text(
                                                        "0.0%",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 9.sp,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      circularStrokeCap: CircularStrokeCap
                                                          .round,
                                                      progressColor: Colors.red,
                                                    ),
                                                  ),

                                                  Text(
                                                    categoryPerformance[index]['category']
                                                        .toString(),
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11.sp,
                                                          fontWeight: FontWeight
                                                              .bold),
                                                    ),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                          : List.generate(4, (index) {
                                        return Container(
                                          height: 60.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 1,
                                                offset: Offset(0, 1),
                                              ),
                                            ],

                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.all(8.sp),
                                                    child: CircularPercentIndicator(
                                                      radius: 25.sp,
                                                      lineWidth: 8.sp,
                                                      animation: true,
                                                      percent: (0 / 100)
                                                          .clamp(0.0, 1.0),
                                                      center: Text(
                                                        "${(0 < 0 ? 0 : 0)
                                                            .toStringAsFixed(1)}%",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontSize: 10.sp,
                                                            color: Colors.white),
                                                      ),
                                                      circularStrokeCap: CircularStrokeCap
                                                          .round,
                                                      progressColor: 0 < 40
                                                          ? Colors.red
                                                          : 0 >= 40 &&
                                                          0 <= 60
                                                          ? Colors.yellow
                                                          : Colors.green,
                                                    )
                                                ),

                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      ),
                                    ),
                                  ),
                                )
                            )


                        ),
                      ],
                    ),
                  )


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String sub) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding:  EdgeInsets.all(5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              sub,
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

}

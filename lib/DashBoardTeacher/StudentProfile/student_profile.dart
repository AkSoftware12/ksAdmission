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
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(59),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              elevation: 4,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "details".toUpperCase(),
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16.sp,
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                children: [

                  Container(
                    height: 120.sp,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10.sp,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.sp),
                                child: SizedBox(
                                  height: 100.sp,
                                  width: 100.sp,
                                  child: Image.network(
                                    photoUrl.toString(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Return a default image widget here
                                      return Container(
                                        color: Colors.grey,
                                        // Placeholder color
                                        // You can customize the default image as needed
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.sp,
                              ),
                              Container(
                                height: 80.sp,
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.sp, right: 8.sp),
                                        child: SizedBox(
                                          height: 20.sp,
                                          child: Text(
                                            '${nickname}',
                                            style: GoogleFonts.cabin(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.sp, right: 8.sp),
                                        child: Text(
                                          "${userEmail}",
                                          style: GoogleFonts.cabin(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Performance',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: Container(
                      height: 150.sp,
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


                  Padding(
                    padding: EdgeInsets.only(
                        top: 5.sp, right: 0.sp, left: 3.sp, bottom: 5.sp),
                    child: Row(
                      children: [
                        Text(
                          'Activity',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                                        color: primaryColor,
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
                                      color: primaryColor,
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
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../baseurl/baseurl.dart';

class QuizResultPage extends StatefulWidget {
  final int rank;
  final String score;
  final int correctquestion;
  final int totalQuestions;
  final int skipquestion;
  final int attemptQuestions;
  final String total_negative_marks;
  final int wrongquestion;
  final int total_marks;
  final String title;

  const QuizResultPage(
      {super.key,
      required this.rank,
      required this.score,
      required this.correctquestion,
      required this.totalQuestions,
      required this.title,
      required this.skipquestion,
      required this.attemptQuestions,
      required this.total_negative_marks,
      required this.wrongquestion,
      required this.total_marks});

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  List<dynamic> plan = [];

  Future<void> hitPlan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userId = preferences.getInt('user_id');
    // final response = await http.post(Uri.parse(customsubscriptions));
    final response = await http.post(
      Uri.parse(papers),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'data' is a list, update apiData accordingly
          plan = responseData['data'];
          // restBanner=responseData['data']['banner_img'];

          // await saveDataLocally(responseData['posts']);
        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // hitPlan();
  }


  List<PieChartSectionData> _buildPieChartSections() {
    final total = widget.correctquestion + widget.wrongquestion + widget.skipquestion;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: widget.correctquestion .toDouble(),
        title: '${(widget.correctquestion  / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: widget.wrongquestion.toDouble(),
        title: '${(widget.wrongquestion / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.blue.shade50,
        value: widget.skipquestion.toDouble(),
        title: '${(widget.skipquestion / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
          title:  Text(
            'Results',
            style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          actions: [
            GestureDetector(
                onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Homepage(initialIndex: 0,

                ),
              ),
            );
          }, child: Padding(
            padding:  EdgeInsets.only(right:12.sp),
            child: Icon(Icons.home,color: Colors.white,size: 23.sp,),
          )

          )
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [



           Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                height: 210.sp,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                    stops: [0, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: HexColor('#ABB7B7'),
                    width: 1.sp,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),

                child: Column(
                  children: [
                    Container(
                      height: 180.sp,

                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          centerSpaceRadius: 30.sp,
                          sectionsSpace: 2,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Card(
                              color: Colors.green, // Set the card color to green
                              elevation: 5, // Adds shadow to the card
                              child: Padding(
                                padding: EdgeInsets.all(5.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                              child: SizedBox(
                                height: 20.sp,
                                child: Center(
                                  child: Text(
                                    'Correct',
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Card(
                              color: Colors.red, // Set the card color to green
                              elevation: 5, // Adds shadow to the card
                              child: Padding(
                                padding: EdgeInsets.all(5.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                              child: SizedBox(
                                height: 20.sp,
                                child: Center(
                                  child: Text(
                                    'Wrong',
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Card(
                              color: Colors.yellow, // Set the card color to green
                              elevation: 1, // Adds shadow to the card
                              child: Padding(
                                padding: EdgeInsets.all(5.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                              child: SizedBox(
                                height: 20.sp,
                                child: Center(
                                  child: Text(
                                    'Skip Question',
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    )
                  ],
                ),
              ),
            ),
              SizedBox(
                height: 25.sp,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff16222a), Color(0xff3a6073)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: HexColor('#ABB7B7'),
                            width: 1.sp,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Your Rank',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.rank.toString(),
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  StatBox(
                                      label: 'Correct',
                                      value: widget.correctquestion.toString()),
                                  StatBox(
                                      label: 'Wrong',
                                      value: widget.wrongquestion.toString()),
                                  StatBox(
                                      label: 'Skipped',
                                      value: widget.skipquestion.toString()),
                                ],
                              ),
                              Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatBox(
                                      label: 'Attempts',
                                      value: widget.attemptQuestions.toString()),
                                  StatBox(
                                      label: 'Marks',
                                      value:
                                          '${widget.score}/${widget.total_marks}'),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

                    SizedBox(height: 20),

              Container(
                height: 40.sp,
                width: 150.sp,

                decoration: BoxDecoration(
                    color: primaryColor2,
                  borderRadius: BorderRadius.circular(10.sp)
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Homepage(initialIndex: 0,

                          ),
                        ),
                      );
                    }, child: Padding(
                  padding:  EdgeInsets.only(right:0.sp),
                  child:Center(child: Text('Back To Home')),
                )

                )
                ,
              )






            ],
          ),
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label;
  final String value;

  StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}

class SubscriptionDetail extends StatelessWidget {
  final IconData icon;
  final String title;

  SubscriptionDetail({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class CorrectIncorrectSkipped extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text('Correct', style: TextStyle(color: Colors.green)),
            Text('11'),
          ],
        ),
        Column(
          children: [
            Text('Incorrect', style: TextStyle(color: Colors.red)),
            Text('34'),
          ],
        ),
        Column(
          children: [
            Text('Skipped', style: TextStyle(color: Colors.orange)),
            Text('5'),
          ],
        ),
      ],
    );
  }
}

class QuestionAnalysisGrid extends StatelessWidget {
  final List<String> questionResults = [
    'correct', 'incorrect', 'skipped', // populate this with the result of each question
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10, // 10 per row
        childAspectRatio: 1,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        String result = questionResults[index % questionResults.length];
        Color borderColor;
        Color borderColorB;
        switch (result) {
          case 'correct':
            borderColor = Colors.green;
            borderColorB = Colors.green.shade50;
            break;
          case 'incorrect':
            borderColor = Colors.red;
            borderColorB = Colors.red.shade50;
            break;
          case 'skipped':
            borderColor = Colors.blue;
            borderColorB = Colors.blue.shade50;
            break;
          default:
            borderColor = Colors.grey;
            borderColorB = Colors.grey;
        }
        return Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: borderColorB,
            border: Border.all(color: borderColor),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('${index + 1}',style: TextStyle(color: Colors.black),)),
        );
      },
    );
  }
}

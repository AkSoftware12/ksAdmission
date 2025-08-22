import 'dart:async';
import 'dart:ffi';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../HexColorCode/HexColor.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/color_constants.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';

class UserResultsScreen extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final String type;

  const UserResultsScreen(
      {super.key,
      required this.paperId,
      required this.papername,
      required this.exmaTime,
      required this.question,
      required this.marks,
      required this.type});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<UserResultsScreen> {
  int _secondsRemaining = 0;
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;

  int correctQuestion = 0;
  int skipQuestion = 0;
  int wrongQuestion = 0;
  int totalQuestions = 0;
  int totalQuestionMarks = 0;
  int attemptQuestions = 0;
  String totalMarks = '';

  String negativeMarksPerQuestion = '';
  String totalNegativeMarks = '';

  bool _isLoading = false;

  List<dynamic> paperList = [];

  @override
  void initState() {
    super.initState();
    hitQuestionApi();
  }

  Future<void> hitQuestionApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences
        .getString('token'); // Assuming 'token' is stored in SharedPreferences

    final response = await http.get(
      Uri.parse('${getUserPaperListDetails}${widget.paperId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      setState(() {
        correctQuestion = responseData['score']['correct_question'];
        wrongQuestion = responseData['score']['wrong_question'];
        skipQuestion = responseData['score']['skip_question'];
        totalMarks = responseData['score']['score'].toString();
        totalQuestionMarks = responseData['score']['total_marks'];
        totalQuestions = responseData['score']['total_questions'];
        attemptQuestions = responseData['score']['attempt_questions'];
        negativeMarksPerQuestion =
            responseData['score']['negative_marks_per_question'];
        totalNegativeMarks = responseData['score']['total_negative_marks'];
      });

      if (responseData.containsKey('question')) {
        setState(() {
          paperList = responseData['question'];
        });
      } else {
        throw Exception('Invalid API response: Missing "question" key');
      }
    } else {
      throw Exception('Failed to load questions');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = correctQuestion + wrongQuestion + skipQuestion;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: correctQuestion.toDouble(),
        title: '${(correctQuestion)}',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: wrongQuestion.toDouble(),
        title: '${(wrongQuestion)}',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.blue.shade50,
        value: skipQuestion.toDouble(),
        title: '${(skipQuestion)}',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (paperList.isEmpty) {
      return Scaffold(
        backgroundColor: primaryColor,
        // body:Center(
        //   child: CircularProgressIndicator(
        //     color: Colors.white,
        //   ),
        // )
      );
    }
    return Material(
      color: primaryColor,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            ' ${widget.papername.toString()}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Customize text color for paper name
            ),
          ),
        ),
        body: Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${'Total Question : - '} ${totalQuestions}',
                                style: GoogleFonts.radioCanada(
                                  textStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                '${'Total Marks : - '} ${totalQuestionMarks}',
                                style: GoogleFonts.radioCanada(
                                  textStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                '${'Attempt Question : - '} ${attemptQuestions}',
                                style: GoogleFonts.radioCanada(
                                  textStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                '${'Neg.. Marks Per Question : - '} ${negativeMarksPerQuestion}',
                                style: GoogleFonts.radioCanada(
                                  textStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                '${'Total Negative Marks : - '} ${totalNegativeMarks}',
                                style: GoogleFonts.radioCanada(
                                  textStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Container(
                              height: 160.sp,
                              width: 150.sp,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sections: _buildPieChartSections(),
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 2,
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'score',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '${totalMarks}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Card(
                              color: Colors.green,
                              // Set the card color to green
                              elevation: 5,
                              // Adds shadow to the card
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
                              color: Colors.blue.shade50,
                              // Set the card color to green
                              elevation: 1,
                              // Adds shadow to the card
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
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: paperList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 25.sp),
                    child: Card(
                      elevation: 15,
                      color: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: HexColor('#e8eff5'),
                                border: Border(
                                  top: BorderSide(
                                    color: HexColor('#4d6b53'),
                                    // Color of the top border
                                    width: 2.sp, // Width of the top border
                                  ),
                                  bottom: BorderSide(
                                    color: HexColor('#4d6b53'),
                                    // Color of the bottom border
                                    width: 2.sp, // Width of the bottom border
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'Question-'}${index + 1}:',
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.sp,
                                    ),
                                    Text(
                                      paperList[index]['question'].toString(),
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Ensure options are in List<String> format
                            ...(paperList[index]['options'] as List<dynamic>)
                                .asMap()
                                .entries
                                .map((entry) {
                              int optionIndex = entry.key + 1;

                              String optionText = entry.value['text']
                                  .toString(); // Ensure option is a String

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${optionIndex}.  ${optionText}',
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // RadioListTile<int>(
                                  //   title: Text("${optionText}"),
                                  //   // Use optionText for display
                                  //   value: optionIndex,
                                  //   // Use the option index as the value
                                  //   groupValue: null,
                                  //   // Get the selected option for this question
                                  //   onChanged: (value) {
                                  //     setState(() {});
                                  //   },
                                  //   activeColor: greenColorQ,
                                  // ),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1.sp,
                                  ),
                                ],
                              );
                            }).toList(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp, left: 5.sp),
                                      child: Container(
                                        height: 20.sp,
                                        color: Colors.green,
                                        child: Center(
                                            child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.sp, right: 8.sp),
                                          child: Text(
                                            '${paperList[index]['answer'].toString()}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp),
                                      child: SizedBox(
                                        height: 20.sp,
                                        child: Center(
                                          child: Text(
                                            'Correct Answer',
                                            style: GoogleFonts.cabin(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10.sp,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp, left: 5.sp),
                                      child: Container(
                                        height: 20.sp,
                                        width: 20.sp,
                                        color: Colors.grey,
                                        child: Center(
                                            child: Text(
                                          '${paperList[index]['selected_answer'].toString()}',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.sp, right: 8.sp),
                                      child: SizedBox(
                                        height: 20.sp,
                                        child: Center(
                                          child: Text(
                                            'Select Answer',
                                            style: GoogleFonts.cabin(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10.sp,
                                                  fontWeight:
                                                      FontWeight.normal),
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
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

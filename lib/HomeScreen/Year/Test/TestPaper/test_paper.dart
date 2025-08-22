import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../HexColorCode/HexColor.dart';
import '../../../../QuizTestScreen/quiztest.dart';
import '../../../../Utils/app_colors.dart';
import '../../../../Utils/image.dart';
import '../../../../Utils/string.dart';
import '../../../../Utils/textSize.dart';

class TestPaperModel {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String image;

  TestPaperModel({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.image,
  });
}

class TestPaperList extends StatefulWidget {
  final String url;
  final String image;
  final String title;
  final String type;

  const TestPaperList({
    super.key,
    required this.url,
    required this.image,
    required this.title,
    required this.type,
  });

  @override
  State<TestPaperList> createState() => _TestPaperListState();
}

class _TestPaperListState extends State<TestPaperList> {
  bool isLoading = false;

  final List<TestPaperModel> competition = [
    TestPaperModel(
      title: 'NEET',
      subtitle: 'subtitle',
      image: 'assets/neet.png',
      backgroundColor: primaryColor,
    ),
    TestPaperModel(
      title: 'SSC',
      subtitle: 'subtitle',
      image: 'assets/ssc.jpg',
      backgroundColor: primaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 210.sp,
            color: HexColor('#e1e4f3'),
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.sp),
                    Column(
                      children: [
                        Center(
                          child: Container(
                            height: 70.sp,
                            width: 70.sp,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40.sp),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Image.asset(logo),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        Center(
                          child: Text(
                            widget.title,
                            maxLines: 5,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: competition.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        paperId: 5,
                        papername: '',
                        exmaTime: 5,
                        question: '',
                        marks: '',
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      0,
                    ), // Removes rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 20.sp,
                                  width: 20.sp,
                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(15.sp),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.sp),
                                    child: Image.asset(logo),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 5.sp,
                                    right: 0.sp,
                                  ),
                                  child: Text(
                                    competition[index].title.toString(),
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 20.sp,
                              width: 20.sp,
                              decoration: BoxDecoration(
                                color: Colors.orange,

                                borderRadius: BorderRadius.circular(15.sp),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2.sp),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.sp),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                elevation: 5,
                                color: HexColor('#f0df9a'),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline_sharp,
                                        color: Colors.black,
                                        size: 15.sp,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 5.sp,
                                          right: 5.sp,
                                        ),
                                        child: Text(
                                          'Resume',
                                          style: GoogleFonts.cabin(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.sp),
                                  color: HexColor('#f2f2f2'),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        color: Colors.black,
                                        size: 15.sp,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 5.sp,
                                          right: 0.sp,
                                        ),
                                        child: Text(
                                          '${'Attempts'}${' - '}${'2000'}',
                                          style: GoogleFonts.cabin(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

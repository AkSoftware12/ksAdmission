import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:realestate/HomeScreen/Year/SubjectScreen/webView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../HomePage/home_page.dart';
import '../../../Plan/plan.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/textSize.dart';
import '../../../YoutubPlayer/youtube_players.dart';
import '../../../baseurl/baseurl.dart';

class ChapterScreen extends StatefulWidget {
  final String title;
  final String catName;
  final int chapterId;
  final String planstatus;
  final String advance;

  const ChapterScreen({
    super.key,
    required this.title,
    required this.chapterId,
    required this.catName,
    required this.planstatus,
    required this.advance,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  List<dynamic> chapter = [];
  bool isLoading = false; // Add this for the loading state

  @override
  void initState() {
    super.initState();
    hitQuestionApi();
  }

  Future<void> hitQuestionApi() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${chapters}${widget.chapterId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'].toString();

      print(responseData);

      if (responseData.containsKey('chapters')) {
        setState(() {
          chapter = responseData['chapters'];
          isDownloadingList = List<bool>.filled(chapter.length, false);
          downloadProgressList = List<double>.filled(chapter.length, 0.0);
          isLoading = false; // Stop progress bar
        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    } else {
      setState(() {
        isLoading = false; // Stop progress bar on exception
      });
    }
  }

  void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/7269/7269950.png',
                  // Replace with your subscription image
                  height: 100,
                ),
                SizedBox(height: 15),
                Text(
                  "Your Daily Limit Has Been Reached!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "To solve more questions, you can subscribe to our plan or wait for the next day.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanScreen(appBar: 'appBar'),
                          ),
                        );
                      },
                      child: Text(
                        "Subscribe Now",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back to Home",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Homepage(initialIndex: 0),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 12.sp),
                  child: Icon(Icons.home, size: 25.sp),
                ),
              ),
            ],
          ),
        ],
      ),

      body: isLoading
          ? WhiteCircularProgressWidget()
          : Column(
              children: [
                chapter.isEmpty
                    ? Center(child: DataNotFoundWidget())
                    : Flexible(
                        child: ListView.builder(
                          itemCount: chapter.length,
                          itemBuilder: (context, index) {
                            bool isLocked;
                            if (widget.planstatus == 'locked' &&
                                widget.advance == '') {
                              isLocked = widget.planstatus == 'locked'
                                  ? index != 0
                                  : widget.planstatus == 'unlocked';
                            } else if (widget.advance == '2' &&
                                widget.planstatus == 'locked') {
                              isLocked = widget.planstatus == '2'
                                  ? false
                                  : true;
                            } else {
                              isLocked =
                                  false; // Default value if planstatus is neither 'locked' nor 'unlocked'
                            }
                            return Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: GestureDetector(
                                onTap: () {},
                                child: Stack(
                                  children: [
                                    (isLocked)
                                        ? GestureDetector(
                                            onTap: () {
                                              showUpgradeDialog(context);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              // height: 90.sp,
                                              decoration: BoxDecoration(
                                                color: Colors.blueGrey,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 130.sp,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        12.sp,
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${index + 1}${'. '}${chapter[index]['name'].toString()}',
                                                            style: GoogleFonts.roboto(
                                                              textStyle: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center, // Center the text horizontally
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.0,
                                                              ),
                                                          color: Colors.black12,
                                                        ),
                                                        height: 70.sp,
                                                        width: 2.sp,
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      10.sp,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(width: 30.sp),
                                                        SizedBox(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  right: 0.0,
                                                                ),
                                                            child:
                                                                isDownloadingList[index]
                                                                ? Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      CircularProgressIndicator(
                                                                        value:
                                                                            downloadProgressList[index],
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      Text(
                                                                        '${(downloadProgressList[index] * 100).toStringAsFixed(0)}%',
                                                                        style: GoogleFonts.poppins(
                                                                          textStyle: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                TextSizes.textsmall,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : GestureDetector(
                                                                    onTap:
                                                                        () async {},
                                                                    child: Column(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .play_circle_outline_sharp,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              24.sp,
                                                                        ),
                                                                        Text(
                                                                          'Video',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                14.sp,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                            // You can handle the else case here as per your requirement
                                                          ),
                                                        ),
                                                        SizedBox(width: 40.sp),

                                                        GestureDetector(
                                                          onTap: () {},

                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons.more,
                                                                color: Colors
                                                                    .white,
                                                                size: 24.sp,
                                                              ),
                                                              Text(
                                                                'View More',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.sp,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: double.infinity,
                                            // height: 90.sp,
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .blueGrey, // default color
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 130.sp,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      12.sp,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${index + 1}${'. '}${chapter[index]['name'].toString()}',
                                                          style: GoogleFonts.roboto(
                                                            textStyle:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          textAlign: TextAlign
                                                              .center, // Center the text horizontally
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.0,
                                                            ),
                                                        color: Colors.black12,
                                                      ),
                                                      height: 70.sp,
                                                      width: 2.sp,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    10.sp,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(width: 30.sp),
                                                      SizedBox(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                right: 0.0,
                                                              ),
                                                          child:
                                                              isDownloadingList[index]
                                                              ? Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    CircularProgressIndicator(
                                                                      value:
                                                                          downloadProgressList[index],
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    Text(
                                                                      '${(downloadProgressList[index] * 100).toStringAsFixed(0)}%',
                                                                      style: GoogleFonts.poppins(
                                                                        textStyle: TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              TextSizes.textsmall,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () async {
                                                                    if (chapter[index]['youtube_link'] ==
                                                                        null) {
                                                                      Fluttertoast.showToast(
                                                                        msg:
                                                                            "Link not available",
                                                                        toastLength:
                                                                            Toast.LENGTH_LONG,
                                                                        // or Toast.LENGTH_LONG
                                                                        gravity:
                                                                            ToastGravity.BOTTOM,
                                                                        // Position (TOP, BOTTOM, CENTER)
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        // Duration for iOS and Web
                                                                        backgroundColor:
                                                                            Colors.black,
                                                                        textColor:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            16.0,
                                                                      );
                                                                    } else {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) => VideoPlayer(
                                                                                url: chapter[index]['youtube_link'].toString(),
                                                                                title: chapter[index]['name'].toString(),
                                                                                videoId: null,
                                                                                videoStatus: widget.planstatus,
                                                                              ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .play_circle_outline_sharp,
                                                                        color: Colors
                                                                            .white,
                                                                        size: 24
                                                                            .sp,
                                                                      ),
                                                                      Text(
                                                                        'Video',
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14.sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                          // You can handle the else case here as per your requirement
                                                        ),
                                                      ),
                                                      SizedBox(width: 40.sp),

                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => PdfViewerPage(
                                                                url: chapter[index]['notes_url']
                                                                    .toString(),
                                                                title: chapter[index]['name']
                                                                    .toString(),
                                                                category:
                                                                    '${widget.catName}',
                                                                Subject:
                                                                    '${widget.title}',
                                                              ),
                                                            ),
                                                          );
                                                        },

                                                        child: Column(
                                                          children: [
                                                            Icon(
                                                              Icons.more,
                                                              color:
                                                                  Colors.white,
                                                              size: 24.sp,
                                                            ),
                                                            Text(
                                                              'View More',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    if (isLocked)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            // borderRadius: BorderRadius.circular(10.sp)
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8.sp),
                                              topLeft: Radius.circular(8.sp),
                                              topRight: Radius.circular(8.sp),
                                              bottomRight: Radius.circular(
                                                0.sp,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(2.sp),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 12.sp,
                                                right: 12.sp,
                                              ),
                                              child: Icon(
                                                Icons.lock,
                                                size: 16.sp,
                                                color: Colors.black,
                                                // color: Colors.redAccent.shade200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}

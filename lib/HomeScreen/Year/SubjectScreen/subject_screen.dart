import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realestate/HomeScreen/Year/SubjectScreen/webView.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../Plan/plan.dart';
import '../../../PracticeQuestionScreen/practice_question_subject.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/textSize.dart';
import '../../../YoutubPlayer/youtube_players.dart';
import '../../../baseurl/baseurl.dart';
import 'PdfScreen/pdf_list_advance.dart';
import 'chapter_screen.dart';

class SubjectScreen extends StatefulWidget {
  final String title;
  final String catName;
  final int masterSubjectId;
  final String planstatus;

  const SubjectScreen({
    super.key,
    required this.title,
    required this.masterSubjectId,
    required this.catName,
    required this.planstatus,
  });

  @override
  State<SubjectScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<SubjectScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  bool isLoading = false; // Add this for the loading state

  List<dynamic> subjects = [];

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
      Uri.parse('${masterSubject}${widget.masterSubjectId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

      print(responseData);

      if (responseData.containsKey('data')) {
        setState(() {
          subjects = responseData['data'];
          isDownloadingList = List<bool>.filled(subjects.length, false);
          downloadProgressList = List<double>.filled(subjects.length, 0.0);
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

  Future<void> downloadAndOpenPDF(
    String url,
    String filename,
    int index,
  ) async {
    setState(() {
      isDownloadingList[index] = true;
      downloadProgressList[index] = 0.0;
    });

    try {
      Dio dio = Dio();

      // Request permission to write to external storage
      PermissionStatus status = await Permission.manageExternalStorage
          .request();

      if (status.isGranted) {
        // Get the directory to store the downloaded file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> folders = directory!.path.split("/");
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Download";
          directory = Directory(newPath);
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        String filePath = '${directory.path}/$filename.pdf';

        // Start the download
        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgressList[index] = received / total;
              });
            }
          },
        );

        setState(() {
          downloadProgressList[index] = 1.0; // Ensure 100% completion
          isDownloadingList[index] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed: $filePath')),
        );

        // Open the downloaded PDF file
        OpenFilex.open(filePath);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      }
    } catch (e) {
      setState(() {
        isDownloadingList[index] = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
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
                        Navigator.pushReplacement(
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
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [],
      ),
      body: isLoading
          ? WhiteCircularProgressWidget()
          : Column(
              children: [
                subjects.isEmpty
                    ? Center(child: DataNotFoundWidget())
                    : Flexible(
                        child: ListView.builder(
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(0.sp),
                              child: GestureDetector(
                                onTap: () {
                                  if (subjects[index]['advance_status'] == 2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterScreen(
                                          title: subjects[index]['name']
                                              .toString(),
                                          chapterId: subjects[index]['id'],
                                          catName: widget.catName,
                                          planstatus: '${widget.planstatus}',
                                          advance: '2',
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterScreen(
                                          title: subjects[index]['name']
                                              .toString(),
                                          chapterId: subjects[index]['id'],
                                          catName: '${widget.catName}',
                                          planstatus: '${widget.planstatus}',
                                          advance: '',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  children: [
                                    if (index == 0)
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PdfViewerPage(
                                                          url:
                                                              '${subjects[0]['syllabus_url'].toString()}',
                                                          title: widget.title,
                                                          category: '',
                                                          Subject: '',
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                color: Colors.blueGrey,
                                                child: Padding(
                                                  padding: EdgeInsets.all(3.sp),
                                                  child: Center(
                                                    child: Text(
                                                      'Syllabus',
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: TextSizes
                                                              .textmedium,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                if (widget.planstatus ==
                                                    'locked') {
                                                  showUpgradeDialog(context);
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PracticeQuestionSubjectScreen(
                                                            paperId: 2,
                                                            papername: '',
                                                            exmaTime: 150,
                                                            question: '',
                                                            marks: '',
                                                            sunjectId:
                                                                subjects[index]['id'],
                                                          ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Card(
                                                color: Colors.blueGrey,
                                                child: Padding(
                                                  padding: EdgeInsets.all(3.sp),
                                                  child: Center(
                                                    child: Text(
                                                      'Practice  24/7',
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: TextSizes
                                                              .textmedium,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Padding(
                                      padding: EdgeInsets.all(3.sp),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,

                                            decoration: BoxDecoration(
                                              // color: Colors.blueGrey,
                                              // color: greenColorQ.withOpacity(0.9),
                                              color: Colors.blueGrey,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 100.sp,
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
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              height: 50.sp,
                                                              width: 50.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          40.0,
                                                                        ),
                                                                  ),
                                                              child: SizedBox(
                                                                height: 30.sp,
                                                                width: 30.sp,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        5.0,
                                                                      ),
                                                                  child: Image.network(
                                                                    subjects[index]['image_url']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          subjects[index]['name']
                                                              .toString(),
                                                          style: GoogleFonts.roboto(
                                                            textStyle:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          textAlign: TextAlign
                                                              .center, // Center the text horizontally
                                                        ),
                                                        if (subjects[index]['advance_status'] ==
                                                            1)
                                                          Text(
                                                            '${'Chapter '}${'(${subjects[index]['chapter_count'].toString()})'}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10.sp,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    10.sp,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (userPlanStatus ==
                                                              'Inactive') {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    const PlanScreen(
                                                                      appBar:
                                                                          '',
                                                                    ),
                                                              ),
                                                            );
                                                          } else {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => ChapterScreen(
                                                                  title: subjects[index]['name']
                                                                      .toString(),
                                                                  chapterId:
                                                                      subjects[index]['id'],
                                                                  catName:
                                                                      '${widget.catName}',
                                                                  planstatus:
                                                                      '${widget.planstatus}',
                                                                  advance: '',
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    right: 8.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_ios_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 24.sp,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   'View More',
                                                            //   style: TextStyle(
                                                            //       color: Colors
                                                            //           .white,
                                                            //       fontSize:
                                                            //           10.sp),
                                                            // )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          if (userPlanStatus == 'Inactive')
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  // borderRadius: BorderRadius.circular(10.sp)
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                              2.sp,
                                                            ),
                                                        topLeft:
                                                            Radius.circular(
                                                              2.sp,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              2.sp,
                                                            ),
                                                        bottomRight:
                                                            Radius.circular(
                                                              0.sp,
                                                            ),
                                                      ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(2.sp),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 0.sp,
                                                      right: 0.sp,
                                                    ),
                                                    child: Icon(
                                                      Icons.lock,
                                                      size: 16.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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

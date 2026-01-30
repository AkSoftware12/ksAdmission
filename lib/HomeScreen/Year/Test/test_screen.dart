import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../InstructionsPage/Instructions.dart';
import '../../../Plan/plan.dart';
import '../../../QuizTestScreen/quiztest_mock.dart';
import '../../../Toast/custom_toast.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/image.dart';
import '../../../baseurl/baseurl.dart';

class TestScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final int? stateId;
  final String planstatus;

  const TestScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.stateId,
    required this.planstatus,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  bool isLoading = false;

  List<dynamic> testSeries = [];


  final List<Color> colorList = [primaryColor, Colors.white];

  @override
  void initState() {
    super.initState();
    fetchPaperData(widget.categoryId, widget.stateId);
  }

  Future<void> fetchPaperData(int categoryId, int? stateId) async {
    setState(() {
      isLoading = true; // Show progress bar
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse(papers),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category': widget.categoryId,
        'subcategory': 14,
        'state': widget.stateId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          testSeries = responseData['data'];
          isDownloadingList = List<bool>.filled(testSeries.length, false);
          downloadProgressList = List<double>.filled(testSeries.length, 0.0);
          isLoading = false; // Stop progress bar
        });
      } else {
        // Print the entire response for debugging
        print('Invalid API response: Missing "properties" key');
        print(responseData);
        throw Exception('Invalid API response: Missing "properties" key');
      }
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
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
      body: isLoading
          ? WhiteCircularProgressWidget()
          : SingleChildScrollView(
              child: Column(
                children: [
                  testSeries.isEmpty
                      ? Center(child: DataNotFoundWidget())
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          // Disable scrolling
                          crossAxisCount: 2,
                          childAspectRatio: .9,
                          children: List.generate(
                            testSeries.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (testSeries[index]['test_status'] ==
                                            'Submited') {
                                          CustomToast.show(
                                            context,
                                            "Test Series Already Submitted ",
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InstructionPage(
                                                paperId:
                                                    testSeries[index]['id'],
                                                papername:
                                                    testSeries[index]['paper_name']
                                                        .toString(),
                                                exmaTime:
                                                    testSeries[index]['time_limit'] !=
                                                        null
                                                    ? testSeries[index]['time_limit']
                                                          as int
                                                    : 0,
                                                // Providing default value for null
                                                question:
                                                    testSeries[index]['question_count']
                                                        .toString(),
                                                marks:
                                                    testSeries[index]['total_marks']
                                                        .toString(),
                                                type: 'testSeries',
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: colorList,
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              // color: competition[index].backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(8.sp),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 30.sp,
                                                    width: 30.sp,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15.sp,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        2.sp,
                                                      ),
                                                      child: Image.asset(logo),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 8.sp,
                                                      right: 8.sp,
                                                    ),
                                                    child: Text(
                                                      testSeries[index]['paper_name']
                                                          .toString(),
                                                      style: GoogleFonts.cabin(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                // borderRadius: BorderRadius.circular(10.sp)
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    10.sp,
                                                  ),
                                                  topLeft: Radius.circular(
                                                    10.sp,
                                                  ),
                                                  topRight: Radius.circular(
                                                    10.sp,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    0.sp,
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.sp),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 8.sp,
                                                    right: 8.sp,
                                                  ),
                                                  child: Text(
                                                    'Test Series',
                                                    style:
                                                        GoogleFonts.radioCanada(
                                                          textStyle: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: double.infinity,
                                              height: 100.sp,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                // borderRadius: BorderRadius.circular(10.sp)
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    10.sp,
                                                  ),
                                                  // topLeft: Radius.circular(10.sp),
                                                  // topRight: Radius.circular(10.sp),
                                                  bottomRight: Radius.circular(
                                                    10.sp,
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.sp),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8.sp,
                                                                right: 8.sp,
                                                              ),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  '${''}${'Total Question :- '}${testSeries[index]['question_count'].toString()}',
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8.sp,
                                                                right: 8.sp,
                                                              ),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  '${''}${'Total marks :- '}${testSeries[index]['total_marks'].toString()}',
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8.sp,
                                                                right: 8.sp,
                                                              ),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  '${''}${'Marks Per Question :- '}${testSeries[index]['marks_per_question'].toString()}',
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8.sp,
                                                                right: 8.sp,
                                                              ),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  '${''}${'Negative Marks Per Question :- '}${testSeries[index]['negative_marks'].toString()}',
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 8.sp,
                                                                right: 8.sp,
                                                              ),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  '${''}${'Time Limit :- '}${testSeries[index]['time_limit'].toString()}',
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
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
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.sp),
                                              child: Container(
                                                width: double.infinity,
                                                height: 30.sp,
                                                decoration: BoxDecoration(
                                                  color:
                                                      (testSeries[index]['test_status'] ==
                                                          'Submited')
                                                      ? Colors.blueGrey
                                                      : primaryColor,
                                                  // borderRadius: BorderRadius.circular(10.sp)
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                              10.sp,
                                                            ),
                                                        topLeft:
                                                            Radius.circular(
                                                              10.sp,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              10.sp,
                                                            ),
                                                        bottomRight:
                                                            Radius.circular(
                                                              10.sp,
                                                            ),
                                                      ),
                                                ),
                                                child: Center(
                                                  child:
                                                      (testSeries[index]['test_status'] ==
                                                          'Submited')
                                                      ? Text(
                                                          testSeries[index]['test_status']
                                                              .toString(),
                                                          style: GoogleFonts.radioCanada(
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                        )
                                                      : Text(
                                                          testSeries[index]['test_status']
                                                              .toString(),
                                                          style: GoogleFonts.radioCanada(
                                                            textStyle: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (userPlanStatus == 'Inactive' &&
                                        index != 0)
                                      // if (index != 0 && widget.planstatus == 'locked')
                                      GestureDetector(
                                        onTap: () {
                                          showUpgradeDialog(context);
                                        },

                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),

                                          child: Center(
                                            child: Icon(
                                              Icons.lock,
                                              color: primaryColor,
                                              size: 40.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

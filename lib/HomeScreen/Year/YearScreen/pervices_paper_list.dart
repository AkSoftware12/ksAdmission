import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../QuizTestScreen/quiztest.dart';
import '../../../../Utils/app_colors.dart';
import '../../../../Utils/image.dart';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../Download/db.dart';
import '../../../InstructionsPage/Instructions.dart';
import '../../../Plan/plan.dart';
import '../../../Utils/textSize.dart';
import '../../../baseurl/baseurl.dart';
import '../SubjectScreen/webView.dart';

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

class PrvicesPaperList extends StatefulWidget {
  final int yesrId;
  final int categoryId;
  final int subcategoryId;
  final String year;

  const PrvicesPaperList({
    super.key,
    required this.yesrId,
    required this.year,
    required this.categoryId,
    required this.subcategoryId,
  });

  @override
  State<PrvicesPaperList> createState() => _TestPaperListState();
}

class _TestPaperListState extends State<PrvicesPaperList> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  bool isLoading = false;
  List<dynamic> paper = [];
  String userPlanStatus = '';

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
  void initState() {
    super.initState();
    fetchPaperData(widget.categoryId, widget.yesrId);
  }

  Future<void> fetchPaperData(int categoryId, int yearId) async {
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
        'category': categoryId,
        'year': yearId,
        'subcategory': widget.subcategoryId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          paper = responseData['data'];
          isDownloadingList = List<bool>.filled(paper.length, false);
          downloadProgressList = List<double>.filled(paper.length, 0.0);

          isLoading = false; // Stop progress bar
          print(paper);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${widget.year}',
          maxLines: 5,
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: isLoading
          ? WhiteCircularProgressWidget()
          : Column(
              children: [
                Container(
                  child: paper.isEmpty
                      ? DataNotFoundWidget()
                      : Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: paper.length,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {},
                                child: Card(
                                  elevation: 5,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // Removes rounded corners
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 0.sp),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 5.sp,
                                                  right: 0.sp,
                                                ),
                                                child: Text(
                                                  paper[index]['paper_name']
                                                      .toString(),
                                                  style: GoogleFonts.cabin(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                height: 25.sp,
                                                width: 30.sp,
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.sp),
                                                  child: Image.asset(logo),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  5.0,
                                                ),
                                                child: Text(
                                                  '${paper[index]['language'].toString()}',
                                                  style: GoogleFonts.cabin(
                                                    textStyle: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PdfViewerPage(
                                                            url:
                                                                paper[index]['picture_urls']
                                                                    .toString(),
                                                            title:
                                                                paper[index]['paper_name']
                                                                    .toString(),
                                                            category: '',
                                                            Subject: '',
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 30.sp,
                                                  width: 100.sp,
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                5.sp,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                5.sp,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                5.sp,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                5.sp,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2.0,
                                                          ),
                                                      child: Text(
                                                        'View',
                                                        style: GoogleFonts.cabin(
                                                          textStyle: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

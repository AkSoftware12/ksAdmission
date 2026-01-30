import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realestate/HomeScreen/Year/SubjectScreen/webView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import '../../../Plan/plan.dart';
import '../../../Syllabus/syllabus_screen.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/textSize.dart';
import '../../../baseurl/baseurl.dart';
import '../../home_screen.dart';
import 'chapter_screen.dart';
import 'description.dart';
import 'dart:io';

class TopicScreen extends StatefulWidget {
  final String title;
  final int topicId;

  const TopicScreen({super.key, required this.title, required this.topicId});

  @override
  State<TopicScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<TopicScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  List<dynamic> topic = [];

  @override
  void initState() {
    super.initState();
    hitQuestionApi();
  }

  Future<void> hitQuestionApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${topics}${widget.topicId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('topics')) {
        setState(() {
          topic = responseData['topics'];
          isDownloadingList = List<bool>.filled(topic.length, false);
          downloadProgressList = List<double>.filled(topic.length, 0.0);
        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> _launchYoutubeVideo() async {
    const url = 'https://www.youtube.com/live/7wi297WObFE?si=LzJOKw3wLgr0z5bz';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        automaticallyImplyLeading: true,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),

      body: ListView.builder(
        itemCount: topic.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(5.sp),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(
                      url: topic[index]['picture_urls'].toString(),
                      title: topic[index]['topic_name'].toString(),
                      category: '${widget.title}',
                      Subject: '',
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    // height: 90.sp,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 130.sp,
                          child: Padding(
                            padding: EdgeInsets.all(12.sp),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}${'. '}${topic[index]['topic_name'].toString()}',

                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
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
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black12,
                              ),
                              height: 70.sp,
                              width: 2.sp,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 0.sp),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  child: isDownloadingList[index]
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value:
                                                  downloadProgressList[index],
                                              color: Colors.black,
                                            ),
                                            Text(
                                              '${(downloadProgressList[index] * 100).toStringAsFixed(0)}%',
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: TextSizes.textsmall,
                                                  fontWeight: FontWeight.normal,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            if (topic[index]['notes_url'] ==
                                                null) {
                                              Fluttertoast.showToast(
                                                msg: "PDF NOT FOUND",
                                                toastLength: Toast.LENGTH_SHORT,
                                                // or Toast.LENGTH_LONG
                                                gravity: ToastGravity.BOTTOM,
                                                // Position (TOP, BOTTOM, CENTER)
                                                timeInSecForIosWeb: 1,
                                                // Duration for iOS and Web
                                                backgroundColor: Colors.black,
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                            } else {
                                              if (!isDownloadingList[index]) {
                                                downloadAndOpenPDF(
                                                  topic[index]['notes_url']
                                                      .toString(),
                                                  topic[index]['name']
                                                      .toString(),
                                                  index,
                                                );
                                              }
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                color: Colors.white,
                                                size: 18.sp,
                                              ),
                                              Text(
                                                'Download',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                  // You can handle the else case here as per your requirement
                                ),
                              ),
                              SizedBox(width: 10.sp),

                              GestureDetector(
                                onTap: () async {
                                  await _launchYoutubeVideo();
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline_sharp,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    Text(
                                      'Video ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SyllabusScreen(catId: 5),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.content_copy_outlined,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    Text(
                                      'Syllabus ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 10.sp),
                              GestureDetector(
                                onTap: () {
                                  if (userPlanStatus == 'Inactive') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlanScreen(appBar: ''),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterScreen(
                                          title: topic[index]['name']
                                              .toString(),
                                          chapterId: topic[index]['id'],
                                          catName: '',
                                          planstatus: '',
                                          advance: '',
                                        ),
                                      ),
                                    );
                                  }
                                },

                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.more,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    Text(
                                      'View More',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(10.sp)
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.sp),
                          topLeft: Radius.circular(10.sp),
                          topRight: Radius.circular(10.sp),
                          bottomRight: Radius.circular(0.sp),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.sp),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.sp, right: 8.sp),
                          child: Text(
                            widget.title,
                            style: GoogleFonts.radioCanada(
                              textStyle: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (userPlanStatus == 'Inactive')
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          // borderRadius: BorderRadius.circular(10.sp)
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.sp),
                            topLeft: Radius.circular(8.sp),
                            topRight: Radius.circular(8.sp),
                            bottomRight: Radius.circular(0.sp),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.sp),
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.sp, right: 12.sp),
                            child: Icon(
                              Icons.lock,
                              size: 16.sp,
                              color: Colors.white,
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
    );
  }
}

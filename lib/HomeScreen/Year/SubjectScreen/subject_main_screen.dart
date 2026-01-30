import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realestate/HomeScreen/Year/SubjectScreen/subject_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../HexColorCode/HexColor.dart';
import '../../../Plan/plan.dart';
import '../../../PracticeQuestionScreen/practice_question_subject.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/image.dart';
import '../../../YoutubPlayer/youtube_players.dart';
import '../../../baseurl/baseurl.dart';
import '../../home_screen.dart';

class SubjectMainScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final int? stateId;
  final String planstatus;

  const SubjectMainScreen(
      {super.key, required this.title, required this.categoryId, required this.stateId, required this.planstatus});

  @override
  State<SubjectMainScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<SubjectMainScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  bool isLoading = false; // Add this for the loading state
  List<dynamic> banner = [];

  List<dynamic> subjects = [];

  @override
  void initState() {
    super.initState();
    hitQuestionApi();
    hitAllCategory();

  }

  Future<void> hitQuestionApi() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${subjectMaster}${widget.categoryId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

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

  final List<Color> colorList = [
    primaryColor,
    Colors.white,
  ];

  Future<void> downloadAndOpenPDF(
      String url, String filename, int index) async {
    setState(() {
      isDownloadingList[index] = true;
      downloadProgressList[index] = 0.0;
    });

    try {
      Dio dio = Dio();

      // Request permission to write to external storage
      PermissionStatus status =
          await Permission.manageExternalStorage.request();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      setState(() {
        isDownloadingList[index] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }
  Future<void> hitAllCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse(categorys),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('banners') ) {
        setState(() {
          banner = responseData['banners'];

        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: isLoading
          ? WhiteCircularProgressWidget()
          : Column(
              children: [
                Padding(
                  padding:  EdgeInsets.only(left:5.sp,right: 5.sp,top: 5.sp,bottom: 0.sp),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 110.sp,
                      autoPlay: true,
                      initialPage: 10,
                      viewportFraction: 1,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: (banner.length > 0)
                        ? banner.map((e) {
                      return Builder(
                        builder: (context) {
                          return InkWell(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.sp, vertical: 0),
                              child: Material(
                                borderRadius: BorderRadius.circular(10.0),
                                clipBehavior: Clip.hardEdge,
                                child: Container(
                                  height: 110.sp,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: CachedNetworkImage(
                                      imageUrl: e['picture_urls'].toString(),
                                      fit: BoxFit.fill,
                                      // Adjust this according to your requirement
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            'assets/no_image.jpg',
                                            // Path to your default image asset
                                            // Adjust width as per your requirement
                                            fit: BoxFit
                                                .cover, // Adjust this according to your requirement
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList()
                        : banner.map((e) {
                      return Builder(builder: (context) {
                        return Container(
                          height: 120.sp,
                          width: MediaQuery.of(context).size.width * 0.90,
                          // margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 5.sp, left: 8.sp, right: 5.sp, bottom: 5.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                        text: '${widget.title}${' subject wise complete notes basic and advanced level'}'.toUpperCase(),
                        style: GoogleFonts.radioCanada(
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                subjects.isEmpty
                    ? DataNotFoundWidget()
                    : Flexible(
                        child: GridView.count(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          // Disable scrolling
                          crossAxisCount: 2,
                          childAspectRatio: .9,
                          children: List.generate(
                            subjects.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubjectScreen(
                                        title: subjects[index]['name'].toString(),
                                        masterSubjectId: subjects[index]['id'], catName: '${widget.title}', planstatus: '${widget.planstatus}',
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      // height: 200.sp,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: colorList,
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        color:  HexColor("#4d6b53"),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        // Rounded corners with radius 10
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white,
                                            spreadRadius: 1.sp,
                                          ),
                                        ],
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
                                                          15.sp)),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.sp),
                                                child: Image.asset(logo),
                                              ),
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 0.sp, right: 8.sp),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 60.sp,
                                                      width: 60.sp,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.sp)),
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.sp),
                                                          child: Image.network(
                                                            subjects[index][
                                                                    'picture_urls']
                                                                .toString(),
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Image.asset(
                                                                  logo); // Path to your default image
                                                            },
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 10.sp,
                                                    ),
                                                    Text(
                                                      '${subjects[index]['name'].toString()} ',
                                                      // year[index]['year'].toString(),
                                                      style: GoogleFonts.cabin(
                                                        textStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
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
                                            bottomLeft: Radius.circular(10.sp),
                                            topLeft: Radius.circular(10.sp),
                                            topRight: Radius.circular(5.sp),
                                            bottomRight: Radius.circular(0.sp),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(1.sp),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.sp, right: 8.sp),
                                            child: Text(
                                              _getTruncatedText(widget.title, 2),
                                              maxLines: 1,
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
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
                                      child: Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Container(
                                          width: double.infinity,
                                          height: 20.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            // borderRadius: BorderRadius.circular(10.sp)
                                            borderRadius: BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(10.sp),
                                              topLeft: Radius.circular(10.sp),
                                              topRight: Radius.circular(10.sp),
                                              bottomRight:
                                                  Radius.circular(10.sp),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Continue',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
  String _getTruncatedText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      return words.sublist(0, wordLimit).join(' ') + '...';
    }
    return text;
  }
}

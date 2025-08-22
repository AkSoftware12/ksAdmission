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
import '../../home_screen.dart';
import '../Test/TestPaper/test_paper.dart';
import 'package:intl/intl.dart';

class MockTestScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final int? stateId;
  final String planstatus;

  const MockTestScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.stateId,
    required this.planstatus,
  });

  @override
  State<MockTestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<MockTestScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  String formattedDate = '';
  bool isLoading = false;

  List<dynamic> mockTest = [];

  final List<CompetitionCatergory> competition = [
    CompetitionCatergory(
      title: 'NEET PYS 2024',
      subtitle: 'Get All India Rank',
      image: 'assets/neet.png',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET PYS 2023',
      subtitle: 'Get All India Rank',
      image: 'assets/ssc.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET - Physics Chapterwise PYP (2024-1998)',
      subtitle: 'Get All India Rank',
      image: 'assets/nda.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET - Physics Chapterwise PYP (2024-1998)',
      subtitle: 'Get All India Rank',
      image: 'assets/upsc.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET - Physics Chapterwise PYP (2024-1998)',
      subtitle: 'Get All India Rank',
      image: 'assets/aiims.jfif',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET - Physics Chapterwise PYP (2024-1998)',
      subtitle: 'Get All India Rank',
      image: 'assets/jee.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET - Physics Chapterwise PYP (2024-1998) ',
      subtitle: 'Get All India Rank',
      image: 'assets/ctet.jpeg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET PYS 2022',
      subtitle: 'Get All India Rank',
      image: 'assets/clat.jfif',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET PYS 2021',
      subtitle: 'Get All India Rank',
      image: 'assets/rrb.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET PYS 2020',
      subtitle: 'Get All India Rank',
      image: 'assets/nift.jpg',
      backgroundColor: primaryColor,
    ),
    CompetitionCatergory(
      title: 'NEET PYS 2019',
      subtitle: 'Get All India Rank',
      image: 'assets/nift.jpg',
      backgroundColor: primaryColor,
    ),
  ];

  final List<Color> colorList = [primaryColor, Colors.white];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // Format the date as needed (e.g., "yyyy-MM-dd")
    formattedDate = DateFormat('yyyy-MM-dd').format(now);
    print(formattedDate); // Output: 2024-11-13

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
        'subcategory': 16,
        'state': widget.stateId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          mockTest = responseData['data'];
          isDownloadingList = List<bool>.filled(mockTest.length, false);
          downloadProgressList = List<double>.filled(mockTest.length, 0.0);
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
      body: isLoading
          ? WhiteCircularProgressWidget()
          : SingleChildScrollView(
              child: Column(
                children: [
                  mockTest.isEmpty
                      ? Center(child: DataNotFoundWidget())
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: .9,
                          children: List.generate(mockTest.length, (index) {
                            // Parse the date from your data source
                            String
                            dateString = mockTest[index]['mock_start_date']
                                .toString(); // Ensure this is the correct key
                            DateTime mockDate = DateFormat(
                              "yyyy-MM-dd",
                            ).parse(dateString); // Adjust format as needed
                            DateTime currentDate = DateTime.now();

                            bool isUnlocked = !mockDate.isAfter(
                              currentDate,
                            ); // True if the date is today or earlier

                            return (widget.planstatus == 'locked')
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (index == 0) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                                insetPadding: EdgeInsets.zero,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height -
                                                      MediaQuery.of(
                                                        context,
                                                      ).padding.top,
                                                  child: InstructionPage(
                                                    paperId:
                                                        mockTest[index]['id'],
                                                    papername:
                                                        mockTest[index]['paper_name']
                                                            .toString(),
                                                    exmaTime:
                                                        mockTest[index]['time_limit'] !=
                                                            null
                                                        ? mockTest[index]['time_limit']
                                                              as int
                                                        : 0,
                                                    question:
                                                        mockTest[index]['question_count']
                                                            .toString(),
                                                    marks:
                                                        mockTest[index]['total_marks']
                                                            .toString(),
                                                    type: '',
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          showUpgradeDialog(context);

                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: colorList,
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.0,
                                                      ),

                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.sp),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          padding:
                                                              EdgeInsets.all(
                                                                2.sp,
                                                              ),
                                                          child: Image.asset(
                                                            logo,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 8.sp,
                                                              right: 8.sp,
                                                            ),
                                                        child: Text(
                                                          mockTest[index]['paper_name']
                                                              .toString(),
                                                          style: GoogleFonts.cabin(
                                                            textStyle:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      11.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                                                0.sp,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      2.sp,
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 8.sp,
                                                        right: 8.sp,
                                                      ),
                                                      child: Text(
                                                        'Mock Test',
                                                        style: GoogleFonts.radioCanada(
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
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    // borderRadius: BorderRadius.circular(10.sp)
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(
                                                            10.sp,
                                                          ),
                                                      // topLeft: Radius.circular(10.sp),
                                                      // topRight: Radius.circular(10.sp),
                                                      bottomRight:
                                                          Radius.circular(
                                                            10.sp,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      2.sp,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
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
                                                                      '${''}${'Total Question :- '}${mockTest[index]['question_count'].toString()}',
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
                                                                      '${''}${'Total marks :- '}${mockTest[index]['total_marks'].toString()}',
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
                                                                      '${''}${'Marks Per Question :- '}${mockTest[index]['marks_per_question'].toString()}',
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
                                                                      '${''}${'Negative Marks Per Question :- '}${mockTest[index]['negative_marks'].toString()}',
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
                                                                      '${''}${'Time Limit :- '}${mockTest[index]['time_limit'].toString()}',
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
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.sp),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 30.sp,
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
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
                                                      child: (!isUnlocked)
                                                          ? Text(
                                                              mockTest[index]['mock_start_date']
                                                                  .toString(),
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
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
                                                          : (mockTest[index]['test_status'] ==
                                                                'Submited')
                                                          ? GestureDetector(
                                                              onTap: () {},
                                                              child: Text(
                                                                mockTest[index]['test_status']
                                                                    .toString(),
                                                                style: GoogleFonts.radioCanada(
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              child: Text(
                                                                mockTest[index]['test_status']
                                                                    .toString(),
                                                                style: GoogleFonts.radioCanada(
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .white,
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
                                          if (widget.planstatus == 'locked' &&
                                              index !=
                                                  0) // Add a locked indicator
                                            Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.lock,
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                size: 50.sp,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: isUnlocked
                                          ? () {}
                                          : () {
                                              // Show a message if locked
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "This test is locked until $dateString",
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Stack(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: colorList,
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.0,
                                                      ),

                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.sp),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          padding:
                                                              EdgeInsets.all(
                                                                2.sp,
                                                              ),
                                                          child: Image.asset(
                                                            logo,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 8.sp,
                                                              right: 8.sp,
                                                            ),
                                                        child: Text(
                                                          mockTest[index]['paper_name']
                                                              .toString(),
                                                          style: GoogleFonts.cabin(
                                                            textStyle:
                                                                TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      11.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                                                0.sp,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      2.sp,
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 8.sp,
                                                        right: 8.sp,
                                                      ),
                                                      child: Text(
                                                        'Mock Test',
                                                        style: GoogleFonts.radioCanada(
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
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    // borderRadius: BorderRadius.circular(10.sp)
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(
                                                            10.sp,
                                                          ),
                                                      // topLeft: Radius.circular(10.sp),
                                                      // topRight: Radius.circular(10.sp),
                                                      bottomRight:
                                                          Radius.circular(
                                                            10.sp,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      2.sp,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
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
                                                                      '${''}${'Total Question :- '}${mockTest[index]['question_count'].toString()}',
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
                                                                      '${''}${'Total marks :- '}${mockTest[index]['total_marks'].toString()}',
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
                                                                      '${''}${'Marks Per Question :- '}${mockTest[index]['marks_per_question'].toString()}',
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
                                                                      '${''}${'Negative Marks Per Question :- '}${mockTest[index]['negative_marks'].toString()}',
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
                                                                      '${''}${'Time Limit :- '}${mockTest[index]['time_limit'].toString()}',
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
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.sp),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 30.sp,
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
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
                                                      child: (!isUnlocked)
                                                          ? Text(
                                                              mockTest[index]['mock_start_date']
                                                                  .toString(),
                                                              style: GoogleFonts.radioCanada(
                                                                textStyle: TextStyle(
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
                                                          : (mockTest[index]['test_status'] ==
                                                                'Submited')
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                CustomToast.show(
                                                                  context,
                                                                  "Paper Already Submitted ",
                                                                );
                                                              },
                                                              child: Text(
                                                                mockTest[index]['test_status']
                                                                    .toString(),
                                                                style: GoogleFonts.radioCanada(
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        BuildContext
                                                                        context,
                                                                      ) {
                                                                        return Dialog(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              0,
                                                                            ),
                                                                          ),
                                                                          insetPadding:
                                                                              EdgeInsets.zero,
                                                                          child: SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                MediaQuery.of(
                                                                                  context,
                                                                                ).size.height -
                                                                                MediaQuery.of(
                                                                                  context,
                                                                                ).padding.top,
                                                                            child: InstructionPage(
                                                                              paperId: mockTest[index]['id'],
                                                                              papername: mockTest[index]['paper_name'].toString(),
                                                                              exmaTime:
                                                                                  mockTest[index]['time_limit'] !=
                                                                                      null
                                                                                  ? mockTest[index]['time_limit']
                                                                                        as int
                                                                                  : 0,
                                                                              question: mockTest[index]['question_count'].toString(),
                                                                              marks: mockTest[index]['total_marks'].toString(),
                                                                              type: '',
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                );
                                                              },
                                                              child: Text(
                                                                mockTest[index]['test_status']
                                                                    .toString(),
                                                                style: GoogleFonts.radioCanada(
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .white,
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
                                        ],
                                      ),
                                    ),
                                  );
                          }),
                        ),
                ],
              ),
            ),
    );
  }
}

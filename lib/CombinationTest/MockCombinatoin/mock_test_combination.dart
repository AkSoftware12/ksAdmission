import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../../../baseurl/baseurl.dart';
import '../../HomeScreen/home_screen.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/image.dart';


class MockTestCombinationScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final VoidCallback onReturn;


  const MockTestCombinationScreen({super.key, required this.title, required this.categoryId, required this.onReturn,});

  @override
  State<MockTestCombinationScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<MockTestCombinationScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus='';
  bool isLoading = false;


  List<dynamic> mockTest = [];


  final List<Color> colorList = [
    Colors.white,
   primaryColor,

  ];




  @override
  void initState() {
    super.initState();
    // fetchPaperData(widget.categoryId,);
    hitQuestionApi();
  }

  Future<void> hitQuestionApi() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$combinationData${widget.categoryId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      widget.onReturn;
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('mock_tests')) {
        setState(() {
          mockTest = responseData['mock_tests'];
          // isDownloadingList = List<bool>.filled(subjects.length, false);
          // downloadProgressList = List<double>.filled(subjects.length, 0.0);
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


  Future<void> fetchPaperData(int categoryId,) async {

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
        'category': widget.categoryId,'subcategory': 16,

      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      userPlanStatus=responseData['userPlanStatus'];


      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          mockTest = responseData['data'];
          isDownloadingList = List<bool>.filled(mockTest.length, false);
          downloadProgressList = List<double>.filled(mockTest.length, 0.0);
          isLoading = false; // Stop progress bar

        });
      } else {
        throw Exception('Invalid API response: Missing "properties" key');
      }
    } else {
      // Handle error
      if (kDebugMode) {
        print('Error: ${response.statusCode}');
      }
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> downloadAndOpenPDF(String url, String filename, int index) async {
    setState(() {
      isDownloadingList[index] = true;
      downloadProgressList[index] = 0.0;
    });

    try {
      Dio dio = Dio();

      // Request permission to write to external storage
      PermissionStatus status = await Permission.manageExternalStorage.request();

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
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath = "$newPath/Download";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body:isLoading
          ? WhiteCircularProgressWidget()
          :

      Column(
        children: [
          mockTest.isEmpty
              ? Center(child: DataNotFoundWidget())
              :
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // Disable scrolling
            crossAxisCount: 2,
            childAspectRatio: .9,
            children: List.generate(
              mockTest.length,
                  (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstructionPage(
                                paperId: mockTest[index]['id'],
                                papername: mockTest[index]['paper_name'].toString(),
                                exmaTime: mockTest[index]['time_limit'] != null ? mockTest[index]['time_limit'] as int : 0,  // Providing default value for null
                                question: mockTest[index]['question_count'].toString(),
                                marks: mockTest[index]['total_marks'].toString(),
                                type: '',
                              ),
                            ),
                          );

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
                                color:primaryColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding:  EdgeInsets.all(8.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 30.sp,
                                      width: 30.sp,
                                      decoration: BoxDecoration(
                                          color: Colors.white,

                                          borderRadius: BorderRadius.circular(15.sp)
                                      ),
                                      child: Padding(
                                        padding:  EdgeInsets.all(2.sp),
                                        child: Image.asset(logo),
                                      ),
                                    ),
                                    Padding(
                                      padding:  EdgeInsets.only(top: 8.sp,right: 8.sp),
                                      child: Text(
                                        mockTest[index]['paper_name'].toString(),
                                        style: GoogleFonts.cabin( textStyle:
                                        TextStyle(
                                            color: Colors.black,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold),
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
                                    topRight: Radius.circular(10.sp),
                                    bottomRight: Radius.circular(0.sp),
                                  ),
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.all(2.sp),
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                    child: Text('Mock Test',
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          fontSize: 10.sp,
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
                              child: Container(
                                width: double.infinity,
                                height: 100.sp,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // borderRadius: BorderRadius.circular(10.sp)
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.sp),
                                    // topLeft: Radius.circular(10.sp),
                                    // topRight: Radius.circular(10.sp),
                                    bottomRight: Radius.circular(10.sp),
                                  ),
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.all(2.sp),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                            child:   Text.rich(TextSpan(
                                              text: '${''}${'Total Question :- '}${mockTest[index]['question_count'].toString()}',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )),

                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                            child:   Text.rich(TextSpan(
                                              text: '${''}${'Total marks :- '}${mockTest[index]['total_marks'].toString()}',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )),

                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                            child:   Text.rich(TextSpan(
                                              text: '${''}${'Marks Per Question :- '}${mockTest[index]['marks_per_question'].toString()}',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )),

                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                            child:   Text.rich(TextSpan(
                                              text: '${''}${'Negative Marks Per Question :- '}${mockTest[index]['negative_marks'].toString()}',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )),

                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(left: 8.sp,right: 8.sp),
                                            child:   Text.rich(TextSpan(
                                              text: '${''}${'Time Limit :- '}${mockTest[index]['time_limit'].toString()}',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )),

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
                              child:  Padding(
                                padding:  EdgeInsets.all(8.sp),
                                child: Container(
                                  width: double.infinity,
                                  height: 20.sp,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    // borderRadius: BorderRadius.circular(10.sp)
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.sp),
                                      topLeft: Radius.circular(10.sp),
                                      topRight: Radius.circular(10.sp),
                                      bottomRight: Radius.circular(10.sp),
                                    ),
                                  ),
                                  child:Center(
                                    child: Text('Continue',
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

                      if(userPlanStatus=='Inactive')
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlanScreen(appBar: '',

                                ),
                              ),
                            );

                          },

                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10.0),
                              ),

                              child: Center(child: Icon(Icons.lock,color: primaryColor,size: 40.sp,))),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}

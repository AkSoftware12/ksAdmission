import 'dart:async';
import 'dart:io';

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
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:realestate/NewExam/OMR/omr_sheet.dart';
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
import '../../HomePage/home_page.dart';
import '../../HomeScreen/home_screen.dart';
import 'package:intl/intl.dart';

import 'new_exam_instructions.dart';

class NewExamMockScreen extends StatefulWidget {


  const NewExamMockScreen({
    super.key,
  });

  @override
  State<NewExamMockScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<NewExamMockScreen> {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  bool downloadCompleted = false;
  bool isDownloading = false;
  late List<bool> isDownloadingList;
  late List<double> downloadProgressList;
  String userPlanStatus = '';
  String event_date = '';
  String paperMode = '';
  dynamic  formattedDate ;
  dynamic  formattedDate2 ;
  bool isLoading = false;
  Razorpay _razorpay = new Razorpay();
  var showDialogBox = false;
  final DateTime targetDateTime = DateTime(2025, 1, 15, 10, 0, 0);
  bool isPaperOpened = false;
  final DateTime openDateTime = DateTime(2025, 1, 15, 11, 42, 0);
  final dateStringFromApi = "10:00:00";
  DateTime currentDateTime = DateTime.now();


  String price = "200";
  String time = '';
  String endTime2 = '';
  String paperDate = '';

  String? razorpayOrderId = '';
  String? razorpayKeyId = '';
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';
  String formattedCurrentTime = '';
  List<dynamic> mockTest = [];
  List<dynamic> subject = [];
  bool _isTimeUp = false;
  Timer? _endTimeCheckTimer;
  String buttonString = "";


  final List<Color> colorList = [
    primaryColor,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
   formattedDate = DateFormat('yyyy-MM-dd H:mm:ss').format(now);

    print(formattedDate); // Output: 2024-11-13
    _checkTime();
    fetchPaperData();
    _endTimeCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkEndTime();
    });
  }


  void checkEndTime() {
    DateTime now = DateTime.now();

    // Ensure time and endTime2 are valid before parsing
    if (time.isNotEmpty && endTime2.isNotEmpty) {
      DateTime startTime = DateFormat('HH:mm:ss').parse(time);
      DateTime endTime = DateFormat('HH:mm:ss').parse(endTime2);
      formattedDate = DateFormat('yyyy-MM-dd H:mm:ss').parse('${event_date} ${time}');


      // Set the parsed times to today’s date for a proper comparison
      startTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute, startTime.second);
      endTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute, endTime.second);

      print('START TIME $time');
      print('Formate TIME $formattedDate');
      print('END TIME $endTime2');
      print('Current TIME $now');

      // Compare the current time with the start and end times

      if(formattedDate2==formattedDate){

      }
      if (now.isAfter(formattedDate)) {
        print('Exam Started $now');
        setState(() {
          buttonString = "Start";
        });

      }
      else{
        String formattedStartTime = DateFormat('hh:mm:ss a').format(startTime);
        setState(() {
          buttonString = event_date;
        });
        print('Exam Not Started');
      }

      if (now.isAfter(endTime)) {
        print('Exam Ended $now');
        setState(() {
          // buttonString = "Exam Ended";
          buttonString = "Exams Finished";

        });
      }
    } else {
      print('Invalid time or end time');
    }
  }



  void _checkTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      if (currentTime.isAfter(targetDateTime) || currentTime.isAtSameMomentAs(targetDateTime)) {
        timer.cancel();
        _openPaper();
      }
    });
  }







  void _openPaper() {
    setState(() {
      isPaperOpened = true;
    });
  }

  Future<void> fetchPaperData(

  ) async {
    setState(() {
      isLoading = true; // Show progress bar
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse(eventExam),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category': 5,
        'subcategory': 16,
        'state': '',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      userPlanStatus = responseData['payement_status'];
      event_date = responseData['event_date'];
      paperMode = responseData['test_mode'].toString();
      time = responseData['time_new'];
      endTime2 = responseData['end_time'];

      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          mockTest = responseData['data'];
          subject = responseData['subject'];
          paperDate = responseData['data'][0]['mock_start_date'].toString();
          isDownloadingList = List<bool>.filled(mockTest.length, false);
          downloadProgressList = List<double>.filled(mockTest.length, 0.0);
          isLoading = false; // Stop progress bar
        });
      } else {
        isLoading = false;

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Text(
          'New Exam',
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
                          children: List.generate(
                            mockTest.length,
                            (index) {



                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: isPaperOpened
                                      ? () {

                                        }
                                      : () {
                                          // Show a message if locked
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "This test is locked until ")),
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
                                              borderRadius: BorderRadius.circular(10.0),
                                              // Rounded corners with radius 10
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.grey.withOpacity(0.5),
                                              //     spreadRadius: 2,
                                              //     blurRadius: 7,
                                              //     offset: Offset(0, 3),
                                              //   ),
                                              // ],
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
                                                          fontSize: 11.sp,
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
                                                height: 30.sp,
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
                                                  child: (mockTest[index]['exam_status']=='Yes')?

                                                  GestureDetector(
                                                    onTap: (){
                                                      if(paperMode=='2'){

                                                        if(mockTest[index]['allotment_date'].toString()==event_date){

                                                          if(buttonString=='Exams Finished'){

                                                          }else{
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
                                                                    height: MediaQuery.of(context)
                                                                        .size
                                                                        .height -
                                                                        MediaQuery.of(context)
                                                                            .padding
                                                                            .top,
                                                                    child: InstructionPage(
                                                                      paperId: mockTest[index]
                                                                      ['id'],
                                                                      papername: mockTest[index]
                                                                      ['paper_name']
                                                                          .toString(),
                                                                      exmaTime: mockTest[index]
                                                                      ['time_limit'] !=
                                                                          null
                                                                          ? mockTest[index]
                                                                      ['time_limit'] as int
                                                                          : 0,
                                                                      question: mockTest[index]
                                                                      ['question_count']
                                                                          .toString(),
                                                                      marks: mockTest[index]
                                                                      ['total_marks']
                                                                          .toString(),
                                                                      type: '',

                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }

                                                        }else{

                                                        }



                                                      }
                                                    },


                                                    child:
                                                     (formattedCurrentTime.compareTo(mockTest[index]['time'].toString()) > 0) ?

                                                    Text(event_date,
                                                      style: GoogleFonts.radioCanada(
                                                        textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                          :  mockTest[index]['allotment_date'].toString()==event_date?
                                                     Text(
                                                       // mockTest[index]['mock_start_date'].toString(),
                                                       '${buttonString}',
                                                       style: GoogleFonts.radioCanada(
                                                         textStyle: TextStyle(
                                                           fontSize: 15.sp,
                                                           fontWeight: FontWeight.normal,
                                                           color: Colors.white,
                                                         ),
                                                       ),
                                                     ): Text(
                                                       // mockTest[index]['mock_start_date'].toString(),
                                                       '${'Exam Finished'}',
                                                       style: GoogleFonts.radioCanada(
                                                         textStyle: TextStyle(
                                                           fontSize: 15.sp,
                                                           fontWeight: FontWeight.normal,
                                                           color: Colors.white,
                                                         ),
                                                       ),
                                                     ),




                                                  ):
                                                  GestureDetector(
                                                    child:
                                                    Text(event_date,
                                                      style: GoogleFonts.radioCanada(
                                                        textStyle: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ),
                                              ),
                                            ),

                                          )

                                        ],
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
          ),


    );
  }


}

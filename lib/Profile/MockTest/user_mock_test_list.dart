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
import '../../../baseurl/baseurl.dart';
import '../../HomeScreen/home_screen.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/image.dart';
import '../Results/user_results.dart';


class UserMockTestScreen extends StatefulWidget {
  final String title;
  final int subcategory;

  const UserMockTestScreen({super.key, required this.title, required this.subcategory,});

  @override
  State<UserMockTestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<UserMockTestScreen> {

  bool isLoading = false;


  List<dynamic> mockTest = [];


  final List<Color> colorList = [
    primaryColor,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    fetchPaperData();
  }




  Future<void> fetchPaperData() async {

    setState(() {
      isLoading = true; // Show progress bar
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse(getUserPaperList),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
      'subcategory_id': widget.subcategory,

      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data')) {
        setState(() {
          // Assuming 'properties' is a list, update allProperty accordingly
          mockTest = responseData['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),

        title: Text(widget.title,  style: GoogleFonts.roboto(
          textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),  ),
      ),
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
                              builder: (context) => UserResultsScreen(
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
                                    child: Text('Result',
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

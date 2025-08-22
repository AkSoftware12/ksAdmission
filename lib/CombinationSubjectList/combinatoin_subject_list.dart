
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../Utils/app_colors.dart';
import '../CombinationTest/combination_test.dart';
import '../Utils/image.dart';
import '../baseurl/baseurl.dart';

class CombinationSubjectList extends StatefulWidget {
  final String title;
  final int categoryId;
  final String type;
  final VoidCallback onReturn;



  const CombinationSubjectList(
      {super.key, required this.title, required this.categoryId, required this.type, required this.onReturn});

  @override
  State<CombinationSubjectList> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<CombinationSubjectList> {
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
      Uri.parse('$subjectMaster${widget.categoryId}'),
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
  Future<void> hitCombinationCreateApi() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token',);

    Map<String, dynamic> responseData = {
      "category_id": widget.categoryId,
      "subject_ids": _selectedIndices,
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(subjectCombinationCreate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );


      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        widget.onReturn();
        if (kDebugMode) {
          print("Data sent successfully: ${response.body}");
        }
        setState(() {
          prefs.setBool('combination', true);
          if(widget.type==''){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CombinationTest(title: widget.title, categoryId: widget.categoryId,)),
            );
          } else{


            Navigator.pop(context);

          }

        });



      } else {
        if (kDebugMode) {
          print("Failed to send data: ${response.statusCode}");
        }
        setState(() {
          isLoading = false; // Stop progress bar on exception
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred: $e");
      }
      setState(() {
        isLoading = false; // Stop progress bar on exception
      });
    }
  }



  final List<int> _selectedIndices = [];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title:Text(widget.title,style: TextStyle(
          color: Colors.white
        ),),
      ),
      body: isLoading ? WhiteCircularProgressWidget() : Padding(
        padding:  EdgeInsets.only(bottom: 50.sp),
        child: Column(
          children: [

            subjects.isEmpty
                ? Center(child: DataNotFoundWidget())
                :
            Flexible(
              child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    bool isMaxReached = _selectedIndices.length >= 3;
                    bool isSelected = _selectedIndices.contains(subjects[index]['id']);
                    return Padding(
                      padding: EdgeInsets.all(3.sp),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ChapterScreen(
                          //       title: subjects[index]['name'].toString(),
                          //       chapterId: subjects[index]['id'],
                          //     ),
                          //   ),
                          // );
                        },

                        child: Stack(
                          children: [
                            Container(
                                width: double.infinity,
                                // height: 90.sp,
                                decoration: BoxDecoration(
                                  // color: greenColorQ.withOpacity(0.2),
                                  // color: subjects[index]['color'] != null
                                  //     ? HexColor(subjects[index]['color'].toString())
                                  //     : Colors.grey,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border:  Border(
                                    left: BorderSide(
                                      color: Colors.white, // Change the color to whatever you need
                                      width: 3.sp, // Set the border width
                                    ),
                                    right: BorderSide(
                                      color: Colors.white, // Change the color to whatever you need
                                      width: 3.sp, // Set the border width
                                    ),
                                    top: BorderSide(
                                      color: Colors.white, // Change the color to whatever you need
                                      width: 1.sp, // Set the border width
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.white, // Change the color to whatever you need
                                      width: 1.sp, // Set the border width
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(40.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child:Image.network(
                                            subjects[index]['picture_urls'].toString(),
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(logo); // Path to your default image
                                            },
                                          )

                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        subjects[index]['name'].toString(),
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Spacer(),
                                      Checkbox(
                                        side:
                                        BorderSide(width: 2, color: Colors.white),
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          if (value == true && isMaxReached && !isSelected) {
                                            Fluttertoast.showToast(
                                              msg: "Maximum of 3 Subject can be selected",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }
                                          setState(() {
                                            if (value == true) {
                                              if (_selectedIndices.length >= 3) {
                                                Fluttertoast.showToast(
                                                  msg: "Maximum of 3 items can be selected",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                );
                                                return;
                                              }
                                              _selectedIndices.add(subjects[index]['id']);
                                              if (kDebugMode) {
                                                print(_selectedIndices);
                                              }
                                            } else {
                                              _selectedIndices.remove(subjects[index]['id']);
                                              if (kDebugMode) {
                                                print(_selectedIndices);
                                              }

                                            }
                                          });                                        },
                                        activeColor: Colors.orange,
                                        checkColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                )),
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

                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        height: 50.sp,
        color:primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
           GestureDetector(
              onTap: () async {
                hitCombinationCreateApi();

              },
              child: Container(
                height: 40.sp,
                width: 100.sp,
                decoration: BoxDecoration(
                    color: Colors.orange,

                    borderRadius: BorderRadius.circular(10.sp)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('Submit',style: TextStyle(
                        color: Colors.white,fontSize: 15.sp
                    ),),
                  ),
                ),
              ),
            ),
          Container(),

      ],
        ),
      ),
    );
  }
}

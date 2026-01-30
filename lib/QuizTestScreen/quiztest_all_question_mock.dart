import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/QuizTestScreen/quizResultPage.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class AllQuestionMockQuizScreen extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final String type;


  const AllQuestionMockQuizScreen(
      {super.key,
      required this.paperId,
      required this.papername,
      required this.exmaTime, required this.question, required this.marks, required this.type});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<AllQuestionMockQuizScreen> {
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 0;
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;

  Timer? _timer;
  bool _isAnswered = false;
  int? _selectedIndex; // Store the index of the selected answer
  int? _correctIndex;




  bool _isLoading = false;

  List<dynamic> plan = [];

  List<dynamic> paperList = [];
  List<int> _selectedIndices = [0];
  Map<int, int> selectedOptions = {};
  List<Map<String, dynamic>> response1 = []; // To store selected options


  @override
  void initState() {
    super.initState();
    startTimer();
    _secondsRemaining =minutesToSeconds(widget.exmaTime);
    hitQuestionApi();

    _controller.addListener(() {
      // Update the current index based on scroll position
      final index = (_controller.offset / 300).round(); // Adjust based on item height
      if (index != _currentIndex && index >= 0 && index < paperList.length) {
        setState(() {
          _currentIndex = index;
        });
      }
    });
  }



  int minutesToSeconds(int minutes) {
    return minutes * 60;
  }
  Future<void> hitQuestionApi() async {
    final response = await http.get(Uri.parse('${question}${widget.paperId}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          paperList = responseData['data'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          sendQuestionData();
        }
      });
    });
  }









  String get formattedTime {
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }






  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }


  void addResponse(int questionId, int selectedOption) {
    Map<String, dynamic> questionResponse = {
      "question_id": questionId,
      "selected_option": selectedOption
    };

    // Agar same question ka response already exist hai toh usse update karenge
    int index = response1.indexWhere((response) => response['question_id'] == questionId);
    if (index != -1) {
      response1[index] = questionResponse;
    } else {
      // Agar response pehle se nahi hai toh naya add karenge
      response1.add(questionResponse);
    }
  }


  Future<void> sendQuestionData() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(
              ),

            ],
          ),
        );
      },
    );

    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id',);
    final String? token = prefs.getString('token',);

    Map<String, dynamic> responseData = {
      "paper_id": widget.paperId,
      "user_id": userId.toString(),
      "response": response1
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(submit),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (responseData.containsKey('plan')) {
          setState(() {
            plan = responseData['plan'];

          });
        }
        setState(() {

          if(widget.type=='testSeries'){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizResultPage(
                  rank: jsonData['rank'],
                  score: jsonData['score'].toString(),
                  correctquestion: jsonData['correctquestion'],
                  totalQuestions: jsonData['totalQuestions'],
                  title: widget.papername,
                  skipquestion: jsonData['skipquestion'],
                  attemptQuestions: jsonData['attemptQuestions'],
                  total_negative_marks: jsonData['total_negative_marks'].toString(),
                  wrongquestion: jsonData['wrongquestion'],
                  total_marks: jsonData['total_marks'],),
              ),
            );

          }else{
            _showSubmitDialog(context);

          }


          response1.clear();

        });



      } else {
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }


  Future<bool> showExitPopup(context) async{
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to exit?"),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => Homepage(initialIndex: 0,)),
                            // );

                            Navigator.of(context).pop(true); // Exit the app

                          },
                          child: Text("Yes",style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: greenColorQ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              print('no selected');
                              Navigator.of(context).pop();
                            },
                            child: Text("No", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (paperList.isEmpty) {
      return Scaffold(
        backgroundColor: primaryColor,
        // body:Center(
        //   child: PrimaryCircularProgressWidget(
        //     color: Colors.white,
        //   ),
        // )
      );
    }
    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => Material(
        color: primaryColor,
        child: WillPopScope(
          onWillPop: () async => showExitPopup(context),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,

              title: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.alarm,
                            color: _secondsRemaining <= 10 ? Colors.red : Colors.green,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.sp),
                          // Add Flexible to ensure proper space allocation
                          Text('$formattedTime',style: TextStyle(color: Colors.green),),
                        ],
                      ),
                      // Uncommented code
                      Row(
                        children: [
                          SizedBox(
                            width: 200.sp,
                            child: Text(
                              ' ${widget.papername.toString()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Customize text color for paper name
                              ),
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ],
              ),

              actions: <Widget>[
                Padding(
                  padding:  EdgeInsets.only(right: 5.sp),
                  child: GestureDetector(
                    onTap: () {
                      sendQuestionData();
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 30.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.sp),
                            color: Colors.blueGrey,
                          ),
                          child: Center(
                            child: Padding(
                              padding:  EdgeInsets.only(left: 25.sp,right:25.sp),
                              child: Text(
                                'Submit',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: TextSizes.textsmall2,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              ],

            ),
            body: Padding(
              padding:  EdgeInsets.only(bottom: 50.sp),
              child: ListView.builder(
                controller: _controller,

                itemCount: paperList.length,

                itemBuilder: (context, index) {
                  return Padding(
                    padding:  EdgeInsets.only(bottom: 25.sp),
                    child: Card(
                      elevation: 15,
                      color: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Container(
                        child: Column(
                          children: [

                            Container(
                              decoration: BoxDecoration(
                                color: HexColor('#e8eff5'),
                                border: Border(
                                  top: BorderSide(
                                    color: HexColor('#4d6b53'), // Color of the top border
                                    width: 2.sp, // Width of the top border
                                  ),
                                  bottom: BorderSide(
                                    color: HexColor('#4d6b53'), // Color of the bottom border
                                    width: 2.sp, // Width of the bottom border
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding:  EdgeInsets.all(8.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   '${'Question-'}${index + 1}:',
                                    //   style: GoogleFonts.radioCanada(
                                    //     textStyle: TextStyle(
                                    //       fontSize: 18.sp,
                                    //       fontWeight: FontWeight.bold,
                                    //       color: Colors.black,
                                    //     ),
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   height: 20.sp,
                                    // ),
                                    // Text(
                                    //   paperList[index]['question'].toString(),
                                    //   style: GoogleFonts.radioCanada(
                                    //     textStyle: TextStyle(
                                    //       fontSize: 18.sp,
                                    //       fontWeight: FontWeight.normal,
                                    //       color: Colors.black,
                                    //     ),
                                    //   ),
                                    // ),


                                    if (paperList[index]['question_image_url'] == null || paperList[index]['question'] != null)
                                      Text(
                                        '${index + 1}. ${paperList[index]['question'].toString()}',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    if (paperList[index]['question_image_url'] != null && paperList[index]['question'] == null)
                                      Row(
                                        children: [

                                          Text(
                                            '${index + 1}.',
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Container(
                                                width: double.infinity,
                                                child: Image.network(
                                                  paperList[index]['question_image_url'].toString(),
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    if (paperList[index]['question_image_url'] != null &&
                                        paperList[index]['question'] != null)
                                      SizedBox(
                                        height: 100.sp,
                                        child: Image.network(
                                          paperList[index]['question_image_url'].toString(),
                                        ),
                                      ),
                                    SizedBox(height: 0.sp),
                                  ],
                                ),
                              ),
                            ),

                            // Ensure options are in List<String> format
                            ...(paperList[index]['options'] as List<dynamic>).asMap().entries.map((entry) {
                              int optionIndex = entry.key + 1;

                              String optionText = entry.value['text'].toString(); // Ensure option is a String
                              String optionImage = entry.value['image_url'].toString(); // Ensure option is a String

                              return Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    RadioListTile<int>(

                                      title:  Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if(optionText.isNotEmpty)
                                            Text(optionText),
                                          if(optionText.isEmpty)
                                            Image.network(optionImage)
                                        ],
                                      ), // Use optionText for display
                                      value: optionIndex, // Use the option index as the value
                                      groupValue:  selectedOptions[index], // Get the selected option for this question
                                      onChanged: (value) {
                                        setState(() {

                                          addResponse( paperList[index]['id'],optionIndex);
                                          selectedOptions[index] = value!; // Update the selected option for this question
                                          print(response1);

                                        });
                                      },
                                      activeColor: greenColorQ,
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1.sp,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),


                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Spacer(),
                            //
                            //     // Conditionally show the 'Previous' button only if index is greater than 0
                            //     // if (_currentQuestionIndex > 0)
                            //     //   Padding(
                            //     //     padding: const EdgeInsets.all(0.0),
                            //     //     child: GestureDetector(
                            //     //       onTap: () {
                            //     //         _previousQuestion();
                            //     //       },
                            //     //       child: Row(
                            //     //         children: [
                            //     //           Container(
                            //     //             width: 100.sp,
                            //     //             height: 40.sp,
                            //     //             decoration: BoxDecoration(
                            //     //               borderRadius: BorderRadius.circular(10.sp),
                            //     //               color: ColorConstants.primaryColor,
                            //     //             ),
                            //     //             child: Center(
                            //     //               child: Padding(
                            //     //                 padding: EdgeInsets.all(5.sp),
                            //     //                 child: Text(
                            //     //                   '   Previous   ',
                            //     //                   style: GoogleFonts.poppins(
                            //     //                     textStyle: TextStyle(
                            //     //                       fontSize: TextSizes.textmedium,
                            //     //                       fontWeight: FontWeight.normal,
                            //     //                       color: Colors.white,
                            //     //                     ),
                            //     //                   ),
                            //     //                 ),
                            //     //               ),
                            //     //             ),
                            //     //           ),
                            //     //         ],
                            //     //       ),
                            //     //     ),
                            //     //   ),
                            //     // if (_currentQuestionIndex > 0)
                            //     //   Spacer(),
                            //
                            //     // Always show the 'Next' button
                            //     Padding(
                            //       padding:  EdgeInsets.all(8.sp),
                            //       child: GestureDetector(
                            //         onTap: () {
                            //         },
                            //         child: Row(
                            //           children: [
                            //             Container(
                            //               decoration: BoxDecoration(
                            //                 borderRadius: BorderRadius.circular(8.sp),
                            //                 color: ColorConstants.primaryColor,
                            //               ),
                            //               child: Center(
                            //                 child: Padding(
                            //                   padding: EdgeInsets.all(8.sp),
                            //                   child: Padding(
                            //                     padding:  EdgeInsets.all(0.sp),
                            //                     child: Text(
                            //                       'Clear Selection',
                            //                       style: GoogleFonts.poppins(
                            //                         textStyle: TextStyle(
                            //                           fontSize: TextSizes.textmedium,
                            //                           fontWeight: FontWeight.normal,
                            //                           color: Colors.white,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //
                            //     Spacer(),
                            //   ],
                            // ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomSheet: Container(
              height: 60.sp,
              color: primaryColor,
              width: double.infinity,
              child:  Container(
                height: 40.sp,
                width: double.infinity,
                child: Padding(
                  padding:  EdgeInsets.all(12.sp),
                  child: GestureDetector(
                    onTap: () {
                      sendQuestionData();

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.sp),
                            color: Colors.blueGrey,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Padding(
                                padding:  EdgeInsets.only(left: 25.sp,right:25.sp),
                                child: Text(
                                  'Submit',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: TextSizes.textsmall2,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
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
                ),
              ),

            ),





          ),
        ),
      ),
    );



  }
  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Successfully'),
          content: Text('Your submission has been successfully completed.'),
          actions: <Widget>[
            TextButton(
              child: Text('Back to Home'),
              onPressed: () {


                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage(initialIndex: 0,)),
                );
                // You can navigate back to the Home screen if needed
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  // Method to toggle selection of options
  void _toggleSelection(int optionIndex) {
    if (_selectedIndices.contains(optionIndex)) {
      _selectedIndices.remove(optionIndex); // Remove if already selected
    } else {
      _selectedIndices.add(optionIndex); // Add if not selected
    }
  }
  int? selectedOption; // Declare this in your state class
  Map<int, int?> selectedAnswers = {};
  // Map<int, int?> selectedOptions = {};

// Assuming you have a list to hold selected indices
//   List<int> _selectedIndices = [];
}



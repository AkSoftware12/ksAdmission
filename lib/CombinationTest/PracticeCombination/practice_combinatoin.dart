import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../HexColorCode/HexColor.dart';
import '../../QuizTestScreen/quizResultPage.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/color_constants.dart';
import '../../Utils/image.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';


class PracticeCombinationScreen extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final int categoryId;

  const PracticeCombinationScreen(
      {super.key,
        required this.paperId,
        required this.papername,
        required this.exmaTime, required this.question, required this.marks, required this.categoryId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<PracticeCombinationScreen> {
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 0;

  Timer? _timer;
  bool _isAnswered = false;
  int? _selectedIndex; // Store the index of the selected answer
  int? _correctIndex;
  int _totalQuestions = 0; // Total questions
  int _correctAnswers = 0; // Correct answers
  int _wrongAnswers = 0;



  bool _isLoading = false;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String cityState = '';
  String pin = '';
  List<dynamic> plan = [];

  List<dynamic> paperList = [];
  bool _showExplanation = false;
  final List<int> _selectedIndices = [0];
  Map<int, int> selectedOptions = {};
  List<Map<String, dynamic>> response1 = []; // To store selected options


  @override
  void initState() {
    super.initState();
    startTimer();
    fetchProfileData();
    _secondsRemaining =minutesToSeconds(widget.exmaTime);
    hitQuestionApi();
  }
  int minutesToSeconds(int minutes) {
    return minutes * 60;
  }
  // Future<void> hitQuestionApi() async {
  //   final response = await http.get(Uri.parse('${question}${widget.paperId}'));
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //
  //     if (responseData.containsKey('data')) {
  //       setState(() {
  //         paperList = responseData['data'];
  //       });
  //     } else {
  //       throw Exception('Invalid API response: Missing "category" key');
  //     }
  //   }
  // }

  // Future<void> hitQuestionApi() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? token = prefs.getString('token');
  //   final response = await http.get(
  //     Uri.parse('${combinationData}'),  // Replace with your API URL
  //     headers: {
  //       'Authorization': 'Bearer $token', // Pass token in headers
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //
  //     if (responseData.containsKey('data')) {
  //       setState(() {
  //         paperList = responseData['data'];
  //       });
  //     } else {
  //       throw Exception('Invalid API response: Missing "category" key');
  //     }
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

  Future<void> hitQuestionApi() async {
    // setState(() {
    //   isLoading = true; // Show progress bar
    // });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$combinationData${widget.categoryId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('questions')) {
        setState(() {

          paperList = responseData['questions'];

          // subjects = responseData['data'];
          // isDownloadingList = List<bool>.filled(subjects.length, false);
          // downloadProgressList = List<double>.filled(subjects.length, 0.0);
          // isLoading = false; // Stop progress bar

        });
      } else {
        throw Exception('Invalid API response: Missing "data" key');
      }
    } else {
      setState(() {
        // isLoading = false; // Stop progress bar on exception
      });
    }
  }


  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }



  void _nextQuestion() {
    if (_currentQuestionIndex < paperList.length - 1) {
      setState(() {
        _isAnswered = false;
        _selectedIndex = null; // Reset selected index
        _correctIndex = null; // Reset correct index
        _currentQuestionIndex++; // Move to the next question
        _showExplanation = false; // Hide explanation for the new question
        // startTimer(); // Restart timer for the new question

        if (!_selectedIndices.contains(_currentQuestionIndex)) {
          _selectedIndices.add(_currentQuestionIndex); // Select the index
        }
      });
    } else {
      // You can navigate to a summary screen or show an alert that the quiz is finished
      // For example:
      // _showQuizCompletedDialog();
    }
  }






  String get formattedTime {
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }



  // void _selectAnswer(int selectedIndex) {
  //   if (_isAnswered) return;
  //
  //   final currentQuestion = paperList[_currentQuestionIndex];
  //   final correctAnswerIndex =
  //   currentQuestion['answer']; // Fetch correct answer index
  //
  //   setState(() {
  //     _selectedIndex = selectedIndex;
  //     _correctIndex = correctAnswerIndex;
  //     _isAnswered = true;
  //     // _timer?.cancel(); // Stop the timer when the question is answered
  //   });
  //   setState(() {
  //     _selectedIndex = selectedIndex;
  //     _isAnswered = true;
  //
  //     // Update the response with the selected option
  //     Map<String, dynamic> currentQuestion = paperList[_currentQuestionIndex];
  //     Map<String, dynamic> questionResponse = {
  //       "question_id": currentQuestion['id'],
  //       "selected_option": selectedIndex
  //     };
  //
  //     // Check if the question already exists in the response list and update
  //     int existingIndex = response1.indexWhere((element) =>
  //     element['question_id'] == currentQuestion['id']);
  //     if (existingIndex != -1) {
  //       response1[existingIndex] = questionResponse;
  //     } else {
  //       response1.add(questionResponse);
  //     }
  //
  //     _showExplanation = true; // Show explanation after selection
  //   });
  // }


  void _selectAnswer(int selectedIndex) {
    if (_isAnswered) return;

    final currentQuestion = paperList[_currentQuestionIndex];
    final List<int> correctAnswerIndices =
    List<int>.from(currentQuestion['answer']); // Fetch correct answer indices as a list

    setState(() {
      _selectedIndex = selectedIndex;
      _isAnswered = true;

      if (correctAnswerIndices.contains(selectedIndex)) {
        _correctAnswers++;
      } else {
        _wrongAnswers++;
      }

      _totalQuestions++; // Increment total questions after each attempt

      // Update the response with the selected option
      Map<String, dynamic> questionResponse = {
        "question_id": currentQuestion['id'],
        "selected_option": selectedIndex
      };

      // Check if the question already exists in the response list and update
      int existingIndex = response1.indexWhere(
              (element) => element['question_id'] == currentQuestion['id']);
      if (existingIndex != -1) {
        response1[existingIndex] = questionResponse;
      } else {
        response1.add(questionResponse);
      }

      _showExplanation = true; // Show explanation after selection
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }



  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading =
      false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        nickname = jsonData['user']['name'];
        userEmail = jsonData['user']['email'];
        contact = jsonData['user']['contact'].toString();
        // address = jsonData['user']['bio'];
        photoUrl = jsonData['user']['picture_data'];
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }
  // Create the data to send

  Future<void> sendQuestionData() async {
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
        if (kDebugMode) {
          print("Data sent successfully: ${response.body}");
        }
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (responseData.containsKey('plan')) {
          setState(() {
            plan = responseData['plan'];
          });
        }
        setState(() {

          Navigator.push(
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
        });



      } else {
        if (kDebugMode) {
          print("Failed to send data: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred: $e");
      }
    }
  }


  Future<void> hitPracticeApi({
    required int questionId,
    required int selectedOption,
    required int answer,
    required int subjectId,
  }) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // Define your API endpoint

    // Create the request body
    Map<String, dynamic> body = {
      'question_id': questionId,
      'selected_option': selectedOption,
      'answer': answer,
      'subject_id': subjectId,
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(addPracticeQuestion),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Send the token in the headers
        },
        body: jsonEncode(body), // Convert the body to JSON
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Successfully hit the API
        if (kDebugMode) {
          print('Success: ${response.body}');
        }
      } else {
        // Handle errors
        if (kDebugMode) {
          print('Failed: ${response.statusCode}, ${response.body}');
        }
      }
    } catch (e) {
      // Handle exceptions (like network issues)
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (paperList.isEmpty) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    final currentQuestion = paperList[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              // height: 150.sp,
              width: double.infinity,
              child: Opacity(
                opacity: 0.1, // Adjust the opacity value (0.0 to 1.0)
                child: Image.asset(logo),
              ),
            ),
          ),


          SingleChildScrollView(
            child: Column(
              children: [

                Container(
                  height: 30.sp,
                  color: primaryColor3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 2.sp,),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(5.sp),
                              child: Text(
                                'Total Question',
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            ' $_totalQuestions',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20.sp,),

                      Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 15.sp,
                              )),
                          Text(
                            ' $_correctAnswers',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20.sp,),

                      Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                border: Border.all(color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 15.sp,
                              )),
                          Text(
                            ' $_wrongAnswers',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.green,
                      //           border: Border.all(color: Colors.green),
                      //           borderRadius: BorderRadius.circular(5.0),
                      //         ),
                      //         child: Icon(
                      //           Icons.check_box,
                      //           color: Colors.white,
                      //           size: 15.sp,
                      //         )),
                      //     Text(
                      //       currentQuestion['answer'].toString(),
                      //       style: GoogleFonts.roboto(
                      //         textStyle: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16.sp,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 58.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (currentQuestion['question_image_url'] == null || currentQuestion['question'] != null)
                          Text(
                            '${_currentQuestionIndex + 1}. ${currentQuestion['question']}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        if (currentQuestion['question_image_url'] != null && currentQuestion['question'] == null)
                          Row(
                            children: [

                              Text(
                                '${_currentQuestionIndex + 1}.',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Image.network(
                                    currentQuestion['question_image_url'].toString(),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // if (currentQuestion['question_image_url'] != null && currentQuestion['question'] != null)
                        //   Text(
                        //     '${_currentQuestionIndex + 1}. ${currentQuestion['question']}',
                        //     style: TextStyle(
                        //       fontSize: 24,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.black,
                        //     ),
                        //   ),
                        if (currentQuestion['question_image_url'] != null &&
                            currentQuestion['question'] != null)
                          SizedBox(
                            height: 100.sp,
                            child: Image.network(
                              currentQuestion['question_image_url'].toString(),
                            ),
                          ),
                        SizedBox(height: 20),
                        Column(
                          children: (currentQuestion['options'] as List<dynamic>)
                              .asMap()
                              .entries
                              .map<Widget>((entry) {
                            int index = entry.key + 1;

                            String option = entry.value['text'].toString();
                            String optionImage = entry.value['image_url'].toString();

                            // Color buttonColor = Colors.white;
                            //
                            // if (_isAnswered) {
                            //   if (index == _correctIndex) {
                            //     buttonColor = Colors.green; // Correct answer turns green
                            //   } else if (index == _selectedIndex && index != _correctIndex) {
                            //     buttonColor = Colors.red; // Incorrect answer turns red
                            //   }
                            // }




                            bool isCorrect =
                            List<int>.from(currentQuestion['answer']).contains(index);
                            Color optionColor;

                            if (_isAnswered) {
                              if (_selectedIndex == index) {
                                optionColor = isCorrect ? Colors.green : Colors.red;
                              } else if (isCorrect) {
                                optionColor = Colors.green; // Mark correct answers
                              } else {
                                optionColor = Colors.transparent;
                              }
                            } else {
                              optionColor = Colors.transparent;
                            }


                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  _selectAnswer(index);
                                  hitPracticeApi(questionId: currentQuestion['id'], selectedOption: index, answer: currentQuestion['answer'], subjectId: currentQuestion['subject_id']);
                                  setState(() {
                                    _showExplanation = true; // Show explanation after answer is selected
                                  });
                                },
                                child: Stack(
                                  children: [
                                    if (entry.value['image_url'] == null)
                                      Container(
                                        // height: 50.sp,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.sp),
                                          color: optionColor,
                                          border: Border.all(
                                            color: HexColor('#ABB7B7'),
                                            width: 1.sp,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Padding(
                                              padding: EdgeInsets.only(left: 12.sp),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '$index. $option',
                                                  style: GoogleFonts.radioCanada(
                                                    textStyle: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Padding(
                                            //   padding: EdgeInsets.only(left: 12.sp),
                                            //   child: Text(
                                            //     '${index}.', // Update to show question number
                                            //     style: GoogleFonts.radioCanada(
                                            //       textStyle: TextStyle(
                                            //         fontSize: 15.sp,
                                            //         fontWeight: FontWeight.bold,
                                            //         color: Colors.black,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: EdgeInsets.only(left: 12.sp),
                                            //   child: Text(
                                            //     ' $option',
                                            //     style: GoogleFonts.radioCanada(
                                            //       textStyle: TextStyle(
                                            //         fontSize: 15.sp,
                                            //         fontWeight: FontWeight.normal,
                                            //         color: Colors.black,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    if (entry.value['text'] == null)
                                      Container(
                                        height: 100.sp,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.sp),
                                          color: optionColor,
                                          border: Border.all(
                                            color: HexColor('#ABB7B7'),
                                            width: 1.sp,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 12.sp),
                                              child: Text(
                                                '$index.', // Update to show question number
                                                style: GoogleFonts.radioCanada(
                                                  textStyle: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100.sp,
                                              child: Image.network(optionImage),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_showExplanation)
                          Column(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Explanation : - ',
                                    style: GoogleFonts.radioCanada(
                                      textStyle: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(currentQuestion['explanation'].toString()),
                                  if (currentQuestion['explanation_image'] != null)
                                    Image.network(currentQuestion['explanation_image'].toString()),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        height: 50.sp,
        color: Colors.white,
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),

                // Conditionally show the 'Previous' button only if index is greater than 0
                // if (_currentQuestionIndex > 0)
                //   Padding(
                //     padding: const EdgeInsets.all(0.0),
                //     child: GestureDetector(
                //       onTap: () {
                //         _previousQuestion();
                //       },
                //       child: Row(
                //         children: [
                //           Container(
                //             width: 100.sp,
                //             height: 40.sp,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(10.sp),
                //               color: ColorConstants.primaryColor,
                //             ),
                //             child: Center(
                //               child: Padding(
                //                 padding: EdgeInsets.all(5.sp),
                //                 child: Text(
                //                   '   Previous   ',
                //                   style: GoogleFonts.poppins(
                //                     textStyle: TextStyle(
                //                       fontSize: TextSizes.textmedium,
                //                       fontWeight: FontWeight.normal,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // if (_currentQuestionIndex > 0)
                //   Spacer(),

                // Always show the 'Next' button
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                    onTap: () {
                      _nextQuestion();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 100.sp,
                          height: 40.sp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            color: ColorConstants.primaryColor,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Text(
                                '   Next   ',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: TextSizes.textmedium,
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

                Spacer(),
              ],
            ),
          ],
        ),
      ),
      // endDrawer: Drawer(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(15.sp), // Only round top-left corner
      //       bottomLeft: Radius.circular(0.sp), // Only round top-right corner
      //     ),
      //   ),
      //   width: MediaQuery.sizeOf(context).width * .55,
      //   // backgroundColor: Theme.of(context).colorScheme.background,
      //   backgroundColor: Colors.white,
      //   child: Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: <Widget>[
      //           Padding(
      //             padding: EdgeInsets.only(top: 30.sp),
      //             child: Row(
      //               children: [
      //                 SizedBox(
      //                   width: 10.sp,
      //                 ),
      //                 ClipRRect(
      //                   borderRadius: BorderRadius.circular(25.sp),
      //                   child: SizedBox(
      //                     height: 50.sp,
      //                     width: 50.sp,
      //                     child: Image.network(
      //                       photoUrl.toString(),
      //                       fit: BoxFit.cover,
      //                       errorBuilder: (context, error, stackTrace) {
      //                         // Return a default image widget here
      //                         return Container(
      //                           color: Colors.grey,
      //                           // Placeholder color
      //                           // You can customize the default image as needed
      //                           child: Icon(
      //                             Icons.image,
      //                             color: Colors.white,
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   width: 10.sp,
      //                 ),
      //                 Container(
      //                   height: 50.sp,
      //                   child: Center(
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Padding(
      //                           padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
      //                           child: SizedBox(
      //                             height: 20.sp,
      //                             child: Text(
      //                               '${nickname}',
      //                               style: GoogleFonts.cabin(
      //                                 textStyle: TextStyle(
      //                                     color: Colors.black,
      //                                     fontSize: 19.sp,
      //                                     fontWeight: FontWeight.bold),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
      //                           child: Text(
      //                             "${userEmail}",
      //                             style: GoogleFonts.cabin(
      //                               textStyle: TextStyle(
      //                                   color: primaryColor,
      //                                   fontSize: 13.sp,
      //                                   fontWeight: FontWeight.normal),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.only(left: 8.sp, right: 8.sp, top: 8.sp),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Row(
      //                   children: [
      //                     Card(
      //                       color: Colors.green, // Set the card color to green
      //                       elevation: 1, // Adds shadow to the card
      //                       child: Padding(
      //                         padding: EdgeInsets.all(5.sp),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
      //                       child: SizedBox(
      //                         height: 20.sp,
      //                         child: Center(
      //                           child: Text(
      //                             'Current Question',
      //                             style: GoogleFonts.cabin(
      //                               textStyle: TextStyle(
      //                                   color: Colors.black,
      //                                   fontSize: 10.sp,
      //                                   fontWeight: FontWeight.normal),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 Row(
      //                   children: [
      //                     Card(
      //                       color: Colors.white, // Set the card color to green
      //                       elevation: 5, // Adds shadow to the card
      //                       child: Padding(
      //                         padding: EdgeInsets.all(5.sp),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
      //                       child: SizedBox(
      //                         height: 20.sp,
      //                         child: Center(
      //                           child: Text(
      //                             'Not Visited',
      //                             style: GoogleFonts.cabin(
      //                               textStyle: TextStyle(
      //                                   color: Colors.black,
      //                                   fontSize: 10.sp,
      //                                   fontWeight: FontWeight.normal),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.only(left: 8.sp, right: 8.sp, bottom: 8.sp),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Row(
      //                   children: [
      //                     Card(
      //                       color: Colors.grey, // Set the card color to green
      //                       elevation: 5, // Adds shadow to the card
      //                       child: Padding(
      //                         padding: EdgeInsets.all(5.sp),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
      //                       child: SizedBox(
      //                         height: 20.sp,
      //                         child: Center(
      //                           child: Text(
      //                             'Visited',
      //                             style: GoogleFonts.cabin(
      //                               textStyle: TextStyle(
      //                                   color: Colors.black,
      //                                   fontSize: 10.sp,
      //                                   fontWeight: FontWeight.normal),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.only(left: 0.sp, right: 0.sp, bottom: 8.sp),
      //             child: Divider(
      //               color: Colors.grey.shade300,
      //               // Set the color of the divider
      //               thickness: 2.0,
      //               // Set the thickness of the divider
      //               height: 1, // Set the height of the divider
      //             ),
      //           ),
      //
      //           Flexible(
      //             child: GridView.count(
      //               crossAxisCount: 4, // Number of items per row
      //               // crossAxisSpacing: 10.sp, // Space between columns
      //               // mainAxisSpacing: 10.sp, // Space between rows
      //               padding: EdgeInsets.zero, // Remove extra padding
      //               children: List.generate(paperList.length, (index) {
      //                 Color cardColor;
      //                 if (_currentQuestionIndex == index) {
      //                   cardColor = Colors.green; // Currently selected index
      //                 } else if (_selectedIndices.contains(index)) {
      //                   cardColor =
      //                       Colors.grey; // Clicked item (part of selected indices)
      //                 } else {
      //                   cardColor = Colors.white; // Default color
      //                 }
      //                 return SizedBox(
      //                   height: 30.sp,
      //                   width: 30.sp,
      //                   child: GestureDetector(
      //                     onTap: () {
      //                       setState(() {
      //                         _currentQuestionIndex =
      //                             index; // Update current question index
      //                         _showExplanation = false; // Reset explanation view
      //                         _isAnswered = false; // Reset answered state
      //                         // _selectedIndices.add(index); // Select the index
      //                         if (!_selectedIndices.contains(index)) {
      //                           _selectedIndices.add(index); // Select the index
      //                         }
      //
      //                         Navigator.pop(context);
      //                         // Toggle selection state
      //                         // if (_selectedIndices.contains(index)) {
      //                         //   _selectedIndices.remove(index); // Deselect if already selected
      //                         // } else {
      //                         //   _selectedIndices.add(index); // Select the index
      //                         // }
      //                       });
      //                     },
      //                     child: Card(
      //                       elevation: 5,
      //                       color: cardColor, // Set the card color
      //                       child: Center(
      //                           child: Text(
      //                             (index + 1).toString(),
      //                             style: TextStyle(fontSize: 20.sp),
      //                           )),
      //                     ),
      //                   ),
      //                 );
      //               }),
      //             ),
      //           ),
      //         ],
      //       )),
      // ),
    );
  }
}

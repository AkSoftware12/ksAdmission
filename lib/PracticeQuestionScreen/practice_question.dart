import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/Plan/plan.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../QuizTestScreen/quizResultPage.dart';
import '../Utils/app_colors.dart';
import '../Utils/color_constants.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class PracticeQuestionScreen extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final bool isLocked; // Declare variable to receive value

  const PracticeQuestionScreen(
      {super.key,
      required this.paperId,
      required this.papername,
      required this.exmaTime,
      required this.question,
      required this.marks, required this.isLocked});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<PracticeQuestionScreen> {
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 0;

  Timer? _timer;
  bool _isAnswered = false;
  int? _selectedIndex; // Store the index of the selected answer
  int? _correctIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
  List<int> _selectedIndices = [0];
  Map<int, int> selectedOptions = {};
  List<Map<String, dynamic>> response1 = []; // To store selected options


  int _questionsAttemptedToday = 0; // Track number of questions attempted
  DateTime? _lastAttemptTime; // Store last attempt time
  bool _canAttemptMore = true; // Flag to check if user can attempt more

  @override
  void initState() {
    super.initState();
    startTimer();
    fetchProfileData();
    _secondsRemaining = minutesToSeconds(widget.exmaTime);
    hitQuestionApi();
    checkQuestionAttemptTime();

  }

  int minutesToSeconds(int minutes) {
    return minutes * 60;
  }



  Future<void> hitQuestionApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${practiceQuestion}'), // Replace with your API URL
      headers: {
        'Authorization': 'Bearer $token', // Pass token in headers
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          if (responseData['data'] == null || responseData['data'].isEmpty) {
            paperList = [];
            showUpgradeDialog(context);
          } else {
            paperList = responseData['data'];
          }
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }

    } else {
      throw Exception('Failed to load data');
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
  /// ✅ **Check if the user has attempted questions in the last 24 hours**
  Future<void> checkQuestionAttemptTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int lastAttemptTimestamp = prefs.getInt('last_attempt_time') ?? 0;
    _questionsAttemptedToday = prefs.getInt('questions_attempted') ?? 0;

    if (lastAttemptTimestamp != 0) {
      _lastAttemptTime = DateTime.fromMillisecondsSinceEpoch(lastAttemptTimestamp);

      // Calculate if 24 hours have passed since last attempt
      if (DateTime.now().difference(_lastAttemptTime!).inHours >= 24) {
        // Reset the counter if 24 hours have passed
        await prefs.setInt('questions_attempted', 0);
        _questionsAttemptedToday = 0;
        _canAttemptMore = true;
      } else {
        // Otherwise, check if they already attempted 10 questions
        if (_questionsAttemptedToday >= 10 && widget.isLocked) {
          _canAttemptMore = false;

          showUpgradeDialog(context);

          // redirectToPlanScreen();
        }
      }
    }
  }

  /// ✅ **Navigate to Plan Screen if limit is reached**
  void redirectToPlanScreen() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PlanScreen(appBar: 'Upgrade Plan')),
      );
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

        if (!_selectedIndices.contains(_currentQuestionIndex)) {
          _selectedIndices.add(_currentQuestionIndex); // Select the index
        }

        // Check if current question is the 10th and isLocked is true
        if (_currentQuestionIndex == 9 && widget.isLocked) {

          showUpgradeDialog(context);


        }
      });
    } else {
      // You can navigate to a summary screen or show an alert that the quiz is finished
      print("Quiz Completed");
    }
  }

  /// ✅ **Move to Next Question (Check Attempt Limit)**




  String get formattedTime {
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }









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
        void showUpgradeDialog(BuildContext context) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                        'https://cdn-icons-png.flaticon.com/512/7269/7269950.png', // Replace with your subscription image
                        height: 100,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Your Daily Limit Has Been Reached!",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => PlanScreen(appBar: 'appBar')),
                              );                      },
                            child: Text("Subscribe Now", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pop(true); // Exit the app

                            },
                            child: Text("Back to Home", style: TextStyle(color: Colors.red, fontSize: 16)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }


        @override
        void dispose() {
          _timer?.cancel();
          super.dispose();
        }

        void _refresh() {
          setState(() {
            fetchProfileData();
          });
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
              photoUrl = jsonData['user']['picture_data'].toString();
            });
          } else {
            throw Exception('Failed to load profile data');
          }
        }

        // Create the data to send

        Future<void> sendQuestionData() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? userId = prefs.getString(
            'id',
          );
          final String? token = prefs.getString(
            'token',
          );

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
                      total_negative_marks:
                      jsonData['total_negative_marks'].toString(),
                      wrongquestion: jsonData['wrongquestion'],
                      total_marks: jsonData['total_marks'],
                    ),
                  ),
                );
              });
            } else {
              print("Failed to send data: ${response.statusCode}");
            }
          } catch (e) {
            print("Error occurred: $e");
          }
        }

        Future<void> hitPracticeApi({
          required int questionId,
          required int selectedOption,
          // required int answer,
          required int subjectId,
        }) async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? token = prefs.getString('token');

          // Define your API endpoint

          // Create the request body
          Map<String, dynamic> body = {
            'question_id': questionId,
            'selected_option': selectedOption,
            // 'answer': answer,
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
              print('Success: ${response.body}');
            } else {
              // Handle errors
              print('Failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle exceptions (like network issues)
      print('Error: $e');
    }
  }


  Future<bool> showExitPopup(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔴 Icon
              Icon(
                Icons.exit_to_app_rounded,
                size: 36,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 14),

              /// 📝 Title
              const Text(
                "Exit Practice Question",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              /// 💬 Message
              const Text(
                "Do you really want to exit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 22),

              /// 🔘 Buttons
              Row(
                children: [
                  /// NO
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// YES
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:  HexColor('#010071'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (paperList.isEmpty) {
      return Scaffold(
        // backgroundColor: primaryColor,
        backgroundColor:  HexColor('#010071'),
        body: Center(
          child: PrimaryCircularProgressWidget(
          ),
        ),
      );
    }

    final currentQuestion = paperList[_currentQuestionIndex];
    final correctAnswer = currentQuestion['answer'];

    return  SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) =>  WillPopScope(
        onWillPop: () async => showExitPopup(context),

        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF010071),
                    Color(0xFF0A1AFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              'Practice Question 24/7', // ✅ dynamic
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

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

                            if ( currentQuestion['question_image_url']!=null)
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
                                        height: 50.sp,
                                        // width: double.infinity,
                                        child: Image.network( currentQuestion['question_image_url'].toString(),)),
                                  ),
                                ],
                              ), // Display Question Image
                            if (currentQuestion['question']!='')
                              Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: (currentQuestion['question']!=null)? Text('${currentQuestion['question']}'
                                    ,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ):Text('')
                              ),



                            // if (currentQuestion['question_image_url']!=null)
                            //   Image.network(currentQuestion['question_image_url'].toString(),), // Display Question Image
                            // if (currentQuestion['question']!=null)
                            //   Padding(
                            //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //     child: Text(
                            //       currentQuestion['question'],
                            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            //     ),
                            //   ),
                            // SizedBox(height: 20),
                            //


                            // if (currentQuestion['question_image_url'] == null ||
                            //     currentQuestion['question'] != null)
                            //   Text(
                            //     '${_currentQuestionIndex + 1}. ${currentQuestion['question']}',
                            //     style: TextStyle(
                            //       fontSize: 16.sp,
                            //       fontWeight: FontWeight.normal,
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            // if (currentQuestion['question_image_url'] != null &&
                            //     currentQuestion['question'] == null)
                            //   Row(
                            //     children: [
                            //       Text(
                            //         '${_currentQuestionIndex + 1}.',
                            //         style: TextStyle(
                            //           fontSize: 20.sp,
                            //           fontWeight: FontWeight.normal,
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //       Expanded(
                            //         child: SizedBox(
                            //           width: double.infinity,
                            //           child: Container(
                            //             child: Image.network(
                            //               currentQuestion['question_image_url']
                            //                   .toString(),
                            //               fit: BoxFit.fill,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            //
                            // if (currentQuestion['question_image_url'] != null &&
                            //     currentQuestion['question'] != null)
                            //   SizedBox(
                            //     height: 100.sp,
                            //     child: Image.network(
                            //       currentQuestion['question_image_url'].toString(),
                            //     ),
                            //   ),
                            SizedBox(height: 20),
                            Column(
                              children:
                              (currentQuestion['options'] as List<dynamic>)
                                  .asMap()
                                  .entries
                                  .map<Widget>((entry) {
                                int index = entry.key + 1;

                                String option = entry.value['text'].toString();
                                String optionImage =
                                entry.value['image_url'].toString();


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
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _selectAnswer(index);
                                      hitPracticeApi(
                                          questionId: currentQuestion['id'],
                                          selectedOption: index,
                                          // answer: currentQuestion['answer'],
                                          subjectId: currentQuestion['subject_id']);
                                      setState(() {
                                        _showExplanation =
                                        true; // Show explanation after answer is selected
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        // if (entry.value['image_url'] == null)
                                        //   Container(
                                        //     // height: 50.sp,
                                        //     width: double.infinity,
                                        //     decoration: BoxDecoration(
                                        //       borderRadius:
                                        //       BorderRadius.circular(5.sp),
                                        //       color: optionColor,
                                        //       border: Border.all(
                                        //         color: HexColor('#ABB7B7'),
                                        //         width: 1.sp,
                                        //       ),
                                        //     ),
                                        //     child: Column(
                                        //       mainAxisAlignment:
                                        //       MainAxisAlignment.start,
                                        //       crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //       children: [
                                        //         Padding(
                                        //           padding:
                                        //           EdgeInsets.only(left: 12.sp),
                                        //           child: Padding(
                                        //             padding:
                                        //             const EdgeInsets.all(8.0),
                                        //             child: Text(
                                        //               '${index}. $option',
                                        //               style:
                                        //               GoogleFonts.radioCanada(
                                        //                 textStyle: TextStyle(
                                        //                   fontSize: 15.sp,
                                        //                   fontWeight:
                                        //                   FontWeight.normal,
                                        //                   color: Colors.black,
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         ),
                                        //
                                        //         // Padding(
                                        //         //   padding: EdgeInsets.only(left: 12.sp),
                                        //         //   child: Text(
                                        //         //     '${index}.', // Update to show question number
                                        //         //     style: GoogleFonts.radioCanada(
                                        //         //       textStyle: TextStyle(
                                        //         //         fontSize: 15.sp,
                                        //         //         fontWeight: FontWeight.bold,
                                        //         //         color: Colors.black,
                                        //         //       ),
                                        //         //     ),
                                        //         //   ),
                                        //         // ),
                                        //         // Padding(
                                        //         //   padding: EdgeInsets.only(left: 12.sp),
                                        //         //   child: Text(
                                        //         //     ' $option',
                                        //         //     style: GoogleFonts.radioCanada(
                                        //         //       textStyle: TextStyle(
                                        //         //         fontSize: 15.sp,
                                        //         //         fontWeight: FontWeight.normal,
                                        //         //         color: Colors.black,
                                        //         //       ),
                                        //         //     ),
                                        //         //   ),
                                        //         // ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // if (entry.value['text'] == null)
                                        //   Container(
                                        //     height: 100.sp,
                                        //     width: double.infinity,
                                        //     decoration: BoxDecoration(
                                        //       borderRadius:
                                        //       BorderRadius.circular(5.sp),
                                        //       color: optionColor,
                                        //       border: Border.all(
                                        //         color: HexColor('#ABB7B7'),
                                        //         width: 1.sp,
                                        //       ),
                                        //     ),
                                        //     child: Row(
                                        //       children: [
                                        //         Padding(
                                        //           padding:
                                        //           EdgeInsets.only(left: 12.sp),
                                        //           child: Text(
                                        //             '${index}.',
                                        //             // Update to show question number
                                        //             style: GoogleFonts.radioCanada(
                                        //               textStyle: TextStyle(
                                        //                 fontSize: 17.sp,
                                        //                 fontWeight: FontWeight.bold,
                                        //                 color: Colors.grey,
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         ),
                                        //         SizedBox(
                                        //           height: 100.sp,
                                        //           child: Image.network(optionImage),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        //

                                        if (entry.value['image_url'] != null)
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
                                                    '${index}.', // Update to show question number
                                                    style: GoogleFonts.radioCanada(
                                                      textStyle: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 50.sp,
                                                  child: Image.network(optionImage),
                                                ),
                                              ],
                                            ),
                                          ),

                                        if (entry.value['text'] != "")


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
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Padding(
                                                    padding: EdgeInsets.only(left: 1.sp),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child:   Text.rich(TextSpan(
                                                        text: '${index}.   ',
                                                        style: GoogleFonts.notoSans(
                                                          textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold,color: Colors.black),
                                                        ),
                                                        children: <TextSpan>[

                                                          TextSpan(
                                                            text: '$option',
                                                            style: GoogleFonts.notoSans(
                                                              textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal,color: Colors.black),
                                                            ),
                                                          )
                                                        ],
                                                      )),



                                                      // Text(
                                                      //   '${index}. $option',
                                                      //   style: GoogleFonts.radioCanada(
                                                      //     textStyle: TextStyle(
                                                      //       fontSize: 15.sp,
                                                      //       fontWeight: FontWeight.normal,
                                                      //       color: Colors.black,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ),
                                                  ),


                                                ],
                                              ),
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
                                        '${'Explanation : - '}',
                                        style: GoogleFonts.radioCanada(
                                          textStyle: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                          '${currentQuestion['explanation'].toString()}'),
                                      if (currentQuestion['explanation_image'] !=
                                          null)
                                        Image.network(
                                            currentQuestion['explanation_image']
                                                .toString()),
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
                                color: HexColor('#010071'),
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

        ),
      ),
    );


  }
}

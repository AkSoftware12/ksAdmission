import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:realestate/QuizTestScreen/quizResultPage.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../HexColorCode/HexColor.dart';
import '../../HomePage/home_page.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/color_constants.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';
import '../OMR/omr_sheet.dart';


class NewExamMockQuizScreen extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final String endTime;
  final String type;


  const NewExamMockQuizScreen(
      {super.key,
      required this.paperId,
      required this.papername,
      required this.exmaTime, required this.question, required this.marks, required this.type, required this.endTime, });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<NewExamMockQuizScreen> {
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 0;

  Timer? _timer;
  bool _isAnswered = false;
  int? _selectedIndex; // Store the index of the selected answer
  int? _correctIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();




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
  Timer? _endTimeCheckTimer;


  @override
  void initState() {
    super.initState();
    startTimer(widget.endTime);
    fetchProfileData();
    _secondsRemaining =minutesToSeconds(widget.exmaTime);
    hitQuestionApi();

    _endTimeCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkEndTime(); // Check end time every minute
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

  void startTimer(String endTimeStr) {
    // Parse the endTime string into a DateTime object
    DateTime now = DateTime.now();
    List<String> timeParts = endTimeStr.split(':');
    DateTime endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      int.parse(timeParts[2]),
    );

    // Calculate the initial remaining time
    _secondsRemaining = endTime.difference(now).inSeconds;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        DateTime currentTime = DateTime.now();
        if (currentTime.isBefore(endTime)) {
          // Decrease remaining time in seconds
          _secondsRemaining = endTime.difference(currentTime).inSeconds;
        } else {
          timer.cancel();
          // Navigate to OMRUploader screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OMRUploader(),
            ),
          );
        }
      });
    });
  }

  void checkEndTime() {
    DateTime now = DateTime.now();

    // Parse the end time into a DateTime object (only time part)
    DateTime endTime = DateFormat('HH:mm:ss').parse(widget.endTime);

    // Set the parsed end time to today’s date for a proper comparison
    endTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute, endTime.second);

    print('END TIME ${widget.endTime}');  // Ensure the end time is in the correct format
    print('Current TIME ${now}');

    // Compare the current time with the end time
    if (now.isAfter(endTime)) {
      print('Exam ENDed ${now}');
      _closePaper(); // Close the exam if the current time exceeds the end time
    }
  }

  void _closePaper() {
    // Logic to close the paper, like navigating to a result page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OMRUploader()),
    );
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

  void _showQuizCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Completed'),
        content: Text('You have completed the quiz!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // You can add navigation or any other action after the quiz ends
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // You can add navigation or any other action after the quiz ends
            },
            child: Text('cancel'),
          ),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _isAnswered = false;
        _selectedIndex = null;
        _correctIndex = null;
        _currentQuestionIndex--;
        _showExplanation = false;
        // startTimer();

        if (!_selectedIndices.contains(_currentQuestionIndex)) {
          _selectedIndices.add(_currentQuestionIndex); // Select the index
        }
      });
    }
  }

  // void _selectAnswer(int index) {
  //   if (_isAnswered) return;
  //
  //   final currentQuestion = paperList[_currentQuestionIndex];
  //   final correctAnswerIndex =
  //       currentQuestion['answer']; // Fetch correct answer index
  //
  //   setState(() {
  //     _selectedIndex = index;
  //     _correctIndex = correctAnswerIndex;
  //     _isAnswered = true;
  //     // _timer?.cancel(); // Stop the timer when the question is answered
  //   });
  //
  //   // Move to the next question after a short delay
  //   // Future.delayed(Duration(seconds: 2), _nextQuestion);
  // }


  String get formattedTime {
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }



  void _selectAnswer(int selectedIndex) {
    final currentQuestion = paperList[_currentQuestionIndex];
    final correctAnswerIndex = currentQuestion['answer'] is List
        ? currentQuestion['answer'][0]
        : currentQuestion['answer'];

    setState(() {
      _selectedIndex = selectedIndex;
      _correctIndex = correctAnswerIndex;
      _isAnswered = true;
      _showExplanation = true; // Show explanation after selection

      // Update the response with the selected option
      Map<String, dynamic> questionResponse = {
        "question_id": currentQuestion['id'],
        "selected_option": selectedIndex
      };

      // Check if the question already exists in the response list and update
      int existingIndex = response1.indexWhere((element) =>
      element['question_id'] == currentQuestion['id']);
      if (existingIndex != -1) {
        // Update the existing selected option
        response1[existingIndex]['selected_option'] = selectedIndex;
      } else {
        // Add the selected option if it's not already in the list
        response1.add(questionResponse);
      }
    });
  }

  // void _selectAnswer(int selectedIndex) {
  //   if (_isAnswered) return;
  //
  //   final currentQuestion = paperList[_currentQuestionIndex];
  //   final correctAnswerIndex =
  //   currentQuestion['answer'] is List ? currentQuestion['answer'][0] : currentQuestion['answer'];
  //
  //   setState(() {
  //     _selectedIndex = selectedIndex;
  //     _correctIndex = correctAnswerIndex;
  //     _isAnswered = true;
  //   });
  //
  //   Map<String, dynamic> questionResponse = {
  //     "question_id": currentQuestion['id'],
  //     "selected_option": selectedIndex,
  //   };
  //
  //   int existingIndex = response1.indexWhere(
  //           (element) => element['question_id'] == currentQuestion['id']);
  //   if (existingIndex != -1) {
  //     response1[existingIndex] = questionResponse;
  //   } else {
  //     response1.add(questionResponse);
  //   }
  //
  //   setState(() {
  //     _showExplanation = true;
  //   });
  // }


  @override
  void dispose() {
    _timer?.cancel();
    _endTimeCheckTimer?.cancel();

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
        photoUrl = jsonData['user']['picture_data'];
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }
  // Create the data to send

  Future<void> sendQuestionData() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
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

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Homepage()),
          // );

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
        body:WhiteCircularProgressWidget()
      );
    }

    final currentQuestion = paperList[_currentQuestionIndex];
    final correctAnswer = currentQuestion['answer'];

    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => WillPopScope(
        onWillPop: () async {
          // Prevent the screen from going back
          return false;
        },
        // onWillPop: () async => showExitPopup(context),
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
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(
                      Icons.dialpad,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
              // Padding(
              //   padding:  EdgeInsets.only(right: 5.sp),
              //   child: GestureDetector(
              //     onTap: () {
              //       sendQuestionData();
              //     },
              //     child: Row(
              //       children: [
              //         Container(
              //           height: 30.sp,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10.sp),
              //             color: Colors.green,
              //           ),
              //           child: Center(
              //             child: Padding(
              //               padding: EdgeInsets.all(5.sp),
              //               child: Text(
              //                 'SUBMIT',
              //                 style: GoogleFonts.poppins(
              //                   textStyle: TextStyle(
              //                     fontSize: TextSizes.textmedium,
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),


            ],

          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
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
                                  child: Container(
                                    width: double.infinity,
                                    child: Image.network(
                                      currentQuestion['question_image_url'].toString(),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

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

                            Color buttonColor = Colors.white;
                            Color borderColor = HexColor('#ABB7B7'); // Default border color

                            // Change border color to green when the answer is selected
                            if (index == _selectedIndex) {
                              borderColor = Colors.green;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   _selectAnswer(index); // Update selected index
                                  //   _selectedIndex = index; // Store the selected index
                                  //   print(response1);
                                  //
                                  // });
                                },
                                child: Stack(
                                  children: [
                                    if (entry.value['image_url'] == null)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.sp),
                                          color: buttonColor,
                                          border: Border.all(
                                            color: borderColor, // Apply the updated border color
                                            width: 2.sp,
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
                                                  '${index}. $option',
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
                                          ],
                                        ),
                                      ),
                                    if (entry.value['text'] == null)
                                      Container(
                                        height: 100.sp,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.sp),
                                          color: buttonColor,
                                          border: Border.all(
                                            color: borderColor, // Apply the updated border color
                                            width: 2.sp,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 12.sp),
                                              child: Text(
                                                '${index}.', // Show question number
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
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

                    // Conditionally show the 'Previous' button only if the index is greater than 0
                    if (_currentQuestionIndex > 0)
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: GestureDetector(
                          onTap: () {
                            _previousQuestion();
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
                                      '   Previous   ',
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
                                  child: Text(' Skip'  // Show 'Submit' on the last question
                                        ,   // Show 'Next' on all other questions
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

                    // Conditionally show the 'Next' or 'Submit' button based on the question index
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

                                       // Show 'Submit' on the last question
                                         ' Next ',   // Show 'Next' on all other questions
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
                )

              ],
            ),
          ),
          endDrawer: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.sp), // Only round top-left corner
                bottomLeft: Radius.circular(0.sp), // Only round top-right corner
              ),
            ),
            width: MediaQuery.sizeOf(context).width * .55,
            // backgroundColor: Theme.of(context).colorScheme.background,
            backgroundColor: Colors.white,
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.sp),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10.sp,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25.sp),
                            child: SizedBox(
                              height: 40.sp,
                              width: 40.sp,
                              child: Image.network(
                                photoUrl.toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Return a default image widget here
                                  return Container(
                                    color: Colors.grey,
                                    // Placeholder color
                                    // You can customize the default image as needed
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.sp,
                          ),
                          Container(
                            height: 50.sp,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                                    child: SizedBox(
                                      height: 20.sp,
                                      child: Text(
                                        '${nickname}',
                                        style: GoogleFonts.cabin(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                                    child: Text(
                                      "${userEmail}",
                                      maxLines: 1,
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: primaryColor,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.sp, right: 8.sp, top: 8.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Card(
                                color: Colors.green, // Set the card color to green
                                elevation: 1, // Adds shadow to the card
                                child: Padding(
                                  padding: EdgeInsets.all(5.sp),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                                child: SizedBox(
                                  height: 20.sp,
                                  child: Center(
                                    child: Text(
                                      'Current Question',
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Card(
                                color: Colors.white, // Set the card color to green
                                elevation: 5, // Adds shadow to the card
                                child: Padding(
                                  padding: EdgeInsets.all(5.sp),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                                child: SizedBox(
                                  height: 20.sp,
                                  child: Center(
                                    child: Text(
                                      'Not Visited',
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal),
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
                    Padding(
                      padding: EdgeInsets.only(left: 8.sp, right: 8.sp, bottom: 8.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Card(
                                color: Colors.grey, // Set the card color to green
                                elevation: 5, // Adds shadow to the card
                                child: Padding(
                                  padding: EdgeInsets.all(5.sp),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp, right: 8.sp),
                                child: SizedBox(
                                  height: 20.sp,
                                  child: Center(
                                    child: Text(
                                      'Visited',
                                      style: GoogleFonts.cabin(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal),
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
                    Padding(
                      padding: EdgeInsets.only(left: 0.sp, right: 0.sp, bottom: 8.sp),
                      child: Divider(
                        color: Colors.grey.shade300,
                        // Set the color of the divider
                        thickness: 2.0,
                        // Set the thickness of the divider
                        height: 1, // Set the height of the divider
                      ),
                    ),

                    Flexible(
                      child: GridView.count(
                        crossAxisCount: 4, // Number of items per row
                        padding: EdgeInsets.zero, // Remove extra padding
                        children: List.generate(paperList.length, (index) {
                          Color cardColor;
                          if (_currentQuestionIndex == index) {
                            cardColor = Colors.green; // Currently selected index
                          } else if (_selectedIndices.contains(index)) {
                            cardColor = Colors.grey; // Clicked item (part of selected indices)
                          } else {
                            cardColor = Colors.white; // Default color
                          }
                          return SizedBox(
                            height: 30.sp,
                            width: 30.sp,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = null; // Reset selected index
                                  _correctIndex = null; // Reset correct index
                                  _currentQuestionIndex = index; // Update current question index
                                  _isAnswered = false; // Reset answered state

                                  // If the index is not already selected, add it
                                  if (!_selectedIndices.contains(index)) {
                                    _selectedIndices.add(index); // Select the index
                                  }

                                  Navigator.pop(context);
                                });
                              },
                              child: Card(
                                elevation: 5,
                                color: cardColor, // Set the card color
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(fontSize: 20.sp),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                )),
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
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../QuizTestScreen/quiztest.dart';
import '../QuizTestScreen/quiztest_all_question_mock.dart';
import '../QuizTestScreen/quiztest_mock.dart';
import '../Utils/app_colors.dart';
import '../Utils/color_constants.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';

class InstructionPage extends StatefulWidget {
  final int paperId;
  final int exmaTime;
  final String papername;
  final String question;
  final String marks;
  final String type;

  const InstructionPage({
    super.key,
    required this.paperId,
    required this.exmaTime,
    required this.papername,
    required this.question,
    required this.marks,
    required this.type,
  });

  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  String? _selectedOption = 'one_by_one';

  final String htmlData = """
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Common Exam Instructions</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.8;
            margin: 0px;
            padding: 0px;
            background-color: #f4f4f9;
            color: #333;
        }

        h1 {
            text-align: center;
            color: #444;
            font-size: 1.8rem;
        }

        ul {
            list-style-type:disc;
            margin: 0px 0px 5px 10px ;
            padding: 0;
        }

        li {
            margin-bottom: 0px;
        }

        .important {
            color: red;
            font-weight: bold;
        }

       
    </style>
</head>

<body>
    <ul>
        <li>Carry a valid photo ID proof (e.g., Aadhaar Card, PAN Card, Passport, or Voter ID) along with the admit
            card. <br> मान्य फोटो पहचान पत्र (जैसे आधार कार्ड, पैन कार्ड, पासपोर्ट, या मतदाता पहचान पत्र) और प्रवेश पत्र
            साथ लाएं।</li>
        <li>Ensure to arrive at the exam center at least 30 minutes before the reporting time. <br> परीक्षा केंद्र पर
            रिपोर्टिंग समय से कम से कम 30 मिनट पहले पहुंचें।</li>
        <li>Electronic devices such as mobile phones, smartwatches, calculators, and any other communication devices are
            strictly prohibited inside the examination hall. <br> मोबाइल फोन, स्मार्टवॉच, कैलकुलेटर और अन्य इलेक्ट्रॉनिक
            उपकरण परीक्षा कक्ष में सख्त वर्जित हैं।</li>
        <li>Only blue or black ballpoint pens are allowed unless specified otherwise. <br> केवल नीले या काले बॉल प्वाइंट
            पेन का उपयोग करें, जब तक कि अन्यथा निर्दिष्ट न किया गया हो।</li>
        <li>Do not bring any blank paper or books to the exam hall. Rough work should be done in the space provided in
            the question booklet. <br> परीक्षा कक्ष में कोई भी खाली कागज या किताब न लाएं। रफ कार्य प्रश्न पुस्तिका में
            प्रदान की गई जगह पर करें।</li>
        <li>Follow the seating plan assigned at the examination center. / परीक्षा केंद्र पर आवंटित बैठने की योजना का
            पालन करें।</li>
        <li>Impersonation or cheating of any kind will lead to disqualification and legal action. <br> कोई भी नकल या
            धोखाधड़ी अयोग्यता और कानूनी कार्रवाई का कारण बनेगी।</li>
        <li>Keep your admit card safe throughout the examination and produce it on request by invigilators. <br> अपना
            प्रवेश पत्र पूरे परीक्षा के दौरान सुरक्षित रखें और परीक्षक के अनुरोध पर दिखाएं।</li>
        <li>Any misbehavior with staff or candidates will result in immediate disqualification. <br> कर्मचारियों या
            उम्मीदवारों के साथ किसी भी प्रकार का दुर्व्यवहार तत्काल अयोग्यता का कारण बनेगा।</li>
        <li>Read all the instructions mentioned on the question paper carefully before starting the exam. <br> परीक्षा शुरू
            करने से पहले प्रश्न पत्र में दिए गए सभी निर्देशों को ध्यान से पढ़ें।</li>
        <li><span class="important">Once the exam is over, do not take the question paper, answer sheet, or rough sheets
                outside the hall. <br> परीक्षा समाप्त होने के बाद, प्रश्न पत्र, उत्तर पुस्तिका या रफ शीट्स को कक्ष से बाहर
                न ले जाएं।</span></li>
        <li>Maintain silence and discipline during the examination. <br> परीक्षा के दौरान शांति और अनुशासन बनाए रखें।</li>
        <li>Follow all COVID-19 guidelines (if applicable), such as wearing masks, maintaining social distancing, and
            using hand sanitizer. <br> सभी COVID-19 दिशानिर्देशों का पालन करें (यदि लागू हो), जैसे मास्क पहनना, सामाजिक
            दूरी बनाए रखना और हैंड सैनिटाइजर का उपयोग करना।</li>
    </ul>
</body>

</html>

  """;

  double _progressValue = 0.0; // Progress bar value
  Timer? _timer; // Timer to update progress
  int _duration = 10; // Duration of the timer in seconds

  @override
  void initState() {
    super.initState();
    // _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _progressValue += 0.01; // Increment progress value
        if (_progressValue >= 1.0) {
          _timer?.cancel(); // Stop the timer
          _navigateToNextScreen(); // Call the method to navigate
        }
      });
    });
  }

  void _navigateToNextScreen() {
    if (widget.type == 'solvedPaper') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            paperId: widget.paperId,
            papername: widget.papername,
            exmaTime: widget.exmaTime != null ? widget.exmaTime as int : 0,
            question: widget.question,
            marks: widget.marks,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MockQuizScreen(
            paperId: widget.paperId,
            papername: widget.papername,
            exmaTime: widget.exmaTime != null ? widget.exmaTime as int : 0,
            question: widget.question,
            marks: widget.marks,
            type: '',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'General Instructions',
                    style: GoogleFonts.cabin(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    ' सामान्य निर्देश',
                    style: GoogleFonts.cabin(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 18.sp, top: 0.sp),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close, size: 25.sp, color: Colors.black),
                ),
              ),
            ],
          ),

          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 140.sp),
                      child: Html(data: htmlData),
                    ),
                  ],
                ),
              ),

              // SingleChildScrollView(
              //   child: SizedBox(
              //     // height: 150.sp,
              //     width: double.infinity,
              //     child: Opacity(
              //       opacity: 0.1, // Adjust the opacity value (0.0 to 1.0)
              //       child: Image.asset(logo),
              //     ),
              //   ),
              // ),
            ],
          ),
          bottomSheet: Container(
            height: 140.sp,
            color: Colors.white,
            child: Column(
              children: [
                // Adding Radio buttons for "One by One" and "All Questions"
                Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Radio<String>(
                        value: 'one_by_one',
                        groupValue: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                        activeColor:
                            primaryColor, // Set the selected color to black
                      ),
                      Text(
                        'One by One Question',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: TextSizes.textsmall,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Radio<String>(
                        value: 'all_questions',
                        groupValue: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                      Text(
                        'All Questions',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: TextSizes.textsmall,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);

                          if (_selectedOption == 'all_questions') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllQuestionMockQuizScreen(
                                  paperId: widget.paperId,
                                  papername: widget.papername,
                                  exmaTime: widget.exmaTime != null
                                      ? widget.exmaTime as int
                                      : 0,
                                  question: widget.question,
                                  marks: widget.marks,
                                  type: widget.type,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MockQuizScreen(
                                  paperId: widget.paperId,
                                  papername: widget.papername,
                                  exmaTime: widget.exmaTime != null
                                      ? widget.exmaTime as int
                                      : 0,
                                  question: widget.question,
                                  marks: widget.marks,
                                  type: widget.type,
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 150.sp,
                              height: 40.sp,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.sp),
                                color: ColorConstants
                                    .primaryColor, // Set your desired color
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 35.sp,
                                    right: 35.sp,
                                  ),
                                  child: Text(
                                    ' Continue',
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

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class FaqScreen extends StatefulWidget {
  final String appBar;

  const FaqScreen({super.key, required this.appBar});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> faqData = [
    {
      "question": "What types of quizzes are available on the app?",
      "answer":
      "Our app offers a variety of quizzes, including Mock Tests, Test Series, Daily Quizzes, and Practice Tests. Each type is designed to help you improve in specific areas and track your progress effectively.",
    },
    {
      "question": "How do I start a quiz?",
      "answer":
      "To start a quiz, go to the Quizzes section, select the type of quiz you're interested in, and choose a specific quiz from the list. Then, click on the Start Quiz button to begin.",
    },
    {
      "question": "How are scores calculated?",
      "answer":
      "Scores are calculated based on correct answers, with negative marking applied to incorrect answers where applicable. Your overall performance score is also calculated using a weighted formula across mock tests, test series, quizzes, and practice questions.",
    },
    {
      "question": "Where can I see my subject combination?",
      "answer":
      "Your chosen subject combination is saved in your profile, and you can view or modify it in the Subject Selection section.",
    },
    {
      "question":
      "Your chosen subject combination is saved in your profile, and you can view or modify it in the Subject Selection section.",
      "answer":
      "The overall performance score is a weighted average based on mock tests (30%), test series (20%), daily quizzes (20%), practice questions (20%), and app activity (10%). The score is capped at 80% to maintain fair grading.",
    }
  ];


  List<dynamic> faqlist = [];



  Future<void> hitFaqList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse("${faq}"),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          faqlist = responseData['data'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    hitFaqList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar.isEmpty
          ? null
          :  AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title:  Text("FAQ",
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),

        ),
      ),


      body: Stack(
        children: [
          Center(
            child: SizedBox(
              child: Opacity(
                opacity: 0.1, // Adjust the opacity value (0.0 to 1.0)
                child: Image.asset(logo),
              ),
            ),
          ),

          ListView.builder(
            itemCount: faqlist.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.blueGrey.shade50,
                child: ExpansionTile(
                  title: Text(
                    faqlist[index]['question']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Container(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(faqlist[index]['answer']!,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: TextSizes.textsmall,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),),
                      ),
                    ),
                  ],
                  trailing: Icon(Icons.arrow_drop_down), // Arrow icon
                  initiallyExpanded: index == 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



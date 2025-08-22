import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../CombinationSubjectList/combinatoin_subject_list.dart';
import '../../CombinationTest/combination_test.dart';
import '../../Utils/app_colors.dart';
import '../../baseurl/baseurl.dart';
import 'MockTest/mock_test.dart';
import 'SubjectScreen/subject_main_screen.dart';
import 'Test/test_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class Yearpage extends StatefulWidget {
  final String title;
  final int categoeyId;
  final int subcategoeyId;
  final int? stateId;
  final int initialIndex;
  final String type;
  final String planstatus;

  const Yearpage({
    super.key,
    required this.title,
    required this.categoeyId,
    required this.subcategoeyId,
    required this.initialIndex,
    required this.type,
    required this.stateId,
    required this.planstatus,
  });

  @override
  State<Yearpage> createState() => _YearpageState();
}

class _YearpageState extends State<Yearpage> {
  int _selectedIndex = 0;

  String combination = '';
  List<dynamic> banner = [];

  TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    hitAllCategory();
    _selectedIndex = widget.initialIndex; // Set the initial tab index
  }

  _getPage(int page) {
    switch (page) {
      // case 0:
      //   return YearScreen(
      //     title: widget.title,
      //     categoryId: widget.categoeyId,
      //     subcategoryId: widget.subcategoeyId,
      //     stateId: widget.stateId,
      //   );
      case 0:
        return SubjectMainScreen(
          title: widget.title,
          categoryId: widget.categoeyId,
          stateId: widget.stateId,
          planstatus: '${widget.planstatus}',
        );
      case 1:
        return MockTestScreen(
          title: widget.title,
          categoryId: widget.categoeyId,
          stateId: widget.stateId,
          planstatus: '${widget.planstatus}',
        );
      case 2:
        return TestScreen(
          title: widget.title,
          categoryId: widget.categoeyId,
          stateId: widget.stateId,
          planstatus: 'appBar',
        );
      default:
        return Container();
    }
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() async {
        // combination = jsonData['user']['is_combination'].toString();

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String combination = jsonData['user']['is_combination']
            .toString();
        await prefs.setString('is_combination', combination);
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> hitAllCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(categorys),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('banners')) {
        setState(() {
          banner = responseData['banners'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          title: Text(
            widget.title,
            style: GoogleFonts.radioCanada(
              textStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),

          actions: [
            Row(
              children: [
                if (widget.type == 'CUET')
                  GestureDetector(
                    onTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final String? combination = prefs.getString(
                        'is_combination',
                      );
                      if (combination == '1') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CombinationTest(
                              title: widget.title,
                              categoryId: widget.categoeyId,
                            ),
                          ),
                        );
                      } else {
                        // If user is not logged in, navigate to login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CombinationSubjectList(
                              title: widget.title,
                              categoryId: widget.categoeyId,
                              type: '',
                              onReturn: () {},
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: Text(
                            'Subject Combination',
                            style: GoogleFonts.radioCanada(
                              textStyle: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Color for text to contrast the gradient
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Center(child: _getPage(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.calendar_month),
            //   label: 'Previous Papers',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note),
              label: 'Subject Wise',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet),
              label: 'Mock Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_fields),
              label: 'Test Series',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: primaryColor,
          type: BottomNavigationBarType.fixed,

          // Ensures all items are shown
          selectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          showUnselectedLabels: true,

          // Add this line to show unselected labels
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

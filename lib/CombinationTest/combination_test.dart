
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../CombinationSubjectList/combinatoin_subject_list.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';
import 'MockCombinatoin/mock_test_combination.dart';
import 'PracticeCombination/practice_combinatoin.dart';
import 'TestSeriesCombination/Test_Series_combination.dart';

class CombinationTest extends StatefulWidget {
  final String title;
  final int categoryId;
  const CombinationTest({super.key, required this.title, required this.categoryId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<CombinationTest> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = false;


  List<dynamic> subjectList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    hitQuestionApi();
  }

  final List<String> subjects = ["Math", "Science", "History"];
  Future<void> hitQuestionApi() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${combinationData}${widget.categoryId}'),
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // userPlanStatus = responseData['userPlanStatus'];

      if (responseData.containsKey('subjectMaster')) {
        setState(() {
          subjectList = responseData['subjectMaster'];
          // isDownloadingList = List<bool>.filled(subjects.length, false);
          // downloadProgressList = List<double>.filled(subjects.length, 0.0);
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

  void _refresh() {
    setState(() {
      hitQuestionApi();
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: Text('CUET COMBINATION ',style: TextStyle(color: Colors.white,fontSize: 13.sp),),
          actions: [

            GestureDetector(
                onTap: (){
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
                          child: CombinationSubjectList(title: widget.title, categoryId: widget.categoryId, type: 'update', onReturn: _refresh),
                        ),
                      );
                    },
                  );
                },

                child: Padding(
                  padding:  EdgeInsets.only(right: 12.sp),
                  child:Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple], // Gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Text(
                        'Update Combination',
                        style: GoogleFonts.radioCanada(
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Color for text to contrast the gradient
                          ),
                        ),
                      ),
                    ),
                  ),

                ))


          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.sp), // Adjust height to fit the ListView
            child: Column(
              children: [
                Container(
                  height: 35.sp, // Set height for the horizontal ListView
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(3.sp),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding:  EdgeInsets.all(8.sp),
                            child: Text(
                              subjectList[index]['name'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: "Mock Test"),
                    Tab(text: "Test Series"),
                    Tab(text: "Practice 24/7"),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            MockTestCombinationScreen(title: widget.title, categoryId: widget.categoryId, onReturn: _refresh,), // First Tab (Offline)
            TestSeriesCombinationScreen(title: widget.title, categoryId: widget.categoryId,),   // Second Tab (Notes)
            PracticeCombinationScreen(paperId: 5, papername: '', exmaTime: 200, question: '', marks: '', categoryId: widget.categoryId,),   // Second Tab (Notes)
          ],
        ),
      ),
    );

  }
}

class SubjectCard extends StatelessWidget {
  final String subject;

  SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          subject,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
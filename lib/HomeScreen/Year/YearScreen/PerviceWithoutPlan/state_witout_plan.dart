import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HomeScreen/Year/YearScreen/PerviceWithoutPlan/pervice_without_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../CommonCalling/progressbarWhite.dart';
import '../../../../Utils/app_colors.dart';
import '../../../../Utils/textSize.dart';
import '../../../../baseurl/baseurl.dart';

class NursingStateWithoutPlan extends StatefulWidget {
  final String type;
  final String title;
  final String catName;
  final String description;
  final int cat;
  final int subCat;
  final int initialIndex;

  NursingStateWithoutPlan({
    required this.type,
    required this.title,
    required this.description,
    required this.cat,
    required this.subCat,
    required this.catName,
    required this.initialIndex,
  });

  @override
  State<NursingStateWithoutPlan> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NursingStateWithoutPlan> {
  List<dynamic> doubtlist = [];
  int?
  selectedIndex; // Declare this outside the widget, in the state of your StatefulWidget.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    hitDoubtList();
  }

  Future<void> hitDoubtList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse("${getState}"),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('states')) {
        setState(() {
          doubtlist = responseData['states'];
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
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${widget.title}',
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
        actions: [],
      ),
      body: doubtlist.isEmpty
          ? WhiteCircularProgressWidget()
          : Padding(
              padding: EdgeInsets.all(5.sp),
              child: ListView.builder(
                itemCount: doubtlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerviceWithoutPlanYearScreen(
                            title: widget.catName,
                            categoryId: widget.cat,
                            subcategoryId: widget.subCat,
                            stateId: doubtlist[index]['id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: SizedBox(
                              height: 40.sp,
                              width: 60.sp,
                              child: Image.asset(
                                'assets/india_state.gif',
                                // cacheWidth: 60,cacheHeight: 60,
                              ),
                            ),
                          ),
                          title: Text(
                            doubtlist[index]['name'].toString(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: TextSizes.textsmall,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            doubtlist[index]['council_name'].toString(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: TextSizes.textsmall2,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          trailing: Radio(
                            value: index,
                            groupValue: selectedIndex,
                            activeColor: primaryColor,
                            onChanged: (int? value) {
                              setState(() {
                                selectedIndex = value;
                              });

                              // Navigate to the next screen after selection
                              if (value != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PerviceWithoutPlanYearScreen(
                                          title: widget.catName,
                                          categoryId: widget.cat,
                                          subcategoryId: widget.subCat,
                                          stateId: doubtlist[index]['id'],
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

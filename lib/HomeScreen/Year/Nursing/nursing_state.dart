import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../HomePage/home_page.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/image.dart';
import '../../../Utils/textSize.dart';
import '../../../baseurl/baseurl.dart';
import '../yearpage.dart';

class NursingState extends StatefulWidget {
  final String type;
  final String title;
  final String catName;
  final String description;
  final int cat;
  final int subCat;
  final int initialIndex;
  final String planstatus;

  NursingState({
    required this.type,
    required this.title,
    required this.description,
    required this.cat,
    required this.subCat,
    required this.catName,
    required this.initialIndex,
    required this.planstatus,
  });

  @override
  State<NursingState> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NursingState> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
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
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){
                Navigator.of(context).pop();

              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Choose from industry-ready courses in ${widget.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )


          ],

        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationList()),
                );
              },
            ),
          ),
        ],

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

          doubtlist.isEmpty
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
                              builder: (context) => Yearpage(
                                title: widget.catName,
                                categoeyId: widget.cat,
                                subcategoeyId: widget.subCat,
                                initialIndex: widget.initialIndex,
                                type: doubtlist[index]['name'].toString(),
                                stateId: doubtlist[index]['id'],
                                planstatus: widget.planstatus,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1,color: Colors.blue.shade100)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(0.sp),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(5.sp),
                                child: Container(
                                  height: 60.sp,
                                  width: 60.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.sp),
                                        border: Border.all(width: 1,color: Colors.blue.shade50)
                                  ),
                                  child: SizedBox(
                                    height: 40.sp,
                                    width: 60.sp,
                                    child: Icon(
                                      Icons.flag, // ya Icons.map / Icons.flag
                                      size: 30.sp,
                                      color: Colors.blue,
                                    ),
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
                                        builder: (context) => Yearpage(
                                          title: widget.catName,
                                          categoeyId: widget.cat,
                                          subcategoeyId: widget.subCat,
                                          initialIndex: widget.initialIndex,
                                          type: doubtlist[index]['name'].toString(),
                                          stateId: doubtlist[index]['id'],
                                          planstatus: '${widget.planstatus}',
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
        ],
      ),

    );
  }
}

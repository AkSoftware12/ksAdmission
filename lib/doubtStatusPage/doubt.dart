import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../CommonCalling/progressbarWhite.dart';
import '../Utils/app_colors.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class DoubtStatusPage extends StatefulWidget {
  const DoubtStatusPage({super.key});

  @override
  State<DoubtStatusPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<DoubtStatusPage> {
  bool isLoading = false;


  List<dynamic> doubtlist = [];


  @override
  void initState() {
    super.initState();
    hitDoubtList();
  }


  Future<void> hitDoubtList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse("${doubtsStatus}"),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          doubtlist = responseData['data'];
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
    return  Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('${'Doubt Status'}',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body:isLoading
          ? PrimaryCircularProgressWidget()
          :

      Column(
        children: [
          doubtlist.isEmpty
              ? Center(child: DataNotFoundWidget())
              :
          Expanded(
            child: ListView.builder(
                itemCount: doubtlist.length,
                itemBuilder: (BuildContext context, int index){
                  return  Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),

                    ),
                    child: Padding(
                      padding:  EdgeInsets.all(3.sp),
                      child:ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(00.sp),
                          child: SizedBox(
                            height: 40.sp,
                            width: 40.sp,
                            child: Image.asset('assets/doubt_s.png'),
                          ),
                        ),
                        title: Text(
                          doubtlist[index]['message'].toString(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: TextSizes.textsmall,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              '${doubtlist[index]['entry_date'].toString()}',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: TextSizes.textsmall,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),

                          ],
                        ),
                        trailing:  Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              ' ${doubtlist[index]['status_text'].toString()}',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: TextSizes.textsmall2,
                                  color: doubtlist[index]['status_text']=='Accepted'?Colors.green: Colors.red,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                          ],
                        ),

                      ),

                    ),
                  );
                }),
          )
        ],
      ),

    );
  }
}

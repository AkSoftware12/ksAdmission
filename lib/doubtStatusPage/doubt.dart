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
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
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
    setState(() {
      isLoading = true; // 🔹 START LOADING
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(doubtsStatus),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          doubtlist = responseData['data'] ?? []; // 🔹 NULL SAFE
        });
      } else {
        doubtlist = [];
      }
    } catch (e) {
      doubtlist = [];
    }

    setState(() {
      isLoading = false; // 🔹 STOP LOADING
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                    'Doubt Status',
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
                    "Track & manage your doubts in real time",
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



      body: isLoading
          ? const PrimaryCircularProgressWidget()
          : doubtlist.isEmpty
          ? const Center(child: DataNotFoundWidget())
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        itemCount: doubtlist.length,
        itemBuilder: (context, index) {
          final item = doubtlist[index];
          final isAccepted = item['status_text'] == 'Accepted';

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: HexColor('#0e4ccc').withOpacity(.25),
                width: 1,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: HexColor('#0e4ccc').withOpacity(.20),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),

              leading: Container(
                height: 46.h,
                width: 46.h,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset('assets/doubt_s.png'),
                ),
              ),

              title: Text(
                item['message'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: HexColor('#0e4ccc'),
                ),
              ),

              subtitle: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  item['entry_date'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.black87,
                  ),
                ),
              ),

              trailing: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  item['status_text'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isAccepted ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),


    );
  }
}

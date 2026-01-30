import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../HexColorCode/HexColor.dart';
import '../../HomePage/home_page.dart';
import '../../OfflineClass/offline_class.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';
import '../doubt_session.dart';
import 'doubt_list.dart';

class DoubtSessionTabClass extends StatefulWidget {
  const DoubtSessionTabClass({
    super.key,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DoubtSessionTabClass>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010071),
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
              onTap: () {
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
                children: [
                  Text(
                   'Doubt Session', // ✅ dynamic
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Clear your doubts with real-time expert support',
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
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


      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          child: Column(
            children: [
              // _topHeader(),
              SizedBox(height: 2.h),
              _tabBar(),
              SizedBox(height: 8.h),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    DoubtSession(), // First Tab (Offline)
                    DoubtList(), // Second Tab (Notes)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _tabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          // color: HexColor('#010071'),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: HexColor('#010071'),),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              colors: [ Color(0xFF0A1AFF), Color(0xFF0A1AFF),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: HexColor('#010071'),
          labelStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "New Doubt"),
            Tab(text: "My Doubts"),
          ],
        ),
      ),
    );
  }

}




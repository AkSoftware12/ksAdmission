import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Doubt Session',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "Create Doubt ",
            ),
            Tab(text: "Your Doubt"),
          ],
          labelColor: Colors.white,
          // Selected tab color
          unselectedLabelColor: Colors.grey,

          indicatorColor: Colors.orange, // Underline color
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DoubtSession(), // First Tab (Offline)
          DoubtList(), // Second Tab (Notes)
        ],
      ),
    );
  }
}




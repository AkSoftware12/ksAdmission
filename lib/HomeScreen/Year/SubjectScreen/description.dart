import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../baseurl/baseurl.dart';

class DescriptionScreen extends StatefulWidget {
  final int descriptionId;
  const DescriptionScreen({super.key, required this.descriptionId});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  String descriptions = '';

  Future<void> hitDescriptionApi() async {

    final response = await http.get(Uri.parse('${description}${widget.descriptionId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        descriptions= jsonData['description']['content'];


      });

    } else {
      throw Exception('Failed to load profile data');
    }
  }


  @override
  void initState() {
    super.initState();
    hitDescriptionApi();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              descriptions,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
              textAlign: TextAlign.center, // Center the text horizontally
            ),
          ],
        ),
      ),
    );
  }
}

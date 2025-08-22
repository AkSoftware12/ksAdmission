import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Utils/image.dart';
import '../baseurl/baseurl.dart';

class SyllabusScreen extends StatefulWidget {
  final int  catId;

  const SyllabusScreen({super.key, required this.catId});
  @override
  _SyllabusScreenState createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String data = '';
  bool isLoading = true; // To show a loading indicator while WebView is loading

  @override
  void initState() {
    super.initState();
    fetchSyllabusData();
  }

  Future<void> fetchSyllabusData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse("${syllabusCat}${widget.catId}");
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        data = jsonData['data']['content'].toString();
        isLoading = false; // Set loading to false when data is ready
      });
    } else {
      throw Exception('Failed to load syllabus data');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Syllabus'),

      ),
      body:  Stack(
        children: [
          Center(
            child: SizedBox(
              height: 200.sp,
              width: 200.sp,
              child: Opacity(
                opacity: 0.3, // Adjust the opacity value (0.0 to 1.0)
                child: Image.asset(logo),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Html(
              data: data,
              style: {
                "*": Style(
                  fontSize: FontSize(16.sp),  // Setting font size to 20.sp
                ),
              },

            ),
          ),

        ],
      ),



    );
  }
}




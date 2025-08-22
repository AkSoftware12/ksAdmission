import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/app_colors.dart';
import '../Year/SubjectScreen/webView.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class NewsScreen extends StatefulWidget {
  final int id;

  const NewsScreen({super.key, required this.id});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // List<dynamic> newsData = [];
  Map<String, dynamic>? newsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews(widget.id);
  }

  Future<void> fetchNews(int id) async {
    try {
      final response = await http.get(Uri.parse('${news}${id}'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            newsData = jsonData['news'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> hitNewsList(int id) async {
    final response = await http.get(Uri.parse('${news}${id}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('news')) {
        setState(() {
          newsData = responseData['news'];
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
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('News', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : newsData == null
          ? Center(child: Text('No data available'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Image
                        if (newsData!['image'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Image.network(
                              '${newsData!['image_urls'].toString()}',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                newsData!['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Subtitle
                              Text(
                                newsData!['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16),
                              // Icons Row
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icons Row
                              Container(
                                height: 80.sp,
                                // color: primaryColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Video Play Icon
                                    if (newsData!['link'] != null)
                                      SizedBox(
                                        width: 80.sp, // Set desired width
                                        height: 50, // Set desired height
                                        child: CupertinoButton(
                                          color: Colors.lightBlueAccent,
                                          padding: EdgeInsets.zero,
                                          // Ensures no extra padding
                                          child: Icon(
                                            Icons.link,
                                            color: Colors.black,
                                            size: 40,
                                          ),
                                          // Adjust icon size if needed
                                          onPressed: () async {
                                            final Uri uri = Uri.parse(
                                              '${newsData?['link']}',
                                            );
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication, // Ensures it opens in the browser
                                              );
                                            } else {
                                              throw "Could not launch ${newsData?['link']}";
                                            }
                                          },
                                        ),
                                      ),
                                    if (newsData!['pdf'] != null)
                                      SizedBox(
                                        width: 80.sp,
                                        height: 50,
                                        child: CupertinoButton(
                                          color: Colors.lightBlueAccent,
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.black,
                                            size: 40,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PdfViewerPage(
                                                  url:
                                                      '${newsData?['pdf_urls']}',
                                                  title:
                                                      '${newsData?['title']}',
                                                  category: '',
                                                  Subject: '',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (newsData!['video'] != null)
                                      SizedBox(
                                        width: 80.sp,
                                        height: 50,
                                        child: CupertinoButton(
                                          color: Colors.lightBlueAccent,
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.black,
                                            size: 40,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

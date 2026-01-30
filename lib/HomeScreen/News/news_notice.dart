import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../HomePage/home_page.dart';
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
                    'News',
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
                    "Latest education news & official updates",
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
          ? Center(child: PrimaryCircularProgressWidget())
          : newsData == null
          ? Center(child: Text('No data available'))
          : Padding(
              padding: const EdgeInsets.all(0.0),
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
                              top: Radius.circular(0),
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
                                  color: Colors.black87,
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
                                          color:    Color(0xFF0A1AFF),
                                          padding: EdgeInsets.zero,
                                          // Ensures no extra padding
                                          child: Icon(
                                            Icons.link,
                                            color: Colors.white,
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
                                          color:  Color(0xFF0A1AFF),
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.white,
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
                                          color:   Color(0xFF0A1AFF),
                                          padding: EdgeInsets.zero,
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
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

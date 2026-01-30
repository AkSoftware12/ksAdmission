import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../HomePage/home_page.dart';
import '../../baseurl/baseurl.dart';
import 'news_notice.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> newsData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    hitNewsList();
  }

  Future<void> hitNewsList() async {
    final response = await http.get(Uri.parse(getNewsList));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('news')) {
        setState(() {
          newsData = responseData['news'];
          _loading=false;
        });
      } else {
        _loading=false;

        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      _loading=false;

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

      body: _loading
          ? const Center(child:PrimaryCircularProgressWidget())
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 00.h, horizontal: 5.w),
        itemCount: newsData.length,
        itemBuilder: (context, index) {
          final item = newsData[index];

          return InkWell(
            borderRadius: BorderRadius.circular(5.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsScreen(id: item['id']),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 5.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF010071).withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔵 Icon Box
                  Container(
                    height: 46.h,
                    width: 46.h,
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                        colors: [
                          Color(0xFF010071).withOpacity(0.7),
                          Color(0xFF0A1AFF).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 🔵 Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: Color(0xFF010071),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    item['entry_date'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF010071),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),


                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),

                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: Color(0xFF010071),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

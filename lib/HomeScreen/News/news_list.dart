import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../../baseurl/baseurl.dart';
import 'news_notice.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> newsData = [];

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
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('News', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: newsData.length, // Number of items in the list
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsScreen(id: newsData[index]['id']),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(5.sp),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.sp),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 40.sp,
                              width: 40.sp,
                              child: Image.asset('assets/news.png'),
                            ),
                            SizedBox(width: 10.sp), // Add some spacing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${newsData[index]['title'].toString()}',
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 5.sp),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 5.sp),
                                      Text(
                                        '${newsData[index]['entry_date'].toString()}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          );
        },
      ),
    );
  }
}

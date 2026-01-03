// Notes Grid Tab
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../Utils/textSize.dart';
import '../../baseurl/baseurl.dart';
import '../doubt_session.dart';
import '../../baseurl/baseurl.dart';
import 'doubt_detail_screen.dart';

class DoubtList extends StatefulWidget {
  @override
  State<DoubtList> createState() => _NotesGridTabState();
}

class _NotesGridTabState extends State<DoubtList> {
  List<dynamic> doubtlist = [];
  bool isLoading = false;

  Future<void> hitDoubtList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse(userDoubtSessionList),
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
  void initState() {
    super.initState();
    hitDoubtList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? WhiteCircularProgressWidget()
        : Column(
            children: [
              doubtlist.isEmpty
                  ? Center(child: DataNotFoundWidget())
                  : Expanded(
                    child: ListView.builder(
                        itemCount: doubtlist.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoubtDetailScreen(
                                          data: doubtlist[index]),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5.sp),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.sp)),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.sp),
                                        child: Image.network(
                                          doubtlist[index]['category']['picture_urls']['image'].toString(),
                                          width: 50.w,
                                          height: 50.w,
                                          fit: BoxFit.cover,

                                          // 🔹 Jab image load ho rahi ho
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: 50.w,
                                              height: 50.w,
                                              alignment: Alignment.center,
                                              child: const CircularProgressIndicator(strokeWidth: 2),
                                            );
                                          },

                                          // 🔹 Jab image na aaye / error ho
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 50.w,
                                              height: 50.w,
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 26.sp,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      title: Text(
                                        doubtlist[index]['subject']['name']
                                            .toString(),
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: TextSizes.textsmall2,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      subtitle: Text(
                                        doubtlist[index]['message'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DoubtDetailScreen(
                                                    data: doubtlist[index]),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.sp),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.sp)),
                                      child: Text(
                                        '   ${doubtlist[index]['category']['name'].toString()}   ',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: TextSizes.textsmall,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.sp),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.sp)),
                                      child: Text(
                                        '   ${doubtlist[index]['entry_date'].toString()}   ',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: TextSizes.textsmall,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ),
            ],
          );
  }
}

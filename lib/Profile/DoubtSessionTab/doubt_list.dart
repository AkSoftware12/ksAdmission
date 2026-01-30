// Notes Grid Tab
import 'package:flutter/cupertino.dart';
import 'package:realestate/CommonCalling/progressbarPrimari.dart';
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
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(userDoubtSessionList),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // ✅ data safe parse
        final List<dynamic> list = (responseData['data'] as List?) ?? [];

        setState(() {
          doubtlist = list;
        });
      } else {
        // ❌ API fail => empty list so "Data Not Found" show ho sake
        setState(() {
          doubtlist = [];
        });
      }
    } catch (e) {
      // ❌ error => empty list
      setState(() {
        doubtlist = [];
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  @override
  void initState() {
    super.initState();
    hitDoubtList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return PrimaryCircularProgressWidget();
    }

    if (doubtlist.isEmpty) {
      return Center(child: DataNotFoundWidget());
    }

    return  ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        itemCount: doubtlist.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = doubtlist[index];

          final String categoryName = item['category']?['name']?.toString() ?? "Category";
          final String entryDate = item['entry_date']?.toString() ?? "";
          final String subjectName = item['subject']?['name']?.toString() ?? "Subject";
          final String message = item['message']?.toString() ?? "";

          final String imageUrl =
              item['category']?['picture_urls']?['image']?.toString() ?? "";

          return InkWell(
            borderRadius: BorderRadius.circular(5.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoubtDetailScreen(data: item),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0A1AFF).withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Color(0xFF0A1AFF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 TOP CHIPS ROW
                  Row(
                    children: [
                      _chipGradient(
                        text: categoryName,
                        icon: Icons.local_offer_rounded,
                        colors: const [Color(0xFF010071), Color(0xFF0A1AFF)],
                      ),
                      const Spacer(),
                      _chipPlain(
                        text: entryDate,
                        icon: Icons.calendar_month_rounded,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // ✅ MAIN CONTENT ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5.r),
                        child: Container(
                          width: 64.w,
                          height: 54.w,
                          color: Colors.grey.shade100,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const PrimaryCircularProgressWidget(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 26.sp,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // Arrow button
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  }
  Widget _chipGradient({
    required String text,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipPlain({required String text, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

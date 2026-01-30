import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realestate/CommonCalling/progressbarPrimari.dart';
import 'package:realestate/Utils/app_colors.dart';
import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarWhite.dart';
import '../HomePage/home_page.dart';
import 'college_detail_screen.dart';

class CollegeListScreen extends StatefulWidget {
  final int? id;
  final String state;

  const CollegeListScreen({super.key, required this.id, required this.state});

  @override
  State<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends State<CollegeListScreen> {
  bool isLoading = false;
  List<dynamic> collegeStates = []; // Declare a list to hold API college

  @override
  void initState() {
    super.initState();
    postWithQueryParams();
  }

  Future<void> postWithQueryParams() async {
    setState(() {
      isLoading = true; // Show progress bar
    });

    try {
      // Construct the URL with query parameters
      final url = Uri.parse(
          'https://ksadmission.in/api/universitywithstates?state_id=${widget.id}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Specify the content type if needed
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Safely check if the 'college' key exists and is a List
        if (jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          setState(() {
            collegeStates = jsonResponse['data'];
            isLoading = false; // Stop progress bar
          });
        } else {
          setState(() {
            collegeStates = []; // Default to an empty list if 'college' is null
            isLoading = false; // Stop progress bar
          });
          if (kDebugMode) {
            print('College key is missing or not a list.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch college. Status Code: ${response.statusCode}');
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      setState(() {
        isLoading = false;
      });
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
                    'Top Universities in ${widget.state}',
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
                    "Learn, compare & choose the right university",
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
          ? PrimaryCircularProgressWidget()
          : collegeStates.isEmpty
              ? Center(child: DataNotFoundWidget())
              : ListView.builder(
                  itemCount: collegeStates.length,
                  itemBuilder: (context, index) {
                    final college = collegeStates[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// 🔹 IMAGE WITH OVERLAY
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                                  child: CachedNetworkImage(
                                    imageUrl: college["picture_urls"].toString(),
                                    height: 200.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        Container(height: 200.h, color: Colors.grey.shade300),
                                    errorWidget: (_, __, ___) => Image.asset(
                                      'assets/no_image.jpg',
                                      height: 200.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                /// Gradient
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.vertical(top: Radius.circular(18)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.65),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                /// Grade chip
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _infoChip(
                                    "Grade ${college["university_grade"]?.toString().toUpperCase() ?? 'N/A'}",
                                    Colors.orange,
                                  ),
                                ),

                                /// University name
                                Positioned(
                                  left: 14,
                                  bottom: 14,
                                  right: 14,
                                  child: Text(
                                    college["university_name"].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            /// 🔹 DETAILS
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  _rowItem("📍 Location",
                                      "${widget.state}, ${college["country"] ?? 'India'}"),
                                  _rowItem("🏛 Type",
                                      college["university_type"] == 1 ? "Government" : "Private"),
                                  _rowItem("📅 Established",
                                      college["established_year"]?.toString() ?? "N/A"),
                                  _rowItem("🏆 NIRF Rank",
                                      college["nirfRank"]?.toString() ?? "N/A"),
                                  _rowItem(
                                    "💰 Fees",
                                    "₹ ${college["min_fees"] ?? 'N/A'} - ${college["max_fees"] ?? 'N/A'}",
                                  ),
                                  _rowItem(
                                    "🌐 Medium",
                                    college["medium"]?.toString().toUpperCase() ?? "N/A",
                                  ),
                                ],
                              ),
                            ),

                            Divider(height: 1),

                            /// 🔹 BUTTONS
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _gradientButton(
                                      text: "APPLY NOW",
                                      colors: [Colors.orange, Colors.deepOrange],
                                      onTap: () {
                                        // same dialog logic
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _gradientButton(
                                      text: "VIEW DETAILS",
                                      colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CollegeDetailScreen(
                                              data: collegeStates[index],
                                              state: widget.state,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _rowItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.35),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

}

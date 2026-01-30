import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/constants/color_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../CommonCalling/progressbarPrimari.dart';
import '../HomePage/home_page.dart';
import 'college_list.dart';

class CollegeState {
  final String name;
  final String colleges;
  final IconData icon;

  CollegeState(this.name, this.colleges, this.icon);
}

class CollegeGridScreen extends StatefulWidget {
  const CollegeGridScreen({super.key});

  @override
  State<CollegeGridScreen> createState() => _CollegeGridScreenState();
}

class _CollegeGridScreenState extends State<CollegeGridScreen> {
  List collegeStates = [];
  List filteredStates = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAssignmentsData();

    _searchController.addListener(() {
      _filterStates(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStates(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => filteredStates = List.from(collegeStates));
      return;
    }

    setState(() {
      filteredStates = collegeStates.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(q);
      }).toList();
    });
  }



  Future<void> fetchAssignmentsData() async {
    final response = await http.get(
      Uri.parse('https://ksadmission.in/api/states'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        collegeStates = jsonResponse['data'];
        filteredStates = List.from(collegeStates); // ✅ initially all show
      });
    } else {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // backgroundColor: ColorConstants.primaryColor,
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
                      'Universities in India',
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

      body: (filteredStates.isNotEmpty || _searchController.text.isNotEmpty)
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Column(
          children: [
            // ✅ Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFF010071).withOpacity(0.10)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF010071).withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: const Color(0xFF010071), size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search state...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _searchController.clear();
                        _filterStates('');
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF010071).withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 16.sp, color: const Color(0xFF010071)),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ✅ Grid
            Expanded(
              child: filteredStates.isNotEmpty
                  ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 5.h,
                  childAspectRatio: 0.70,
                ),
                itemCount: filteredStates.length,
                itemBuilder: (context, index) {
                  final collegeState = filteredStates[index];

                  return _PremiumStateCard(
                    title: collegeState['name'].toString(),
                    subtitle: "Tap to explore",
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollegeListScreen(
                            id: collegeState['id'],
                            state: collegeState['name'].toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
                  : Center(
                child: Text(
                  "No results found",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(child: PrimaryCircularProgressWidget()),


    );
  }
}


class _PremiumStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int index;

  const _PremiumStateCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.white,
            border: Border.all(color: const Color(0xFF010071).withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF010071).withOpacity(0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✨ soft glow circles
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0A1AFF).withOpacity(0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: -22,
                left: -22,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF010071).withOpacity(0.06),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Icon container
                      Container(
                        height: 40.h,
                        width: 40.h,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A1AFF).withOpacity(0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/president.png',
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF121212),
                          height: 1.15,
                        ),
                      ),


                      SizedBox(height: 5.h),

                      // ✅ mini CTA chip
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF010071).withOpacity(0.06),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_rounded,
                                size: 14.sp, color: const Color(0xFF010071)),
                            SizedBox(width: 6.w),
                            Text(
                              "View",
                              style: GoogleFonts.poppins(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF010071),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}

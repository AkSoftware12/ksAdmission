import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../FreeSectionScreen/4k_player.dart';
import '../HexColorCode/HexColor.dart';
import '../Utils/app_colors.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color bg1 = const Color(0xFF07152F);
  final Color bg2 = const Color(0xFF0B2B5A);
  final Color accent = const Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          child: Column(
            children: [
              // _topHeader(),
              SizedBox(height: 2.h),
              _tabBar(),
              SizedBox(height: 8.h),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _liveTab(),
                    _upcomingTab(),
                    _completedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _tabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          // color: HexColor('#010071'),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: HexColor('#010071'),),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              colors: [ Color(0xFF0A1AFF), Color(0xFF0A1AFF),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: HexColor('#010071'),
          labelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "Live"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
          ],
        ),
      ),
    );
  }

  // -------------------- TABS --------------------

  Widget _liveTab() {
    final list = [
      {
        "title": "Physics • Motion",
        "teacher": "By Ravi Sir",
        "time": "Live now",
        "meta": "Class 12 • Section A",
        "tag": "LIVE",
      },
      {
        "title": "Biology • Human Physiology",
        "teacher": "By Neha Ma'am",
        "time": "Live now",
        "meta": "NEET • Batch 2026",
        "tag": "LIVE",
      },
      {
        "title": "Physics • Motion",
        "teacher": "By Ravi Sir",
        "time": "Live now",
        "meta": "Class 12 • Section A",
        "tag": "LIVE",
      },
      {
        "title": "Biology • Human Physiology",
        "teacher": "By Neha Ma'am",
        "time": "Live now",
        "meta": "NEET • Batch 2026",
        "tag": "LIVE",
      },
      {
        "title": "Physics • Motion",
        "teacher": "By Ravi Sir",
        "time": "Live now",
        "meta": "Class 12 • Section A",
        "tag": "LIVE",
      },
      {
        "title": "Biology • Human Physiology",
        "teacher": "By Neha Ma'am",
        "time": "Live now",
        "meta": "NEET • Batch 2026",
        "tag": "LIVE",
      },
      {
        "title": "Physics • Motion",
        "teacher": "By Ravi Sir",
        "time": "Live now",
        "meta": "Class 12 • Section A",
        "tag": "LIVE",
      },
      {
        "title": "Biology • Human Physiology",
        "teacher": "By Neha Ma'am",
        "time": "Live now",
        "meta": "NEET • Batch 2026",
        "tag": "LIVE",
      },
      {
        "title": "Physics • Motion",
        "teacher": "By Ravi Sir",
        "time": "Live now",
        "meta": "Class 12 • Section A",
        "tag": "LIVE",
      },
      {
        "title": "Biology • Human Physiology",
        "teacher": "By Neha Ma'am",
        "time": "Live now",
        "meta": "NEET • Batch 2026",
        "tag": "LIVE",
      },
    ];

    return _tabBody(
      headerTitle: "Ongoing Live",
      headerSub: "Join instantly & start learning",
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = list[index];
          return _classCard(
            title: item["title"]!,
            teacher: item["teacher"]!,
            time: item["time"]!,
            meta: item["meta"]!,
            badgeText: item["tag"]!,
            badgeColor: const Color(0xFFEF4444),
            ctaText: "Join Now",
            ctaIcon: Icons.play_arrow_rounded,
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenNetworkVideoPlayer(
                    videoUrl: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                    live: true,
                    title: '${  item["title"]}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _upcomingTab() {
    final list = [
      {
        "title": "Chemistry • Organic Basics",
        "teacher": "By Aman Sir",
        "time": "Today • 5:30 PM",
        "meta": "Class 11 • Section B",
        "tag": "UPCOMING",
      },
      {
        "title": "Maths • Trigonometry",
        "teacher": "By Pooja Ma'am",
        "time": "Tomorrow • 10:00 AM",
        "meta": "Class 10 • Section C",
        "tag": "SCHEDULED",
      },
      {
        "title": "NEET • Revision Test Discussion",
        "teacher": "By Team",
        "time": "Sun • 7:00 PM",
        "meta": "NEET 2026",
        "tag": "UPCOMING",
      },
      {
        "title": "Chemistry • Organic Basics",
        "teacher": "By Aman Sir",
        "time": "Today • 5:30 PM",
        "meta": "Class 11 • Section B",
        "tag": "UPCOMING",
      },
      {
        "title": "Maths • Trigonometry",
        "teacher": "By Pooja Ma'am",
        "time": "Tomorrow • 10:00 AM",
        "meta": "Class 10 • Section C",
        "tag": "SCHEDULED",
      },
      {
        "title": "NEET • Revision Test Discussion",
        "teacher": "By Team",
        "time": "Sun • 7:00 PM",
        "meta": "NEET 2026",
        "tag": "UPCOMING",
      },
      {
        "title": "Chemistry • Organic Basics",
        "teacher": "By Aman Sir",
        "time": "Today • 5:30 PM",
        "meta": "Class 11 • Section B",
        "tag": "UPCOMING",
      },
      {
        "title": "Maths • Trigonometry",
        "teacher": "By Pooja Ma'am",
        "time": "Tomorrow • 10:00 AM",
        "meta": "Class 10 • Section C",
        "tag": "SCHEDULED",
      },
      {
        "title": "NEET • Revision Test Discussion",
        "teacher": "By Team",
        "time": "Sun • 7:00 PM",
        "meta": "NEET 2026",
        "tag": "UPCOMING",
      },
    ];

    return _tabBody(
      headerTitle: "Your Schedule",
      headerSub: "Upcoming classes & reminders",
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final item = list[index];
          return _upcomingCard(
            title: item["title"]!,
            teacher: item["teacher"]!,
            time: item["time"]!,
            meta: item["meta"]!,
            badgeText: item["tag"]!,
            badgeColor: Color(0xFF0A1AFF),
            ctaText: "",
            ctaIcon: Icons.alarm_add_rounded,
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _completedTab() {
    final list = [
      {
        "title": "Physics • Units & Dimensions",
        "teacher": "By Ravi Sir",
        "time": "Completed • 45 min",
        "meta": "Recording available",
        "tag": "Completed",
      },
      {
        "title": "Biology • Cell",
        "teacher": "By Neha Ma'am",
        "time": "Completed • 60 min",
        "meta": "Notes available",
        "tag": "Completed",
      },
      {
        "title": "Physics • Units & Dimensions",
        "teacher": "By Ravi Sir",
        "time": "Completed • 45 min",
        "meta": "Recording available",
        "tag": "Completed",
      },
      {
        "title": "Biology • Cell",
        "teacher": "By Neha Ma'am",
        "time": "Completed • 60 min",
        "meta": "Notes available",
        "tag": "Completed",
      },
      {
        "title": "Physics • Units & Dimensions",
        "teacher": "By Ravi Sir",
        "time": "Completed • 45 min",
        "meta": "Recording available",
        "tag": "Completed",
      },
      {
        "title": "Biology • Cell",
        "teacher": "By Neha Ma'am",
        "time": "Completed • 60 min",
        "meta": "Notes available",
        "tag": "Completed",
      },
      {
        "title": "Physics • Units & Dimensions",
        "teacher": "By Ravi Sir",
        "time": "Completed • 45 min",
        "meta": "Recording available",
        "tag": "Completed",
      },
      {
        "title": "Biology • Cell",
        "teacher": "By Neha Ma'am",
        "time": "Completed • 60 min",
        "meta": "Notes available",
        "tag": "Completed",
      },
    ];

    return _tabBody(
      headerTitle: "Completed",
      headerSub: "Watch recordings & download notes",
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final item = list[index];
          return _classCard(
            title: item["title"]!,
            teacher: item["teacher"]!,
            time: item["time"]!,
            meta: item["meta"]!,
            badgeText: item["tag"]!,
            badgeColor: const Color(0xFF19800F),
            ctaText: "Watch",
            ctaIcon: Icons.play_circle_fill_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenNetworkVideoPlayer(
                    videoUrl: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                    live: false,
                    title: '${  item["title"]}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // -------------------- UI PIECES --------------------

  Widget _tabBody({
    required String headerTitle,
    required String headerSub,
    required Widget child,
  }) {
    return Column(
      children: [

        SizedBox(height: 0.h),
        Expanded(child: child),
      ],
    );
  }


  Widget _classCard({
    required String title,
    required String teacher,
    required String time,
    required String meta,
    required String badgeText,
    required Color badgeColor,
    required String ctaText,
    required IconData ctaIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white,
          border: Border.all(color:  Color(0xFF010071).withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color:  Color(0xFF010071).withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left thumbnail

            Container(
              width: 80.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network('https://i.postimg.cc/9rftgk9C/Chat-GPT-Image-Dec-29-2025-02-36-40-PM.png',fit: BoxFit.fill,)),
            ),
            SizedBox(width: 5.w),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color:  Color(0xFF010071),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _badge(badgeText, badgeColor),
                    ],
                  ),
                  Text(
                    teacher,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  // SizedBox(height: 6.h),


                  Row(
                    children: [
                      Expanded(
                        child:  Text(
                          meta,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          gradient: LinearGradient(
                            colors: [

                              Color(0xFF0A1AFF),
                              Color(0xFF0A1AFF),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(ctaIcon, color: Colors.white, size: 18.sp),
                            SizedBox(width: 6.w),
                            Text(
                              ctaText,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // CTA button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.90),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _upcomingCard({
    required String title,
    required String teacher,
    required String time,
    required String meta,
    required String badgeText,
    required Color badgeColor,
    required String ctaText,
    required IconData ctaIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white,
          border: Border.all(color:  Color(0xFF010071).withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color:  Color(0xFF010071).withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left thumbnail

            Container(
              width: 80.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network('https://i.postimg.cc/9rftgk9C/Chat-GPT-Image-Dec-29-2025-02-36-40-PM.png',fit: BoxFit.fill,)),
            ),
            SizedBox(width: 5.w),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color:  Color(0xFF010071),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  Text(
                    teacher,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  // SizedBox(height: 6.h),


                  Row(
                    children: [
                      Expanded(
                        child:  Text(
                          meta,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      _badge(badgeText, badgeColor),

                    ],
                  ),

                  // CTA button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

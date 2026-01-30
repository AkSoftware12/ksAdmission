
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ApiModel/api_responses.dart';
import '../../ApiModel/livefree.dart';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../FreeSectionScreen/4k_player.dart';
import '../../HexColorCode/HexColor.dart';


class TeacherLiveClassScreen extends StatefulWidget {
  const TeacherLiveClassScreen({super.key});

  @override
  State<TeacherLiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<TeacherLiveClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  String? _error;

  List<ContentItem> _liveList = [];
  List<ContentItem> _upcomingList = [];
  List<ContentItem> _completedList = [];

  // fallback if api ever sends relative thumb
  final String _thumbBase = "https://apiweb.ksadmission.in/storage/";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchLiveClasses();
      }
    });

    _fetchLiveClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /* -------------------- API CALL -------------------- */

  Future<void> _fetchLiveClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _error = "Token not found. Please login again.";
        });
        return;
      }

      final res = await http.get(
        Uri.parse(userLiveClasses),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = "API Error: ${res.statusCode}\n${res.body}";
        });
        return;
      }

      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      final parsed = TeacherLiveClassesResponse.fromJson(jsonMap);

      final live = List<ContentItem>.from(parsed.live);
      final upcoming = List<ContentItem>.from(parsed.upcoming);
      final completed = List<ContentItem>.from(parsed.completed);

      live.sort((a, b) => (a.startDateTime ?? DateTime(1900))
          .compareTo(b.startDateTime ?? DateTime(1900)));
      upcoming.sort((a, b) => (a.startDateTime ?? DateTime(1900))
          .compareTo(b.startDateTime ?? DateTime(1900)));
      completed.sort((a, b) => (b.startDateTime ?? DateTime(1900))
          .compareTo(a.startDateTime ?? DateTime(1900)));

      setState(() {
        _liveList = live;
        _upcomingList = upcoming;
        _completedList = completed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /* -------------------- HELPERS -------------------- */

  String _prettyDateTime(ContentItem item) {
    final start = item.startDateTime ?? DateTime.now();
    final end = item.endDateTime ?? start.add(const Duration(minutes: 30));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(start.year, start.month, start.day);

    String dayLabel;
    if (date == today) {
      dayLabel = "Today";
    } else if (date == today.add(const Duration(days: 1))) {
      dayLabel = "Tomorrow";
    } else {
      dayLabel = DateFormat('EEE, dd MMM').format(start);
    }

    final st = DateFormat('h:mm a').format(start);
    final et = DateFormat('h:mm a').format(end);
    return "$dayLabel • $st - $et";
  }

  Widget _stateWrapper({required Widget child}) {
    if (_loading) {
      return const Center(child: PrimaryCircularProgressWidget());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: _fetchLiveClasses,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }

  String _fullThumb(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "$_thumbBase$path";
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  void _openVideo(ContentItem item) {
    final url = item.playableUrl; // ✅ videoUrl > meetingUrl
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenNetworkVideoPlayer(
          videoUrl: url,
          live:true,
          title: item.title,
          item: item, // ✅ always single item
        ),
      ),
    );
  }
  void _openVideo2(ContentItem item) {
    final url = item.playableUrl; // ✅ videoUrl > meetingUrl
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenNetworkVideoPlayer(
          videoUrl: url,
          live:false,
          title: item.title,
          item: item, // ✅ always single item
        ),
      ),
    );
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Column(
            children: [
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: HexColor('#010071')),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1AFF), Color(0xFF0A1AFF)],
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
          onTap: (_) => _fetchLiveClasses(),
          tabs: const [
            Tab(text: "Live"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
          ],
        ),
      ),
    );
  }

  /* -------------------- TABS -------------------- */

  Widget _liveTab() {
    return _stateWrapper(
      child: _tabBody(
        child: _liveList.isEmpty
            ? _emptyState(
          icon: Icons.live_tv_rounded,
          colors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
          title: "No Live Class Right Now",
          sub: "Live classes will start here when available",
        )
            : ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
          itemCount: _liveList.length + 1,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            if (index == 0) return _liveNote();
            final item = _liveList[index - 1];
            final meet = item.meetingUrl;

            return _classCard(
              title: item.title,
              teacher: "${item.teacherId ?? ''}",
              time: _prettyDateTime(item),
              meta: item.className ?? item.title,
              badgeText: "LIVE",
              badgeColor: const Color(0xFFEF4444),
              ctaText:
              (meet == null || meet.isEmpty) ? "Not Ready" : "Join Now",
              ctaIcon: Icons.play_arrow_rounded,
              isCtaEnabled: !(meet == null || meet.isEmpty),
              thumbnailUrl: _fullThumb(item.thumbnail),
              onTap: () {
                if (meet == null || meet.isEmpty) return;
                _openVideo(item);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _upcomingTab() {
    return _stateWrapper(
      child: _tabBody(
        child: _upcomingList.isEmpty
            ? _emptyState(
          icon: Icons.schedule_rounded,
          colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          title: "No Upcoming Classes",
          sub: "Scheduled classes will appear here",
        )
            : ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
          itemCount: _upcomingList.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final item = _upcomingList[index];
            return _upcomingCard(
              title: item.title,
              teacher: "Teacher ID: ${item.teacherId ?? ''}",
              time: _prettyDateTime(item),
              meta: item.className ?? item.title,
              badgeText: item.apiStatus.toString(),
              badgeColor: const Color(0xFF0A1AFF),
              thumbnailUrl: _fullThumb(item.thumbnail),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }

  Widget _completedTab() {
    return _stateWrapper(
      child: _tabBody(
        child: _completedList.isEmpty
            ? _emptyState(
          icon: Icons.check_circle_outline_rounded,
          colors: const [Color(0xFF010071), Color(0xFF0A1AFF)],
          title: "No Completed Classes",
          sub: "Your finished classes will appear here",
        )
            : ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
          itemCount: _completedList.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final item = _completedList[index];

            final playUrl = item.playableUrl;
            final hasPlayable = playUrl.isNotEmpty;

            return _completedCard(
              title: item.title,
              teacher: "Teacher ID: ${item.teacherId ?? ''}",
              time: _prettyDateTime(item),
              meta: item.className ?? item.title,
              badgeText: "DONE",
              badgeColor: const Color(0xFF19800F),
              ctaText: hasPlayable ? "Watch" : "N/A",
              ctaIcon: Icons.play_circle_fill_rounded,
              isCtaEnabled: hasPlayable,
              thumbnailUrl: _fullThumb(item.thumbnail),
              pdfs: item.pdfs,
              onOpenPdf: (pdfUrl) => _openUrl(pdfUrl),
              onTap: () => _openVideo2(item),
            );
          },
        ),
      ),
    );
  }

  /* -------------------- PIECES -------------------- */

  Widget _tabBody({required Widget child}) {
    return Column(
      children: [
        Expanded(child: child),
      ],
    );
  }

  Widget _emptyState({
    required IconData icon,
    required List<Color> colors,
    required String title,
    required String sub,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveNote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(
            color: const Color(0xFFDC2626),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 13.sp,
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'NOTE : ',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 0.4,
                      ),
                    ),
                    TextSpan(
                      text:
                      'This live class will be moved to the Completed section within 3 hours after it ends.',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7F1D1D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    required bool isCtaEnabled,
    required String thumbnailUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: HexColor('#0e4ccc').withOpacity(.25),
            width: 1,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: HexColor('#0e4ccc').withOpacity(.25),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80.sp,
                    width: 110,
                    color: Colors.black12,
                  ),
                  Image.network(
                    thumbnailUrl,
                    height: 80.sp,
                    width: 110,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 80.sp,
                            width: 110,
                            color: Colors.black12,
                          ),
                          const PrimaryCircularProgressWidget(),
                        ],
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80.sp,
                      width: 110,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF010071),
                            height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _badge(badgeText, badgeColor),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 14.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'by $teacher',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 13.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.8.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 13.sp, color: const Color(0xFF010071)),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.7.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: isCtaEnabled ? 1 : 0.45,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: isCtaEnabled
                                  ? const [
                                Color(0xFF0A1AFF),
                                Color(0xFF0016C7),
                              ]
                                  : const [
                                Color(0xFF9CA3AF),
                                Color(0xFF9CA3AF),
                              ],
                            ),
                            boxShadow: isCtaEnabled
                                ? [
                              BoxShadow(
                                color: const Color(0xFF0A1AFF)
                                    .withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(ctaIcon,
                                  size: 16.sp, color: Colors.white),
                              SizedBox(width: 2.w),
                              Text(
                                ctaText,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedCard({
    required String title,
    required String teacher,
    required String time,
    required String meta,
    required String badgeText,
    required Color badgeColor,
    required String ctaText,
    required IconData ctaIcon,
    required bool isCtaEnabled,
    required String thumbnailUrl,
    required List<ContentPdf> pdfs,
    required ValueChanged<String> onOpenPdf,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: HexColor('#0e4ccc').withOpacity(.25),
            width: 1,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: HexColor('#0e4ccc').withOpacity(.25),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80.sp,
                    width: 110,
                    color: Colors.black12,
                  ),
                  Image.network(
                    thumbnailUrl,
                    height: 80.sp,
                    width: 110,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 80.sp,
                            width: 110,
                            color: Colors.black12,
                          ),
                          const PrimaryCircularProgressWidget(),
                        ],
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80.sp,
                      width: 110,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF010071),
                            height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // _badge(badgeText, badgeColor),
                      InkWell(
                        onTap: () => Share.share(
                          'https://play.google.com/store/apps/details?id=com.ksadmission&pcampaignid=web_share',
                        ),
                        child: const Icon(Icons.share, color: Colors.black54),
                      ),
                      SizedBox(width: 6.w),

                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 14.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'by $teacher',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 13.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.8.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 13.sp, color: const Color(0xFF010071)),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.7.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: isCtaEnabled ? 1 : 0.45,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: isCtaEnabled
                                  ? const [
                                Color(0xFF0A1AFF),
                                Color(0xFF0016C7),
                              ]
                                  : const [
                                Color(0xFF9CA3AF),
                                Color(0xFF9CA3AF),
                              ],
                            ),
                            boxShadow: isCtaEnabled
                                ? [
                              BoxShadow(
                                color: const Color(0xFF0A1AFF)
                                    .withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(ctaIcon,
                                  size: 16.sp, color: Colors.white),
                              SizedBox(width: 2.w),
                              Text(
                                ctaText,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.95),
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 9.8.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
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
    required String thumbnailUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: HexColor('#0e4ccc').withOpacity(.25),
            width: 1,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: HexColor('#0e4ccc').withOpacity(.25),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80.sp,
                    width: 110,
                    color: Colors.black12,
                  ),
                  Image.network(
                    thumbnailUrl,
                    height: 80.sp,
                    width: 110,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 80.sp,
                            width: 110,
                            color: Colors.black12,
                          ),
                          const PrimaryCircularProgressWidget(),
                        ],
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80.sp,
                      width: 110,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF010071),
                            height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _badge(badgeText, badgeColor),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 14.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'by $teacher',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.class_,
                          size: 13.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.8.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13.sp, color: const Color(0xFF010071)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.8.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


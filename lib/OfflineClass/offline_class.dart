
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../AddAddress/add_address.dart';
import '../ApiModel/livefree.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Plan/plan.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';
import '../YoutubPlayer/youtube_players.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ApiModel/api_responses.dart'; // LiveClassesResponse
import '../ApiModel/livefree.dart'; // ContentItem, ContentPdf
import '../CommonCalling/progressbarPrimari.dart';
import '../FreeSectionScreen/4k_player.dart';
import '../HexColorCode/HexColor.dart';
import '../Plan/plan.dart';
import '../SubscriptionPopup/subscription_popup.dart';

class VideoData {
  final String title;
  final String url;
  final String image;


  VideoData( {
    required this.title,
    required this.url,
    required this.image,

  });
}

class OfflineClass extends StatefulWidget {
  final String title;
  final bool isLocked;
  const OfflineClass({super.key, required this.title, required this.isLocked});

  @override
  State<OfflineClass> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<OfflineClass> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color bg1 = const Color(0xFF07152F);
  final Color bg2 = const Color(0xFF0B2B5A);
  final Color accent = const Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              onTap: () {
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title, // ✅ dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Offline Lecture • Jab Chaaho Tab Padho',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
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
                    OfflineDataTab(isLocked: widget.isLocked,), // First Tab (Offline)
                    OfflinePlanScreen(),
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
            Tab(text: "Video Lecture"),
            Tab(text: "Offline Package"),
          ],
        ),
      ),
    );
  }

}









class OfflineDataTab extends StatefulWidget {
  final bool isLocked;

  const OfflineDataTab({super.key, required this.isLocked});

  @override
  State<OfflineDataTab> createState() => _OfflineDataTabState();
}

class _OfflineDataTabState extends State<OfflineDataTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true; // initial loading only
  bool _refreshing = false; // silent refresh (no list flicker)
  String? _error;

  List<ContentItem> _completedList = [];

  // fallback if api ever sends relative thumb
  final String _thumbBase = "https://apiweb.ksadmission.in/storage/";

  bool get _isLocked => widget.isLocked;
  bool _firstApiDone = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_firstApiDone) return;
      _firstApiDone = true;
      await _fetchLiveClasses(silent: false);
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (!_firstApiDone) return; // first load complete ho tabhi tab-change allow
      _fetchLiveClasses(silent: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _popupOpen = false;

  void _openSubscribePopupOnce() {
    if (_popupOpen) return;
    _popupOpen = true;

    showSubscriptionPremiumPopup(context, onSubscribe: (){
      _goToPlanScreen();
    }).whenComplete(() {
      _popupOpen = false;
    });
  }

  /* -------------------- API CALL -------------------- */

  Future<void> _fetchLiveClasses({required bool silent}) async {
    // silent = true -> keep list visible, show a small top loader
    // silent = false -> show full loader (used only on initial or hard retry)

    if (!mounted) return;

    if (silent) {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _refreshing = false;
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
          _refreshing = false;
          _error = "API Error: ${res.statusCode}\n${res.body}";
        });
        return;
      }

      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      final parsed = LiveClassesResponse.fromJson(jsonMap);
      final completed = List<ContentItem>.from(parsed.completed);

      completed.sort((a, b) => (b.startDateTime ?? DateTime(1900))
          .compareTo(a.startDateTime ?? DateTime(1900)));

      setState(() {
        _completedList = completed;

        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onPullRefresh() async {
    // ✅ No flicker: list stays, only top progress appears
    await _fetchLiveClasses(silent: true);
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


  void _openVideo2(ContentItem item) {
    final url = item.playableUrl; // ✅ videoUrl > meetingUrl
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenNetworkVideoPlayer(
          videoUrl: url,
          live: false,
          title: item.title,
          item: item, isLocked: widget.isLocked,
        ),
      ),
    );
  }

  // ✅ LOCK overlay (thumbnail par)
  Widget _lockOverlay()   {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.red, size: 20),
                  const SizedBox(height: 0),
                  Text(
                    "Locked",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ top small loader (no list flicker)
  Widget _topRefreshingBar() {
    if (!_refreshing) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        minHeight: 2.2,
        backgroundColor: Colors.transparent,
        color: const Color(0xFF0A1AFF),
      ),
    );
  }

  Widget _stateWrapper({required Widget child}) {
    // ✅ initial load: show big loader only once
    final bool initialEmpty = _completedList.isEmpty;

    if (_loading && initialEmpty) {
      return const Center(child: PrimaryCircularProgressWidget());
    }

    if (_error != null && initialEmpty) {
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
                onPressed: () => _fetchLiveClasses(silent: false),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ normal state: show content + small top loader
    return Stack(
      children: [
        child,
        _topRefreshingBar(),
      ],
    );
  }

  /* -------------------- UI -------------------- */

  void _goToPlanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanScreen(appBar: 'AppBar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Column(
            children: [
              Expanded(
                child: _stateWrapper(
                  child: RefreshIndicator(
                    onRefresh: _onPullRefresh,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _completedTab(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }





  Widget _completedTab() {
    return _tabBody(
      child: _completedList.isEmpty
          ? _emptyState(
        icon: Icons.check_circle_outline_rounded,
        colors: const [Color(0xFF010071), Color(0xFF0A1AFF)],
        title: "No Completed Classes",
        sub: "Your finished classes will appear here",
      )
          : ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
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
            ctaText: _isLocked ? "Locked" : (hasPlayable ? "Watch" : "N/A"),
            ctaIcon: _isLocked
                ? Icons.lock_rounded
                : Icons.play_circle_fill_rounded,
            isCtaEnabled: !_isLocked && hasPlayable,
            locked: _isLocked,
            thumbnailUrl: _fullThumb(item.thumbnail),
            pdfs: item.pdfs,
            onOpenPdf: (pdfUrl) {
              if (_isLocked) {
                _openSubscribePopupOnce();
                return;
              }
              _openUrl(pdfUrl);
            },
            onTap: () {
              // if (_isLocked) {
              //   _openSubscribePopupOnce();
              //   return;
              // }
              if (!hasPlayable) return;
              _openVideo2(item);
            },
          );
        },
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
    required bool locked,
    required String thumbnailUrl,
    required List<ContentPdf> pdfs,
    required ValueChanged<String> onOpenPdf,
    required VoidCallback onTap,
  }) {
    final bool enabled = (!locked && isCtaEnabled);

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      // ✅ FIX: locked hone par bhi tap allow, popup dikhao
      onTap: () {
        if (locked) {
          _openSubscribePopupOnce();
          return;
        }
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
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
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child:   CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        height: 80.sp,
                        width: 120,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) => const PrimaryCircularProgressWidget(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image_outlined),
                      )
                  ),
                  if (locked) _lockOverlay(),
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF010071),
                            // height: 1.25,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      InkWell(
                        onTap: () {
                          if (locked) {
                            _openSubscribePopupOnce();
                            return;
                          }
                          Share.share(
                            'https://play.google.com/store/apps/details?id=com.ksadmission&pcampaignid=web_share',
                          );
                        },
                        child: Icon(
                          Icons.share,
                          size: 15,
                          color: locked ? Colors.black26 : Colors.black54,
                        ),
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
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
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
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: enabled ? 1 : 0.45,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: enabled
                                  ? const [
                                Color(0xFF0A1AFF),
                                Color(0xFF0016C7)
                              ]
                                  : const [
                                Color(0xFF9CA3AF),
                                Color(0xFF9CA3AF)
                              ],
                            ),
                            boxShadow: enabled
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
                              Icon(ctaIcon, size: 16.sp, color: Colors.white),
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

}







class OfflinePlanScreen extends StatefulWidget {
  const OfflinePlanScreen({super.key});

  @override
  State<OfflinePlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<OfflinePlanScreen> {
  String subsid = "0";
  String planId = "";
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  dynamic currency = '';

  Set<String> selectedVendorIds = Set<String>();
  // List<String> selectedIds = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;

  bool isDataLoading = true;






  List<dynamic> allPlan = [];

  Future<void> hitPlan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    setState(() {
      isDataLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(offlineplan),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> plans = (responseData['plans'] ?? []) as List<dynamic>;

        setState(() {
          allPlan = plans; // agar empty hoga to [] set ho jayega
          isDataLoading = false;
        });
      } else {
        setState(() {
          allPlan = [];
          isDataLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        allPlan = [];
        isDataLoading = false;
      });
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    hitPlan();
  }

  Future<void> createPlan() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryCircularProgressWidget(
              ),

            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
      'id',
    );
    final String? token = prefs.getString(
      'token',
    );

    Map<String, dynamic> responseData = {
      "plan_id": planId,
      "subject_id": userId.toString(),
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(planCreateOffline),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(
              initialIndex: 0,
            ),
          ),
        );
      } else {
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${prefs.getString('data')}',
        'description': 'Subscription',
        'prefill': {
          'contact': '${prefs.getString('user_phone')}',
          'email': '${prefs.getString('user_email')}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Premium Header ----------
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(3.sp, 0.sp, 3.sp, 5.sp),
              padding: EdgeInsets.all(14.sp),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 44.sp,
                    width: 44.sp,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14.sp),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.offline_pin_rounded,
                        color: Colors.white),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Offline Plans",
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.sp),
                        Text(
                          "Choose a plan & continue",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.sp, vertical: 7.sp),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_rounded,
                            size: 14.sp, color: Colors.white),
                        SizedBox(width: 6.sp),
                        Text(
                          "${allPlan.length} Plans",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- List ----------
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isDataLoading) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PrimaryCircularProgressWidget(),
                          SizedBox(height: 10.sp),
                          Text(
                            "Loading plans...",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (allPlan.isEmpty) {
                    return _EmptyPlansUI(
                      onRetry: hitPlan,
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(5.sp, 0, 5.sp, 14.sp),
                    itemCount: allPlan.length,
                    itemBuilder: (context, index) {
                      final plan = allPlan[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.sp),
                        child: _PremiumPlanCard(
                          plan: plan,
                          onContinue: () {
                            setState(() {
                              planId = plan['id'].toString();
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddAddress(
                                  categoryId: plan['category']['id'],
                                  price: plan['price_without_gst'].toString(),
                                  planId: plan['id'],
                                  isSubject: plan['is_subject_wise'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }




  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // SubscriptionAPI();

    createPlan();

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }
}


class _PremiumPlanCard extends StatelessWidget {
  final dynamic plan;
  final VoidCallback onContinue;

  const _PremiumPlanCard({
    required this.plan,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = HexColor(plan['color'].toString());
    final String imageUrl = plan['image_url'].toString();
    final String category = plan['category']['name'].toString();
    final String planName = plan['name'].toString();
    final String desc = plan['desc'].toString();
    final String price = plan['price_without_gst'].toString();

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.sp),
        border: Border.all(color: Color(0xFF0A1AFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.sp),
        child: Stack(
          children: [
            // ✅ VERY soft accent background (always same)
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                height: 170.sp,
                width: 170.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -70,
              child: Container(
                height: 190.sp,
                width: 190.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.06),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TOP ROW =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // icon box
                      Container(
                        height: 54.sp,
                        width: 54.sp,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16.sp),
                          border: Border.all(
                            color: accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Image.network(
                            imageUrl,
                            color: accent,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.black45,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),

                      // title area
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // category
                            Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 6.sp),

                            // plan name
                            Text(
                              planName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),

                          ],
                        ),
                      ),

                      // price box
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 10.sp,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.sp),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 2.sp),
                            Text(
                              "₹ $price",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.sp),

                  // ================= DIVIDER =================
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.black12,
                  ),

                  SizedBox(height: 8.sp),

                  // ================= DESCRIPTION =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 30.sp,
                        width: 30.sp,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                            color: accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.check_rounded,
                            size: 18.sp, color: accent),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          desc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),

                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.sp),

                  // ================= CONTINUE BUTTON =================

              Padding(
                padding: EdgeInsets.all(5.sp),
                child: SizedBox(
                  height: 35.sp,
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onContinue,
                      borderRadius: BorderRadius.circular(14.sp),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(14.sp),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              ],
              ),
            ),

            // ✅ top-right small badge (consistent)
            Positioned(
              top: 12.sp,
              right: 12.sp,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8.sp,
                      width: 8.sp,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.sp),
                    Text(
                      "Plan",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
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
}
class _EmptyPlansUI extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyPlansUI({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(14.sp),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 62.sp,
              width: 62.sp,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18.sp),
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 34.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 12.sp),
            Text(
              "No Plans Found",
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6.sp),
            Text(
              "Abhi offline plans available nahi hain.\nPlease retry after some time.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 14.sp),
            SizedBox(
              height: 44.sp,
              width: double.infinity,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(14.sp),
                child: Ink(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(14.sp),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18.sp, color: Colors.white),
                      SizedBox(width: 8.sp),
                      Text(
                        "Retry",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../AddAddress/add_address.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Plan/plan.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';
import '../YoutubPlayer/youtube_players.dart';

import 'package:google_fonts/google_fonts.dart';


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
  final bool isLocked; // Declare variable to receive value

  const OfflineDataTab({super.key, required this.isLocked, });

  @override
  State<OfflineDataTab> createState() => _OfflineDataTabState();
}

class _OfflineDataTabState extends State<OfflineDataTab> {
  bool _isLoading = false;
  List<dynamic> videoList = [];

  Future<void> fetchVideoData() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri uri = Uri.parse(getlecture);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData.containsKey('lectures')) {
        setState(() {
          videoList = jsonData['lectures'];
        });
      } else {
        throw Exception('Invalid API response: Missing "lectures" key');
      }
    } else {
      throw Exception('Failed to load video data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVideoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryCircularProgressWidget(),
            SizedBox(height: 10.sp),
            Text(
              "Loading video lectures...",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          // 📌 Updated Logic for Unlocking
          bool isUnlocked = widget.isLocked == false || index == 0;




          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                // print(videoList[index]['video_url'].toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayer(
                      url: videoList[index]['video_url'].toString(),
                      title: videoList[index]['title'].toString(),
                      videoId: videoList[index]['id'],
                      videoStatus: "unlocked",
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanScreen(appBar: 'Upgrade Plan'),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    /// 🎬 Thumbnail
                    Positioned.fill(
                      child: Image.network(
                        '${baseUrlImage}${videoList[index]['thumbnail']}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),

                    /// 🌈 Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// ▶️ Play / 🔒 Lock Icon
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked
                              ? Colors.white.withOpacity(0.85)
                              : Colors.black.withOpacity(0.6),
                        ),
                        child: Icon(
                          isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                          color: isUnlocked ? Colors.black : Colors.white,
                          size: 36,
                        ),
                      ),
                    ),

                    /// 🏷️ Title Bar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                        ),
                        child: Text(
                          videoList[index]['title'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    /// 🔒 Locked Badge
                    if (!isUnlocked)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "LOCKED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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

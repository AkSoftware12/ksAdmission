import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/KsTools/INDRODUCATION/Introduction.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import '../../HexColorCode/HexColor.dart';

class CounsellingToolFeature {
  final String title;
  final String description;
  final IconData icon;

  CounsellingToolFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class FeatureToolsPage extends StatefulWidget {
  const FeatureToolsPage({super.key});

  @override
  State<FeatureToolsPage> createState() => _FeatureToolsPageState();
}

class _FeatureToolsPageState extends State<FeatureToolsPage>
    with SingleTickerProviderStateMixin {
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var mini = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  var selectedfABLocation = FloatingActionButtonLocation.endDocked;

  VideoPlayerController? _controller1;

  late AnimationController _controller;
  bool isLoading = false;
  bool isDataLoading = true;

  static List<CounsellingToolFeature> features = [
    CounsellingToolFeature(
      title: "All India Rank Wise College List",
      description: "Check colleges based on your All India Rank.",
      icon: Icons.list_alt,
    ),
    CounsellingToolFeature(
      title: "State Wise College List",
      description: "View colleges available in your state.",
      icon: Icons.location_on,
    ),
    CounsellingToolFeature(
      title: "Top 10 College List (Based on Rank)",
      description: "Get the top 10 colleges based on your rank.",
      icon: Icons.star,
    ),
    CounsellingToolFeature(
      title: "Filter Wise College List",
      description: "Filter colleges by course, fees, location, etc.",
      icon: Icons.filter_list,
    ),
    CounsellingToolFeature(
      title: "Category Wise College List",
      description: "View colleges based on category (Gen, OBC, SC, ST, EWS).",
      icon: Icons.category,
    ),
    CounsellingToolFeature(
      title: "Quota Wise College List",
      description: "View colleges based on quotas like All India, State, etc.",
      icon: Icons.group,
    ),
    CounsellingToolFeature(
      title: "Cutoff Based College List",
      description: "Check colleges based on previous year cutoffs.",
      icon: Icons.score,
    ),
    CounsellingToolFeature(
      title: "Round Wise College Allotment List",
      description: "Access allotment lists for each counselling round.",
      icon: Icons.event,
    ),
    CounsellingToolFeature(
      title: "Course Wise College List",
      description: "Search colleges by courses like MBBS, BDS, BAMS, etc.",
      icon: Icons.book,
    ),
    CounsellingToolFeature(
      title: "Rank Predictor & College Suggestion Tool",
      description: "Predict suitable colleges based on rank and category.",
      icon: Icons.psychology,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isDataLoading = false;
      });
    });
    initializeVideo();
  }

  @override
  void dispose() {
    if (_controller1 != null && _controller1!.value.isPlaying) {
      _controller1!.pause();
    }
    _controller1?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void initializeVideo() {
    _controller1 = VideoPlayerController.network(
        'https://apiweb.ksadmission.in/upload/video/1747803890WhatsApp_Video_2025-05-21_at_10.23.13_AM.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: HexColor('#f2f5ff'),
            height: double.infinity,
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/tools_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // AppBar
              PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.sp),
                    bottomRight: Radius.circular(20.sp),
                  ),
                  child: AppBar(
                    backgroundColor: HexColor('#5e19a1'),
                    elevation: 2,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 20.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Ks Counselling Tool',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                    ],
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: isDataLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                )
                    : Column(
                  children: [
                    // Video Section
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        margin: EdgeInsets.all(10.sp),
                        height: 180.sp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.sp),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.sp),
                              child: AspectRatio(
                                aspectRatio:
                                _controller1!.value.aspectRatio,
                                child: _controller1!.value.isInitialized
                                    ? VideoPlayer(_controller1!)
                                    : Container(color: Colors.black),
                              ),
                            ),
                            if (!_controller1!.value.isPlaying)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.sp),
                                child: Image.asset(
                                  'assets/addmission_tools.jpg',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _controller1!.value.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white,
                                size: 50.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_controller1!.value.isPlaying) {
                                    _controller1!.pause();
                                  } else {
                                    _controller1!.play();
                                  }
                                });
                              },
                            ),
                            Positioned(
                              bottom: 10.sp,
                              left: 10.sp,
                              child: Text(
                                'Introduction to Ks Counselling Tools',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Usage Note
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                HexColor('#c30917'),
                                Colors.purple
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.sticky_note_2_outlined,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You can use this tools three times.',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Features Header
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 15.sp),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.list,
                            color: Colors.white,
                            size: 17.sp,
                          ),
                          SizedBox(width: 10.sp),
                          Text(
                            'All Features',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable Features List
                    Expanded(
                      child: ListView.builder(
                        // physics: const BouncingScrollPhysics(),
                        itemCount: features.length,
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        itemBuilder: (context, index) {
                          final feature = features[index];
                          return FadeInUp(
                            duration:
                            Duration(milliseconds: 300 + (index * 100)),
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.sp),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 0.sp),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(0.sp),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(10.sp),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5.sp),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                          BorderRadius.circular(8.sp),
                                        ),
                                        child: Icon(
                                          feature.icon,
                                          color: HexColor('#7209B7'),
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.sp),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              feature.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 0.sp),
                                            Text(
                                              feature.description,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Next Button
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.sp),
                  child: GestureDetector(
                    onTap: () {
                      _controller1!.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntroductionPage(),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 40.sp,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [HexColor('#5e19a1'), Colors.purple.shade200],
                        ),
                        borderRadius: BorderRadius.circular(30.sp),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
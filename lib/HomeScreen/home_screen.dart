import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:realestate/HomeScreen/popular_plans.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Calender/calender.dart';
import '../CollegeStateList/college_state_list.dart';
import '../FreeSectionScreen/free_content_main.dart';
import '../HexColorCode/HexColor.dart';
import '../KsTools/INDRODUCATION/counselling_tool_feature.dart';
import '../NewExam/NewExamMockTest/new_exam_mock_test_list.dart';
import '../OfflineClass/offline_class.dart';
import '../PracticeQuestionScreen/practice_question.dart';
import '../QuizTestScreen/quiztest_mock.dart';
import '../StudentTeacherUi/OnlineDashBoard/online_dashboard.dart';
import '../Utils/app_colors.dart';
import '../Utils/string.dart';
import '../WebView/webview.dart';
import '../baseurl/baseurl.dart';
import 'News/news_list.dart';
import 'Year/Nursing/nursing_state.dart';
import 'Year/SubjectScreen/webView.dart';
import 'Year/YearScreen/PerviceWithoutPlan/pervice_without_plan.dart';
import 'Year/YearScreen/PerviceWithoutPlan/state_witout_plan.dart';
import 'Year/yearpage.dart';
import 'package:video_player/video_player.dart';

class CompetitionCatergory {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String image;

  CompetitionCatergory({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.image,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isPopupShown = false;

  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String cityState = '';
  String pin = '';
  List<dynamic> homePlanlist = [];
  List<dynamic> category = [];
  List<dynamic> newsData = [];
  List<dynamic> banner = [];
  List<dynamic> eventBanner = [];
  List<dynamic> quoteBanner = [];
  List<dynamic> subcategory = [];
  List<dynamic> dailyQuizs = [];
  List<dynamic> classCategorie = [];
  bool isLoading = false; // Add this for the loading state
  late ScrollController? scrollController;
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  List<dynamic> videoUrls = [];
  int currentIndex = 0;
  bool isMuted = true; // Mute video on first play

  @override
  void initState() {
    super.initState();
    hitHomePlanList();
    hitAllCategory();
    fetchProfileData();
    hitNewsList();
    scrollController = ScrollController();

    // Start auto-scroll for news
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (_scrollController!.hasClients) {
        double maxScroll = _scrollController!.position.maxScrollExtent;
        double currentScroll = _scrollController!.offset;
        if (currentScroll < maxScroll) {
          _scrollController!.animateTo(
            currentScroll + 50.0, // Scroll by 50 pixels
            duration: Duration(milliseconds: 700),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController!.jumpTo(0); // Reset to top when reaching the end
        }
      }
    });

    WidgetsBinding.instance.addObserver(this);
    // jab app open hoga tab popup dikhao
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImagePopup(context);
      _isPopupShown = true;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController?.dispose();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // jab app wapas foreground me aaye
      if (!_isPopupShown) {
        _showImagePopup(context);
        _isPopupShown = true;
      }
    } else if (state == AppLifecycleState.paused) {
      // jab app background me jaye
      _isPopupShown = false;
    }
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

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse(getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      isLoading =
          false; // Set loading state to false after registration completes
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        nickname = jsonData['user']['name'].toString();
        userEmail = jsonData['user']['email'].toString();
        contact = jsonData['user']['contact'].toString();
        bio = jsonData['user']['bio'].toString();
        photoUrl = jsonData['user']['picture_data'].toString();
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> hitAllCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(categorys),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          category = responseData['data'];
          banner = responseData['banners'];
          eventBanner = responseData['event_banner'];
          quoteBanner = responseData['quote_banner'];
          subcategory = responseData['subcategories'];
          dailyQuizs = responseData['quizzes'];
          classCategorie = responseData['classCategories'];
          print(classCategorie);
          print('Banner $banner');

          videoUrls = responseData['video'];
          if (videoUrls.isNotEmpty) {
            initializeVideoPlayer(videoUrls[currentIndex]['video_urls']);
          }
          // videoUrls = responseData['video'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await hitAllCategory();
    } catch (error) {}
  }

  Future<void> hitHomePlanList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(homeplan),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    print('token:$token');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('plans')) {
        setState(() {
          homePlanlist = responseData['plans'];
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void initializeVideoPlayer(String videoUrl) {
    _controller?.dispose(); // Dispose previous controller

    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
        _controller?.setVolume(isMuted ? 0 : 1); // Mute video on first play
        _isPlaying = true;

        _controller?.addListener(() {
          if (_controller!.value.position == _controller!.value.duration) {
            playNextVideo();
          }
        });
      })
      ..setLooping(false);
  }

  void playNextVideo() {
    if (videoUrls.isNotEmpty) {
      setState(() {
        currentIndex = (currentIndex + 1) % videoUrls.length;
        initializeVideoPlayer(videoUrls[currentIndex]['video_urls']);
      });
    }
  }

  void playPreviousVideo() {
    if (videoUrls.isNotEmpty) {
      setState(() {
        currentIndex = (currentIndex - 1 + videoUrls.length) % videoUrls.length;
        initializeVideoPlayer(videoUrls[currentIndex]['video_urls']);
      });
    }
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _controller?.setVolume(isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (category.isEmpty) {
      return Scaffold(
        backgroundColor: HexColor('375E97'),
        body: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner Section
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.sp,
                    right: 5.sp,
                    top: 5.sp,
                    bottom: 5.sp,
                  ),
                  child: Container(
                    height: 120.sp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(
                        10.sp,
                      ), // Adjust for roundness
                    ),
                  ),
                ),

                Container(
                  color: greenColorQ,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Card(
                          // elevation: 5,
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ), // 5 logical pixels radius
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.sp),
                            child: Text(
                              'Latest News',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button Grid Section
                Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor('C4DFE6'),
                      borderRadius: BorderRadius.circular(
                        10.sp,
                      ), // Adjust for roundness
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.sp, top: 8.sp),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        // 2 items per row
                        childAspectRatio: 3,
                        // Adjust based on the desired item height/width ratio
                        crossAxisSpacing: 10.sp,
                        // Space between columns
                        mainAxisSpacing: 10.sp,
                        // Space between rows
                        padding: EdgeInsets.all(5.sp),
                        children: List.generate(4, (index) {
                          return GestureDetector(
                            child: Container(
                              height: 50.sp,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey,
                              ),
                              child: Text('       '),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Container(
                  // color: greenColorQ,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Card(
                          // elevation: 5,
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ), // 5 logical pixels radius
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.sp),
                            child: Text(
                              'Latest News',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subject Categories Section
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff536976),
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40.sp,
                                child: ListView.builder(
                                  itemCount: 1,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile();
                                  },
                                ),
                              ),
                              SizedBox(height: 160.sp),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff536976),
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40.sp,
                                child: ListView.builder(
                                  itemCount: 1,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile();
                                  },
                                ),
                              ),
                              SizedBox(height: 160.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: homepageColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5.sp,
                        right: 5.sp,
                        top: 5.sp,
                        bottom: 5.sp,
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 110.sp,
                          autoPlay: true,
                          initialPage: 10,
                          viewportFraction: 1,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: (banner.length > 0)
                            ? banner.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return InkWell(
                                      onTap: () {
                                        if (e['link'] != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return WebViewExample(
                                                  title: '',
                                                  url: e['link'],
                                                );
                                              },
                                            ),
                                          );
                                        } else if (e['pdf'] != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PdfViewerPage(
                                                    url: e['pdf_urls']
                                                        .toString(),
                                                    title: '',
                                                    category: '',
                                                    Subject: '',
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.sp,
                                          vertical: 0,
                                        ),
                                        child: Material(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Container(
                                            height: 110.sp,
                                            width: double.infinity,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: e['picture_urls']
                                                    .toString(),
                                                fit: BoxFit.fill,
                                                // Adjust this according to your requirement
                                                placeholder: (context, url) =>
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors
                                                                .orangeAccent,
                                                          ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Image.asset(
                                                      'assets/no_image.jpg',
                                                      // Path to your default image asset
                                                      // Adjust width as per your requirement
                                                      fit: BoxFit
                                                          .cover, // Adjust this according to your requirement
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList()
                            : banner.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return Container(
                                      height: 120.sp,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.90,
                                      // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                      ),
                    ),
                    // Tool
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        // color: greenColorQ,
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Card(
                                // elevation: 5,
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5.0,
                                  ), // 5 logical pixels radius
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.sp),
                                  child: Text(
                                    '  Ks Admission Counselling Tools ',
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return FeatureToolsPage();
                              },
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/addmission_tools.jpg',
                            fit: BoxFit.fill,
                            height: 170.sp,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),





                    // Ks Demo Section
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        // color: greenColorQ,
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Card(
                                // elevation: 5,
                                color: Colors.pink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5.0,
                                  ), // 5 logical pixels radius
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.sp),
                                  child: Text(
                                    'Free Section',
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return FreeContentPage();
                              },
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/ksdemosection.png',
                            fit: BoxFit.cover,
                            height: 120.sp,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: HexColor('C4DFE6'),
                          borderRadius: BorderRadius.circular(
                            10.sp,
                          ), // Adjust for roundness
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.sp, top: 8.sp),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            // 2 items per row
                            childAspectRatio: 2,
                            // Adjust based on the desired item height/width ratio
                            crossAxisSpacing: 10.sp,
                            // Space between columns
                            mainAxisSpacing: 10.sp,
                            // Space between rows
                            padding: EdgeInsets.all(5.sp),
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(classCategorie.length, (
                              index,
                            ) {
                              return GestureDetector(
                                child: Container(
                                  // height: 80.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: HexColor('375E97'),
                                  ),
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (index == 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OnlineDashBoard(),
                                              ),
                                            );
                                          } else if (index == 1) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OfflineClass(
                                                  title:
                                                      '${classCategorie[index]['name']}',
                                                  isLocked:
                                                      classCategorie[index]['is_locked'],
                                                ),
                                              ),
                                            );
                                          } else if (index == 2) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PracticeQuestionScreen(
                                                      paperId: 2,
                                                      papername: '',
                                                      exmaTime: 150,
                                                      question: '',
                                                      marks: '',
                                                      isLocked:
                                                          classCategorie[index]['is_locked'],
                                                    ),
                                              ),
                                            );
                                          } else if (index == 3) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return NEETCalendar();
                                                },
                                              ),
                                            );
                                          }
                                        },

                                        child: (index == 0)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/onlinecl.png',
                                                  fit: BoxFit.fill,
                                                  height: 85.sp,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : (index == 1)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/offline.png',
                                                  fit: BoxFit.fill,
                                                  height: 85.sp,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : (index == 2)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/praticesimage.png',
                                                  fit: BoxFit.fill,
                                                  height: 85.sp,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : (index == 3)
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/daily.png',
                                                  fit: BoxFit.fill,
                                                  height: 85.sp,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.sp),
                                                  child: Text(
                                                    '${classCategorie[index]['name']}'
                                                        .toUpperCase(),
                                                    style:
                                                        GoogleFonts.radioCanada(
                                                          textStyle: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      // color: greenColorQ,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Card(
                              // elevation: 5,
                              color: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5.0,
                                ), // 5 logical pixels radius
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.sp),
                                child: Text(
                                  'Exam & Only Hindi Notes',
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        left: 5.sp,
                        right: 5.sp,
                        top: 5.sp,
                        bottom: 5.sp,
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 140.sp,
                          autoPlay: true,
                          initialPage: 10,
                          viewportFraction: 1,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: (eventBanner.length > 0)
                            ? eventBanner.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return InkWell(
                                      onTap: () {
                                        if (e['event_type'] == 'exam') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return NewExamMockScreen();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.sp,
                                          vertical: 0,
                                        ),
                                        child: Material(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Container(
                                            height: 140.sp,
                                            width: double.infinity,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: e['picture_urls']
                                                    .toString(),
                                                fit: BoxFit.fill,
                                                // Adjust this according to your requirement
                                                placeholder: (context, url) =>
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors
                                                                .orangeAccent,
                                                          ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Image.asset(
                                                      'assets/no_image.jpg',
                                                      // Path to your default image asset
                                                      // Adjust width as per your requirement
                                                      fit: BoxFit
                                                          .cover, // Adjust this according to your requirement
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList()
                            : eventBanner.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return Container(
                                      height: 150.sp,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.90,
                                      // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                      ),
                    ),

                    //  Daily Quiz Exam  Start
                    if (dailyQuizs.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('#a28089'),
                            borderRadius: BorderRadius.circular(
                              10.sp,
                            ), // Adjust for roundness
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8.sp),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.sp,
                                    left: 8.sp,
                                    right: 5.sp,
                                  ),
                                  child: Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: AppConstants.dailyQuiz,
                                          style: GoogleFonts.radioCanada(
                                            textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.sp),
                                  child: Container(
                                    height: 100.sp,
                                    // Set an appropriate height for the ListView
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      // Make it scroll horizontally
                                      itemCount: dailyQuizs.length,
                                      // Number of items in the list
                                      itemBuilder: (context, index) => Padding(
                                        padding: EdgeInsets.all(2.sp),
                                        child: Stack(
                                          children: [
                                            // if(category[index]['planstatus']=='locked')
                                            GestureDetector(
                                              onTap: () {
                                                if (dailyQuizs[index]['test_status'] ==
                                                    'Submited') {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Quiz Already Submitted",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    // Duration: LENGTH_SHORT or LENGTH_LONG
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    // Position: BOTTOM, CENTER, or TOP
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => MockQuizScreen(
                                                        paperId:
                                                            dailyQuizs[index]['id'],
                                                        papername:
                                                            dailyQuizs[index]['name']
                                                                .toString(),
                                                        exmaTime:
                                                            dailyQuizs[index]['time_limit'] !=
                                                                null
                                                            ? dailyQuizs[index]['time_limit']
                                                                  as int
                                                            : 0,
                                                        question: '',
                                                        marks:
                                                            dailyQuizs[index]['total_marks']
                                                                .toString(),
                                                        type: 'testSeries',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 5.sp,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 80.sp,
                                                      height: 70.sp,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.grey.withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.0,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          // Border color
                                                          width: 1
                                                              .sp, // Border width
                                                        ),
                                                        // Rounded corners with radius 10
                                                        // boxShadow: [
                                                        //   BoxShadow(
                                                        //     color: Colors.grey.withOpacity(0.5),
                                                        //     spreadRadius: 2,
                                                        //     blurRadius: 7,
                                                        //     offset: Offset(0, 3),
                                                        //   ),
                                                        // ],
                                                      ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                12.sp,
                                                              ),
                                                          child: Image.asset(
                                                            'assets/quiz_8776742.png',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5.sp),
                                                    Center(
                                                      child: Text(
                                                        dailyQuizs[index]['name']
                                                            .toString(),
                                                        style: GoogleFonts.radioCanada(
                                                          textStyle: TextStyle(
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.white,
                                                          ),
                                                        ),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff536976),
                          borderRadius: BorderRadius.circular(
                            10.sp,
                          ), // Adjust for roundness
                          // border: Border.all(
                          //   color: Colors.grey.shade200, // Border color
                          //   width: 1.sp, // Border width
                          // ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.sp),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.sp,
                                  left: 8.sp,
                                  right: 5.sp,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: AppConstants.allCompetition,
                                        style: GoogleFonts.radioCanada(
                                          textStyle: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 140.sp,
                                // Set an appropriate height for the ListView
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: category.length,
                                  // Number of items in the list
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.all(2.sp),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (category[index]['name'] ==
                                                'BSC Nursing , GNM, & Paramedical') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => NursingState(
                                                    type: '',
                                                    title: 'State Wise',
                                                    description: banner[0]['id']
                                                        .toString(),
                                                    cat: category[index]['id'],
                                                    subCat:
                                                        subcategory[1]['id'],
                                                    catName:
                                                        category[index]['name'],
                                                    initialIndex: 0,
                                                    planstatus:
                                                        '${category[index]['planstatus'].toString()}',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Yearpage(
                                                    title:
                                                        category[index]['name']
                                                            .toString(),
                                                    categoeyId:
                                                        category[index]['id'],
                                                    subcategoeyId:
                                                        subcategory[1]['id'],
                                                    initialIndex: 0,
                                                    type:
                                                        category[index]['name']
                                                            .toString(),
                                                    stateId: null,
                                                    planstatus:
                                                        '${category[index]['planstatus'].toString()}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5.0,
                                            ),
                                            child: Container(
                                              width: 150.sp,
                                              height: 150.sp,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10.sp,
                                                    ),
                                                // Adjust for roundness
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                  // Border color
                                                  width: 1.sp, // Border width
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    0.0,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        category[index]['picture_urls']['image']
                                                            .toString(),
                                                    fit: BoxFit.fill,
                                                    // Adjust this according to your requirement
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: Colors
                                                                    .orangeAccent,
                                                              ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Image.asset(
                                                          'assets/no_image.jpg',
                                                          // Path to your default image asset
                                                          // Adjust width as per your requirement
                                                          fit: BoxFit
                                                              .cover, // Adjust this according to your requirement
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
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
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8.sp),
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('C4DFE6'),
                                borderRadius: BorderRadius.circular(
                                  10.sp,
                                ), // Adjust for roundness
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8.sp),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 8.sp,
                                        left: 8.sp,
                                        right: 5.sp,
                                        bottom: 8.sp,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: AppConstants.mockTest,
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 140.sp,
                                      // Set an appropriate height for the ListView
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        // Make it scroll horizontally
                                        itemCount: category.length,
                                        // Number of items in the list
                                        itemBuilder: (context, index) => Padding(
                                          padding: EdgeInsets.all(2.sp),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (category[index]['name'] ==
                                                      'BSC Nursing , GNM, & Paramedical') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => NursingState(
                                                          type: '',
                                                          title: 'State Wise',
                                                          description:
                                                              banner[0]['id']
                                                                  .toString(),
                                                          cat:
                                                              category[index]['id'],
                                                          subCat:
                                                              subcategory[1]['id'],
                                                          catName:
                                                              category[index]['name'],
                                                          initialIndex: 1,
                                                          planstatus:
                                                              '${category[index]['planstatus'].toString()}',
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => Yearpage(
                                                          title:
                                                              category[index]['name']
                                                                  .toString(),
                                                          categoeyId:
                                                              category[index]['id'],
                                                          subcategoeyId:
                                                              subcategory[1]['id'],
                                                          initialIndex: 1,
                                                          type: '',
                                                          stateId: null,
                                                          planstatus:
                                                              '${category[index]['planstatus'].toString()}',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 5.0,
                                                      ),
                                                  child: Container(
                                                    width: 150.sp,
                                                    height: 150.sp,
                                                    // Set the width of each item
                                                    // Set the width of each item
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.sp,
                                                          ),
                                                      // Adjust for roundness
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        // Border color
                                                        width: 1
                                                            .sp, // Border width
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.0,
                                                          ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              0.0,
                                                            ),
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              category[index]['picture_urls']['mock_image']
                                                                  .toString(),
                                                          fit: BoxFit.fill,
                                                          // Adjust this according to your requirement
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: CircularProgressIndicator(
                                                                  color: Colors
                                                                      .orangeAccent,
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Image.asset(
                                                                'assets/no_image.jpg',
                                                                // Path to your default image asset
                                                                // Adjust width as per your requirement
                                                                fit: BoxFit
                                                                    .cover, // Adjust this according to your requirement
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                            ),
                          ),

                          //  banner image court
                          Padding(
                            padding: EdgeInsets.only(
                              left: 0.sp,
                              right: 0.sp,
                              top: 12.sp,
                              bottom: 5.sp,
                            ),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 80.sp,
                                autoPlay: true,
                                initialPage: 10,
                                viewportFraction: 1,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration: Duration(
                                  milliseconds: 800,
                                ),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: (quoteBanner.length > 0)
                                  ? quoteBanner.map((e) {
                                      return Builder(
                                        builder: (context) {
                                          return InkWell(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2.sp,
                                                vertical: 0,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                clipBehavior: Clip.hardEdge,
                                                child: Container(
                                                  height: 80.sp,
                                                  width: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.0,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          e['picture_urls']
                                                              .toString(),
                                                      fit: BoxFit.fill,
                                                      // Adjust this according to your requirement
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors
                                                                  .orangeAccent,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Image.asset(
                                                            'assets/no_image.jpg',
                                                            // Path to your default image asset
                                                            // Adjust width as per your requirement
                                                            fit: BoxFit
                                                                .cover, // Adjust this according to your requirement
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList()
                                  : quoteBanner.map((e) {
                                      return Builder(
                                        builder: (context) {
                                          return Container(
                                            height: 120.sp,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.90,
                                            // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 8.sp),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff536976),
                                borderRadius: BorderRadius.circular(
                                  10.sp,
                                ), // Adjust for roundness
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8.sp),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 8.sp,
                                        left: 8.sp,
                                        right: 5.sp,
                                        bottom: 8.sp,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: AppConstants.testserices,
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 140.sp,
                                      // Set an appropriate height for the ListView
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        // Make it scroll horizontally
                                        itemCount: category.length,
                                        // Number of items in the list
                                        itemBuilder: (context, index) => Padding(
                                          padding: EdgeInsets.all(2.sp),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (category[index]['name'] ==
                                                      'BSC Nursing , GNM, & Paramedical') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => NursingState(
                                                          type: '',
                                                          title: 'State Wise',
                                                          description:
                                                              banner[0]['id']
                                                                  .toString(),
                                                          cat:
                                                              category[index]['id'],
                                                          subCat:
                                                              subcategory[1]['id'],
                                                          catName:
                                                              category[index]['name'],
                                                          initialIndex: 2,
                                                          planstatus:
                                                              '${category[index]['planstatus'].toString()}',
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => Yearpage(
                                                          title:
                                                              category[index]['name']
                                                                  .toString(),
                                                          categoeyId:
                                                              category[index]['id'],
                                                          subcategoeyId:
                                                              subcategory[1]['id'],
                                                          initialIndex: 2,
                                                          type: '',
                                                          stateId: null,
                                                          planstatus:
                                                              '${category[index]['planstatus'].toString()}',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 5.0,
                                                      ),
                                                  child: Container(
                                                    width: 150.sp,
                                                    height: 140.sp,
                                                    // Set the width of each item
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.sp,
                                                          ),
                                                      // Adjust for roundness
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        // Border color
                                                        width: 1
                                                            .sp, // Border width
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.0,
                                                          ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              0.0,
                                                            ),
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              category[index]['picture_urls']['test_image']
                                                                  .toString(),
                                                          fit: BoxFit.fill,
                                                          // Adjust this according to your requirement
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: CircularProgressIndicator(
                                                                  color: Colors
                                                                      .orangeAccent,
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Image.asset(
                                                                'assets/no_image.jpg',
                                                                // Path to your default image asset
                                                                // Adjust width as per your requirement
                                                                fit: BoxFit
                                                                    .cover, // Adjust this according to your requirement
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 8.sp),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffbbd2c5),
                                borderRadius: BorderRadius.circular(
                                  10.sp,
                                ), // Adjust for roundness
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8.sp),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 8.sp,
                                        left: 8.sp,
                                        right: 5.sp,
                                        bottom: 8.sp,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: AppConstants.prevoiuspaper,
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 140.sp,
                                      // Set an appropriate height for the ListView
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        // Make it scroll horizontally
                                        itemCount: category.length,
                                        // Number of items in the list
                                        itemBuilder: (context, index) => Padding(
                                          padding: EdgeInsets.all(2.sp),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (category[index]['name'] ==
                                                  'BSC Nursing , GNM, & Paramedical') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NursingStateWithoutPlan(
                                                          type: '',
                                                          title: 'State Wise',
                                                          description:
                                                              banner[0]['id']
                                                                  .toString(),
                                                          cat:
                                                              category[index]['id'],
                                                          subCat:
                                                              subcategory[1]['id'],
                                                          catName:
                                                              category[index]['name'],
                                                          initialIndex: 0,
                                                        ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PerviceWithoutPlanYearScreen(
                                                          title:
                                                              category[index]['name']
                                                                  .toString(),
                                                          categoryId:
                                                              category[index]['id'],
                                                          subcategoryId:
                                                              subcategory[1]['id'],
                                                          stateId: null,
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5.0,
                                              ),
                                              child: Container(
                                                width: 150.sp,
                                                height: 140.sp,
                                                // Set the width of each item
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.sp,
                                                      ),
                                                  // Adjust for roundness
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                    // Border color
                                                    width: 1.sp, // Border width
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.0,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          0.0,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          category[index]['picture_urls']['previous_image']
                                                              .toString(),
                                                      fit: BoxFit.fill,
                                                      // Adjust this according to your requirement
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => Center(
                                                            child: CircularProgressIndicator(
                                                              color: Colors
                                                                  .orangeAccent,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Image.asset(
                                                            'assets/no_image.jpg',
                                                            // Path to your default image asset
                                                            // Adjust width as per your requirement
                                                            fit: BoxFit
                                                                .cover, // Adjust this according to your requirement
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
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

                    // Mock Test    close
                    Padding(
                      padding: EdgeInsets.only(top: 8.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffbbd2c5),
                          borderRadius: BorderRadius.circular(
                            10.sp,
                          ), // Adjust for roundness
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.sp),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.sp,
                                  left: 8.sp,
                                  right: 5.sp,
                                  bottom: 0.sp,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: AppConstants.popularPlans,
                                        style: GoogleFonts.radioCanada(
                                          textStyle: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 140.sp,
                                // Set an appropriate height for the ListView
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  // Make it scroll horizontally
                                  itemCount: homePlanlist.length,
                                  // Number of items in the list
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.all(2.sp),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PopularPlanScreen(
                                                  data: homePlanlist[index],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 5.0,
                                        ),
                                        child: Container(
                                          width: 150.sp,
                                          height: 140.sp,
                                          // Set the width of each item
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10.sp,
                                            ),
                                            // Adjust for roundness
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              // Border color
                                              width: 1.sp, // Border width
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                0.0,
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    homePlanlist[index]['image_url']
                                                        .toString(),
                                                fit: BoxFit.fill,
                                                // Adjust this according to your requirement
                                                placeholder: (context, url) =>
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors
                                                                .orangeAccent,
                                                          ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Image.asset(
                                                      'assets/no_image.jpg',
                                                      // Path to your default image asset
                                                      // Adjust width as per your requirement
                                                      fit: BoxFit
                                                          .cover, // Adjust this according to your requirement
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('C4DFE6'),
                            borderRadius: BorderRadius.circular(
                              10.sp,
                            ), // Adjust for roundness
                            // border: Border.all(
                            //   color: Colors.grey.shade200, // Border color
                            //   width: 1.sp, // Border width
                            // ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8.sp),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 3.sp,
                                    left: 8.sp,
                                    right: 5.sp,
                                    bottom: 1.sp,
                                  ),
                                  child: Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: AppConstants.universities,
                                          style: GoogleFonts.radioCanada(
                                            textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CollegeGridScreen();
                                        },
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 120.sp,
                                          width: double.infinity,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            // 10 SP radius for rounded corners
                                            child: Image.asset(
                                              'assets/collogeimage.png',
                                              // Replace with your image path
                                              fit: BoxFit.fill,
                                            ),
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
                      ),
                    ),
                    // video
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 8.0),
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         height: 200.sp,
                    //         child:
                    //             videoUrls.isEmpty ||
                    //                 _controller == null ||
                    //                 !_controller!.value.isInitialized
                    //             ? Center(child: CircularProgressIndicator())
                    //             : Stack(
                    //                 alignment: Alignment.center,
                    //                 children: [
                    //                   AspectRatio(
                    //                     aspectRatio:
                    //                         _controller!.value.aspectRatio,
                    //                     child: VideoPlayer(_controller!),
                    //                   ),
                    //                   Positioned(
                    //                     // bottom: 50,
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.spaceBetween,
                    //                       children: [
                    //                         Padding(
                    //                           padding: const EdgeInsets.only(
                    //                             left: 18.0,
                    //                           ),
                    //                           child: GestureDetector(
                    //                             onTap: playPreviousVideo,
                    //                             child: Icon(
                    //                               Icons.skip_previous,
                    //                               color: Colors.black,
                    //                               size: 40,
                    //                             ),
                    //                           ),
                    //                         ),
                    //
                    //                         SizedBox(width: 10),
                    //                         SizedBox(width: 10),
                    //                         Padding(
                    //                           padding: const EdgeInsets.only(
                    //                             right: 18.0,
                    //                           ),
                    //                           child: GestureDetector(
                    //                             onTap: playNextVideo,
                    //                             child: Icon(
                    //                               Icons.skip_next,
                    //                               color: Colors.black,
                    //                               size: 40,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                   Positioned(
                    //                     top: 10,
                    //                     right: 10,
                    //                     child: IconButton(
                    //                       icon: Icon(
                    //                         isMuted
                    //                             ? Icons.volume_off
                    //                             : Icons.volume_up,
                    //                         color: Colors.black,
                    //                         size: 30,
                    //                       ),
                    //                       onPressed: toggleMute,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('C4DFE6'),
                            borderRadius: BorderRadius.circular(
                              10.sp,
                            ), // Adjust for roundness
                            // border: Border.all(
                            //   color: Colors.grey.shade200, // Border color
                            //   width: 1.sp, // Border width
                            // ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8.sp),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 3.sp,
                                    left: 8.sp,
                                    right: 5.sp,
                                    bottom: 1.sp,
                                  ),
                                  child: Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: AppConstants.news,
                                          style: GoogleFonts.radioCanada(
                                            textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsListScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 250.sp,
                                    // Set an appropriate height for the ListView
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      // Makes ListView take only the necessary space
                                      controller: _scrollController,
                                      itemCount: newsData.length,
                                      // Number of items in the list
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewsListScreen(),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(5.sp),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5.sp),
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
                                                            child: Image.asset(
                                                              'assets/news.png',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10.sp,
                                                          ),
                                                          // Add some spacing
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  '${newsData[index]['title'].toString()}',
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5.sp,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .date_range,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          5.sp,
                                                                    ),
                                                                    Text(
                                                                      '${newsData[index]['entry_date'].toString()}',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            10.sp,
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(0.sp),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              00.sp,
                            ), // Adjust for roundness
                            // border: Border.all(
                            //   color: Colors.grey.shade200, // Border color
                            //   width: 1.sp, // Border width
                            // ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8.sp),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  // elevation: 5,
                                  color: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      5.0,
                                    ), // 5 logical pixels radius
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(3.sp),
                                    child: Text(
                                      'Latest News',
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Image
                                    if (newsData[0]['image'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          '${newsData[0]!['image_urls'].toString()}',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            newsData[0]['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Subtitle
                                          Text(
                                            newsData[0]['description']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          // Icons Row
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePopup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isPopupClosed = prefs.getBool('isPopupClosed') ?? false;

    if (isPopupClosed) return; // agar band kiya to popup na dikhao
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FeatureToolsPage();
                      },
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/addmission_popupI_img.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await prefs.setBool(
                      'isPopupClosed',
                      true,
                    ); // permanently band karna
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Don't show again",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
import '../CommonCalling/progressbarPrimari.dart';
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
  int currentIndex = 0;

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
                                                          PrimaryCircularProgressWidget(),
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
                      padding: const EdgeInsets.all(2.0),
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
                            'assets/admission_tools2.jpeg',
                            fit: BoxFit.fill,
                            height: 160.sp,
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
                            'assets/ksdemosection.jpeg',
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
                                                    OnlineDashBoard(
                                                      isLocked:
                                                          classCategorie[index]['is_locked'],
                                                    ),
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
                                                  'assets/onlinecl.jpeg',
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
                                                  'assets/offline.jpeg',
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
                                                  'assets/praticesimage.jpeg',
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
                                                  'assets/daily.jpeg',
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
                                                          PrimaryCircularProgressWidget(),
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
                        padding: EdgeInsets.all(8.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14.sp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 Header
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.sp,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6.sp),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.quiz_rounded,
                                          color: Colors.white,
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.sp),
                                      Text(
                                        AppConstants.dailyQuiz,
                                        style: GoogleFonts.radioCanada(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10.sp),

                                /// 🔹 Quiz List
                                SizedBox(
                                  height: 100.sp,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dailyQuizs.length,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.sp,
                                    ),
                                    itemBuilder: (context, index) {
                                      final quiz = dailyQuizs[index];
                                      final bool isSubmitted =
                                          quiz['test_status'] == 'Submited';

                                      return GestureDetector(
                                        onTap: () {
                                          if (isSubmitted) {
                                            _showSubmittedPopup(context);
                                            return;
                                          }
                                          else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MockQuizScreen(
                                                  paperId: quiz['id'],
                                                  papername: quiz['name']
                                                      .toString(),
                                                  exmaTime:
                                                      quiz['time_limit'] != null
                                                      ? quiz['time_limit']
                                                            as int
                                                      : 0,
                                                  question: '',
                                                  marks: quiz['total_marks']
                                                      .toString(),
                                                  type: 'testSeries',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 95.sp,
                                          margin: EdgeInsets.only(right: 10.sp),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              14.sp,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.12,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              /// 🔸 Submitted Badge
                                              if (isSubmitted)
                                                Positioned(
                                                  top: 3,
                                                  right: 3,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.sp,
                                                          vertical: 2.sp,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.sp,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "DONE",
                                                      style: TextStyle(
                                                        fontSize: 7.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              /// 🔸 Content
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 50.sp,
                                                      width: 50.sp,
                                                      padding: EdgeInsets.all(
                                                        5.sp,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: HexColor(
                                                          '#EEF2FF',
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.sp,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        'assets/quizimag.png',
                                                      ),
                                                    ),
                                                    SizedBox(height: 3.sp),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 6.sp,
                                                          ),
                                                      child: Text(
                                                        quiz['name'].toString(),
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.radioCanada(
                                                              fontSize: 11.sp,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color:
                                                                  Colors.black87,
                                                            ),
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
                                                        category[index]['planstatus']
                                                            .toString(),
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
                                                              PrimaryCircularProgressWidget(),
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
                                                                child:
                                                                    PrimaryCircularProgressWidget(),
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
                                                            child:
                                                                PrimaryCircularProgressWidget(),
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
                                    SizedBox(
                                      height: 140.sp,
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
                                                                child:
                                                                    PrimaryCircularProgressWidget(),
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
                                                            child:
                                                                PrimaryCircularProgressWidget(),
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
                                                          PrimaryCircularProgressWidget(),
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
                                              'assets/collogeimag.jpeg',
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
                    //             ? Center(child: PrimaryCircularProgressWidget())
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
                                if (newsData.isEmpty)
                                  const SizedBox()
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top Image (safe)
                                      if ((newsData.first['image_urls'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(0),
                                              ),
                                          child: Image.network(
                                            (newsData.first['image_urls'] ?? '')
                                                .toString(),
                                            width: double.infinity,
                                            height: 180,
                                            // optional (recommended)
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const SizedBox(), // avoid crash on bad url
                                          ),
                                        ),

                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (newsData.first['title'] ?? '')
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              (newsData.first['description'] ??
                                                      '')
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
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
  void _showSubmittedPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "submitted",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, a2, child) {
        final curved = Curves.easeOutBack.transform(anim.value);

        return Transform.scale(
          scale: curved,
          child: Opacity(
            opacity: anim.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.86,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A1AFF),
                        Color(0xFF010071),

                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // top icon
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22C55E).withOpacity(0.15),
                            border: Border.all(
                              color: const Color(0xFF22C55E),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF16A34A),
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Already Submitted",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Your quiz has already been submitted.\nYou can view results if available.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.35,
                            fontSize: 13.5,
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: BorderSide(
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: const Color(0xFF16A34A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: yaha "View Result" ka navigation daal do agar chaho
                                  // Navigator.push(...);
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

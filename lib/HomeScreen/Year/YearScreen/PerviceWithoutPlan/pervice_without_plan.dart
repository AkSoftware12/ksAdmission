import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realestate/HomeScreen/Year/YearScreen/pervices_paper_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../CommonCalling/data_not_found.dart';
import '../../../../CommonCalling/progressbarWhite.dart';
import '../../../../Utils/app_colors.dart';
import '../../../../Utils/image.dart';
import '../../../../baseurl/baseurl.dart';
import '../../../home_screen.dart';

class PerviceWithoutPlanYearScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final int subcategoryId;
  final int? stateId;

  const PerviceWithoutPlanYearScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.subcategoryId,
    required this.stateId,
  });

  @override
  State<PerviceWithoutPlanYearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends State<PerviceWithoutPlanYearScreen> {
  List<dynamic> year = [];
  bool isLoading = false; // Add this for the loading state
  List<dynamic> banner = [];


  final List<Color> colorList = [primaryColor, Colors.white];

  @override
  void initState() {
    super.initState();
    fetchYearData(widget.categoryId);
    hitAllCategory();
  }

  Future<void> fetchYearData(int categoryId) async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final url = Uri.parse(years); // Replace with your API URL

    // Request body containing the category_id
    final body = jsonEncode({'category_id': categoryId});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Adjust headers if necessary
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data')) {
        setState(() {
          year = responseData['data'];
          isLoading = false; // Stop progress bar
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      setState(() {
        isLoading = false; // Stop progress bar on exception
      });
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

      if (responseData.containsKey('banners')) {
        setState(() {
          banner = responseData['banners'];
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
    return Scaffold(
      backgroundColor: primaryColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${widget.title}  ${' PREVIOUS PAPERS'}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? WhiteCircularProgressWidget()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: (banner.length > 0)
                        ? banner.map((e) {
                            return Builder(
                              builder: (context) {
                                return InkWell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.sp,
                                      vertical: 0,
                                    ),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      clipBehavior: Clip.hardEdge,
                                      child: Container(
                                        height: 110.sp,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: e['picture_urls']
                                                .toString(),
                                            fit: BoxFit.fill,
                                            // Adjust this according to your requirement
                                            placeholder: (context, url) =>
                                                Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            Colors.orangeAccent,
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
                                      MediaQuery.of(context).size.width * 0.90,
                                  // margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    top: 5.sp,
                    left: 8.sp,
                    right: 5.sp,
                    bottom: 5.sp,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.title}${' PREVIOUS PAPERS'}',
                        style: GoogleFonts.radioCanada(
                          textStyle: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                year.isEmpty
                    ? DataNotFoundWidget()
                    : Flexible(
                        child: GridView.count(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          // Disable scrolling
                          crossAxisCount: 2,
                          childAspectRatio: .85,
                          children: List.generate(
                            year.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrvicesPaperList(
                                        yesrId: year[index]['id'],
                                        year:
                                            '${widget.title}${' PREVIOUS PAPERS '}${year[index]['year'].toString()}',
                                        categoryId: widget.categoryId,
                                        subcategoryId: widget.subcategoryId,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      // height: 200.sp,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: colorList,
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        // Rounded corners with radius 10
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white,
                                            spreadRadius: 1.sp,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 30.sp,
                                              width: 30.sp,
                                              decoration: BoxDecoration(
                                                color: Colors.white,

                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15.sp,
                                                    ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.sp),
                                                child: Image.asset(logo),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.sp,
                                                right: 8.sp,
                                              ),
                                              child: Text(
                                                '${widget.title}${' PREVIOUS PAPER '}${year[index]['year'].toString()} ',
                                                // year[index]['year'].toString(),
                                                style: GoogleFonts.cabin(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // borderRadius: BorderRadius.circular(10.sp)
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10.sp),
                                            topLeft: Radius.circular(10.sp),
                                            topRight: Radius.circular(5.sp),
                                            bottomRight: Radius.circular(0.sp),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(3.sp),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 8.sp,
                                              right: 8.sp,
                                            ),
                                            child: Text(
                                              year[index]['year'].toString(),
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        height: 75.sp,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // borderRadius: BorderRadius.circular(10.sp)
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10.sp),
                                            // topLeft: Radius.circular(10.sp),
                                            // topRight: Radius.circular(10.sp),
                                            bottomRight: Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2.sp),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 8.sp,
                                                      right: 8.sp,
                                                    ),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text:
                                                            '${'-'}${'${widget.title}${' PREVIOUS PAPER '}${year[index]['year'].toString()} '}',
                                                        style: GoogleFonts.radioCanada(
                                                          textStyle: TextStyle(
                                                            fontSize: 6.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 8.sp,
                                                      right: 8.sp,
                                                    ),
                                                    child: Text(
                                                      '${'- '}${'Get All India Rank'}',
                                                      style:
                                                          GoogleFonts.radioCanada(
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize:
                                                                      6.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Container(
                                          width: double.infinity,
                                          height: 20.sp,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            // borderRadius: BorderRadius.circular(10.sp)
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                10.sp,
                                              ),
                                              topLeft: Radius.circular(10.sp),
                                              topRight: Radius.circular(10.sp),
                                              bottomRight: Radius.circular(
                                                10.sp,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Continue',
                                              style: GoogleFonts.radioCanada(
                                                textStyle: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
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
                        ),
                      ),
              ],
            ),
    );
  }
}

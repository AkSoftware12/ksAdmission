import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../HomePage/home_page.dart';
import '../../Utils/app_colors.dart';
import '../Counselor/counselor_payment.dart';
import '../INDRODUCATION/Introduction.dart';
import 'best_college.dart';

class AllIndiaCollegeListScreen extends StatefulWidget {
  final String rank;
  final String type;

  const AllIndiaCollegeListScreen({super.key, required this.rank, required this.type});

  @override
  State<AllIndiaCollegeListScreen> createState() => _AllIndiaRankScreenState();
}

class _AllIndiaRankScreenState extends State<AllIndiaCollegeListScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _fatherNameController = TextEditingController();
  bool _isLoading = false;

  late SearchableDropdownController<int> searchableDropdownController;
  late SearchableDropdownController<int> searchableDropdownController2;
  late SearchableDropdownController<int> searchableDropdownController3;
  static final Map<String, List<SearchableDropdownMenuItem<int>>> _cache = {};
  String? selectedCourse;
  String? selectedCategory;
  String? selectedQuota;
  String? lokjText;
  int? textType;
  bool isLoading = false;
  List<dynamic> counseling = [];
  List<dynamic> filteredCounseling = [];
  List<dynamic> cat = [];
  List<dynamic> courseList = [];
  List<dynamic> quotaName = [];
  int visibleItemCount = 10;

  final List<IconData> icons = [
    Icons.school,
    Icons.local_hospital,
    Icons.local_hospital,
    Icons.school,
    Icons.nightlight_round,
    Icons.school,
  ];
  final List<Color> color = [
    Colors.purple,
    Colors.orange,
    Colors.redAccent,
    Colors.green,
    Colors.black,
    Colors.yellow,
    Colors.pink,
  ];



  @override
  void initState() {
    super.initState();
    searchableDropdownController = SearchableDropdownController<int>();
    searchableDropdownController2 = SearchableDropdownController<int>();
    searchableDropdownController3 = SearchableDropdownController<int>();

    collegeList(widget.rank, '', '', '');
  }

  Future<void> collegeList(String rank, String course, String category, String quota) async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    // Construct the URL with query parameters for course, category, and quota
    var queryParameters = {
      'course': course,
      'category': category,
      'quota': quota,
    }.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');

    var url = Uri.parse('$counselingTool${queryParameters.isNotEmpty ? '?$queryParameters' : ''}');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rank': rank,
        'type': widget.type,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        lokjText=responseData['message'].toString();
        textType=responseData['type'];
      });


      if (responseData.containsKey('college')) {
        setState(() {
          counseling = responseData['college'];
          cat = responseData['cat'] ?? [];
          courseList = responseData['course'] ?? [];
          quotaName = responseData['QuotaName'] ?? [];
          filteredCounseling = counseling;
          isLoading = false;

          print("Course List: $courseList");
          print("Cat: $cat");
          print("Quota Name: $quotaName");
        });
      }

      else {
        isLoading = false;
        showRestrictedDialog(context);
        throw Exception('Invalid API response: Missing "college" key');
      }
    } else {
      print('Failed: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }


  void _applyFilters() {
    setState(() {
      isLoading = true;
    });
    // Call the API with selected filters
    collegeList(
      widget.rank,
      selectedCourse ?? '',
      selectedCategory ?? '',
      selectedQuota ?? '',
    );
  }

  void _resetFilters() {
    setState(() {
      selectedCourse = null;
      selectedCategory = null;
      selectedQuota = null;
      searchableDropdownController.clear();
      searchableDropdownController2.clear();
      searchableDropdownController3.clear();
      filteredCounseling = List.from(counseling);
      visibleItemCount = 10;
    });
    // Call the API with no filters
    collegeList(widget.rank, '', '', '');
  }


  void showRestrictedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 8,
            backgroundColor: Colors.transparent, // Important: transparent so we see container's background
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tools_bg.jpg',), // 👈 apni image ka path yahan dein
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Access Restricted',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$lokjText',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {

                        if(textType.toString()=='0'){
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); //
                          Navigator.pop(context); //
                        }else if(textType.toString()=='1'){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Homepage(
                                initialIndex: 0,
                              ),
                            ),
                          );
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: (textType.toString()=='0')?
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ): Text(
                        'Unlock Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFF124559),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF124559),
          secondary: Color(0xFF124559),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, color: Colors.black87),
          labelLarge: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF124559), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: fontSize - 2),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              // 'assets/toolbg.jpeg',
              'assets/tools_bg.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            CustomScrollView(
              slivers: [

                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 5,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.sp),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: HexColor('#00696f'),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'All India College List',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  pinned: true,
                  floating: false,
                  snap: false,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel('Filter Colleges', fontSize, Icon(Icons.filter_alt)),

                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Select Course',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: courseList
                                      .map((dynamic item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedCourse,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedCourse = value;
                                    });
                                  },
                                  customButton: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            selectedCourse ?? 'Select Course',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: selectedCourse == null ? Colors.grey : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (selectedCourse != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedCourse = null; // Clear the selection
                                              });
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              size: 18.sp,
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            size: 20.sp,
                                            color: Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(Icons.keyboard_arrow_down_outlined),
                                    iconSize: 20.sp,
                                    iconEnabledColor: Colors.black,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: MediaQuery.of(context).size.width*1,

                                    padding: EdgeInsets.symmetric(horizontal: 10.sp), // Updated padding for open container
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white,
                                    ),
                                    offset: const Offset(-20, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness: MaterialStateProperty.all<double>(6),
                                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Select Category',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: cat
                                      .map((dynamic item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedCategory,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                  customButton: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            selectedCategory ?? 'Select Category',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: selectedCategory == null ? Colors.grey : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (selectedCategory != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedCategory = null; // Clear the selection
                                              });
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              size: 18.sp,
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            size: 20.sp,
                                            color: Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(Icons.keyboard_arrow_down_outlined),
                                    iconSize: 20.sp,
                                    iconEnabledColor: Colors.black,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: MediaQuery.of(context).size.width*1,

                                    padding: EdgeInsets.symmetric(horizontal: 10.sp), // Updated padding for open container
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white,
                                    ),
                                    offset: const Offset(-20, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness: MaterialStateProperty.all<double>(6),
                                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.sp),

                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Select Quota',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: quotaName
                                      .map((dynamic item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedQuota,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedQuota = value;
                                    });
                                  },
                                  customButton: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            selectedQuota ?? 'Select Quota',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: selectedQuota == null ? Colors.grey : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (selectedQuota != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedQuota = null; // Clear the selection
                                              });
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              size: 18.sp,
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            size: 20.sp,
                                            color: Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    padding: const EdgeInsets.only(left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(Icons.keyboard_arrow_down_outlined),
                                    iconSize: 20.sp,
                                    iconEnabledColor: Colors.black,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: MediaQuery.of(context).size.width*1,

                                    padding: EdgeInsets.symmetric(horizontal: 10.sp), // Updated padding for open container
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white,
                                    ),
                                    offset: const Offset(-20, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness: MaterialStateProperty.all<double>(6),
                                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: HexColor('#f1f5f9'),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: InkWell(
                                        onTap: _resetFilters,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.refresh, color: HexColor('#64748b')),
                                              SizedBox(width: 8),
                                              Text(
                                                'Reset Filters',
                                                style: TextStyle(
                                                  color: HexColor('#64748b'),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.sp),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: HexColor('#124559'),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: InkWell(
                                        onTap: _applyFilters,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Apply Filters',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                            ],
                          ),
                        ),
                      ),

                      CounselorCard(),

                      Padding(
                        padding: EdgeInsets.only(top: 10.sp),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return BestCollegesScreen(rank: widget.rank,);
                                  },
                                ),
                              );
                          },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [HexColor('#FF5F6D'), HexColor('#FFC371')],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),

                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(12.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 18.sp,
                                        width: 18.sp,
                                        child: Image.asset('assets/crown.png', color: Colors.white),
                                      ),
                                      SizedBox(width: 5.sp),
                                      Text(
                                        'View Best Colleges',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 18.sp,
                                    width: 18.sp,
                                    child: Icon(CupertinoIcons.right_chevron, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 0),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.list,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                            SizedBox(width: 5.sp),
                            Text(
                              'All Eligible Colleges Seats ${'(${filteredCounseling.length.toString()})'}',
                              style: TextStyle(
                                fontSize:17.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                          ],
                        ),
                      ),
                      isLoading
                          ? PrimaryCircularProgressWidget()
                          : ListView.builder(
                        itemCount: (filteredCounseling.length > visibleItemCount)
                            ? visibleItemCount
                            : filteredCounseling.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          var college = filteredCounseling[index];
                          int iconIndex = index % icons.length;
                          int colorIndex = index % color.length;

                          return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CounselorPaymentPage(),
                                ),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none, // Allows overflow for chips outside the ListTile
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5), // Consistent margin
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Consistent padding
                                    leading: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color[colorIndex].withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icons[iconIndex], color: color[colorIndex]),
                                    ),
                                    title: Text(
                                      college["Institute"] ?? 'Unknown Institute',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      college["course"] ?? 'Unknown Course',
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: (college["Category"] != null
                                          ? college["Category"].toString().split(",")
                                          : ["N/A"])
                                          .asMap()
                                          .entries
                                          .map<Widget>((entry) {
                                        final index = entry.key;
                                        final category = entry.value.trim();
                                        return AnimatedScale(
                                          scale: 1.0,
                                          duration: Duration(milliseconds: 300 + (index * 100)), // Reduced stagger for subtlety
                                          curve: Curves.easeOut,
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 0,top: 5), // Space between chips
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.withOpacity(0.2), // Softer, less vibrant color
                                              borderRadius: BorderRadius.circular(8),
                                              // border: Border.all(
                                              //   color: Colors.grey.shade300, // Subtle border to blend with ListTile
                                              //   width: 1,
                                              // ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '   ${category.toUpperCase()}',
                                                  style: TextStyle(
                                                    color: Colors.black87, // Neutral color for better integration
                                                    fontSize: 9.sp,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                if (college["SubCategory"] != null &&
                                                    college["SubCategory"] != 'NO' &&
                                                    college["SubCategory"].toString().trim().isNotEmpty &&
                                                    college["SubCategory"].toString().trim().toLowerCase() != 'null') ...[
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "/",
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 9.sp,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    college["SubCategory"].toString().trim().toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 9.sp,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: (visibleItemCount < (filteredCounseling?.length ?? 0))
                            ? _isLoading
                            ?  Center(child: SizedBox(
                          height: 15.sp,
                          width: 15.sp,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ))
                            : TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true; // Show progress indicator
                            });
                            // Simulate loading for 3 seconds
                            Future.delayed(const Duration(seconds: 3), () {
                              setState(() {
                                visibleItemCount = (visibleItemCount + 10 >
                                    (filteredCounseling?.length ?? 0))
                                    ? (filteredCounseling?.length ?? 0)
                                    : visibleItemCount + 10;
                                _isLoading = false; // Hide progress indicator
                              });
                            });
                          },
                          child: Text(
                            "Load More",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),

                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text, double fontSize, Icon icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: Row(
        children: [
          icon,
          SizedBox(width: 5.sp),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.w800,
              color: HexColor('#124559'),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<SearchableDropdownMenuItem<int>>> getAnimeList({
    required int page,
    String? key,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final filteredCourses = (key != null && key.isNotEmpty)
        ? courseList.asMap().entries.where((entry) {
      return entry.value.toString().toLowerCase().contains(key.toLowerCase());
    }).toList()
        : courseList.asMap().entries.toList();

    return filteredCourses.map((entry) {
      int index = entry.key;
      var course = entry.value;
      return SearchableDropdownMenuItem<int>(
        value: index,
        label: course.toString(),
        child: Text(course.toString()),
      );
    }).toList();
  }

  Future<List<SearchableDropdownMenuItem<int>>> getAnimeList2({
    required int page,
    String? key,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final filteredCategories = (key != null && key.isNotEmpty)
        ? cat.asMap().entries.where((entry) {
      return entry.value.toString().toLowerCase().contains(key.toLowerCase());
    }).toList()
        : cat.asMap().entries.toList();

    return filteredCategories.map((entry) {
      int index = entry.key;
      var category = entry.value;
      return SearchableDropdownMenuItem<int>(
        value: index,
        label: category.toString(),
        child: Text(category.toString()),
      );
    }).toList();
  }

  Future<List<SearchableDropdownMenuItem<int>>> getAnimeList3({
    required int page,
    String? key,
  }) async {
    final cacheKey = '${page}_${key ?? ''}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    await Future.delayed(const Duration(seconds: 1));
    final filteredQuotas = (key != null && key.isNotEmpty)
        ? quotaName.asMap().entries.where((entry) {
      return entry.value.toString().toLowerCase().contains(key.toLowerCase());
    }).toList()
        : quotaName.asMap().entries.toList();

    final result = filteredQuotas.map((entry) {
      int index = entry.key;
      var quota = entry.value;
      return SearchableDropdownMenuItem<int>(
        value: index,
        label: quota.toString(),
        child: Text(quota.toString()),
      );
    }).toList();

    _cache[cacheKey] = result;
    return result;
  }
}





class CounselorCard extends StatefulWidget {
  const CounselorCard({super.key});

  @override
  _CounselorCardState createState() => _CounselorCardState();
}

class _CounselorCardState extends State<CounselorCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration for one zoom cycle
    );

    // Create a Tween for scaling between 1.0 and 1.1
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Smooth easing for zoom effect
      ),
    );

    // Set the animation to repeat indefinitely
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 12.sp),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12.r),
          shadowColor: Colors.black.withOpacity(0.2),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CounselorPaymentPage(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [HexColor('#2658a0'), HexColor('#5b1ca1')],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(8.sp),
              child: Row(
                children: [
                  SizedBox(
                    height: 60.sp,
                    width: 60.sp,
                    child: Image.asset(
                      'assets/support.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error, size: 30.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect With Your Counselor',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          semanticsLabel: 'Connect with your counselor',
                        ),
                        SizedBox(height: 6.sp),
                        Text(
                          'Get personalized guidance now',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CounselorPaymentPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.sp,
                              vertical: 0.sp,
                            ),
                          ),
                          child: Text(
                            'Click Here',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
import '../AllIndia/best_college.dart';
import '../Counselor/counselor_payment.dart';
import '../INDRODUCATION/Introduction.dart';
import 'best_college_state.dart';

class StateCollegeListScreen extends StatefulWidget {
  final String rank;
  final String score;
  final String state;

  const StateCollegeListScreen(
      {super.key,
        required this.rank,
        required this.state,
        required this.score});

  @override
  State<StateCollegeListScreen> createState() => _AllIndiaRankScreenState();
}

class _AllIndiaRankScreenState extends State<StateCollegeListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _fatherNameController = TextEditingController();

  late SearchableDropdownController<int> searchableDropdownController;
  late SearchableDropdownController<int> searchableDropdownController2;
  late SearchableDropdownController<int> searchableDropdownController3;
  static final Map<String, List<SearchableDropdownMenuItem<int>>> _cache = {};
  String? selectedCourse;
  String? selectedCategory;
  String? selectedQuota;
  bool isLoading = false;
  List<dynamic> counseling = [];
  List<dynamic> filteredCounseling = [];
  List<dynamic> cat = [];
  List<dynamic> courseList = [];
  List<dynamic> quotaName = [];
  int visibleItemCount = 10;
  String? lokjText;
  int? textType;
  bool _isLoading = false;
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

  Future<void> collegeList(
      String rank, String course, String category, String quota) async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    var queryParameters = {
      'course': course,
      'category': category,
      'college_type': quota,
    }
        .entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) =>
    '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');

    var url = Uri.parse(
        '$counselingToolStatesCollegeList${queryParameters.isNotEmpty ? '?$queryParameters' : ''}');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rank': rank,
        'score': widget.score,
        'state': widget.state,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        lokjText = responseData['message'].toString();
        textType = responseData['type'];
      });

      if (responseData.containsKey('college')) {
        setState(() {
          counseling = responseData['college'] ?? [];
          cat = responseData['cat'] ?? [];
          courseList = responseData['course'] ?? [];
          quotaName = responseData['QuotaName'] ?? [];
          filteredCounseling = counseling;
          isLoading = false;

          print("Course List: $courseList");
          print("Cat: $cat");
          print("Quota Name: $quotaName");
        });
      } else {
        setState(() {
          isLoading = false;
        });
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
    collegeList(widget.rank, '', '', '');
  }


  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: HexColor('#5e19a1'), width: 2),
      ),
      builder: (BuildContext context) {
        // Initialize local state variables for the bottom sheet
        String? localSelectedCourse = selectedCourse;
        String? localSelectedCategory = selectedCategory;
        String? localSelectedQuota = selectedQuota;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter bottomSheetSetState) {
            return Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Colleges',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HexColor('#5e19a1'),
                            fontSize: 20.sp,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 22.sp,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.sp),
                  Padding(
                    padding:  EdgeInsets.only(top: 0.sp, bottom: 0),
                    child: Row(
                      children: [
                        SizedBox(width: 5.sp),
                        Text(
                          'Select Course',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.sp),

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
                      value: localSelectedCourse,
                      onChanged: (String? value) {
                        bottomSheetSetState(() {
                          localSelectedCourse = courseList.contains(value) ? value : null;
                        });
                        // Update the parent state
                        setState(() {
                          selectedCourse = localSelectedCourse;
                        });
                      },
                      customButton: Container(
                        height: 50.sp,
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
                                localSelectedCourse ?? 'Select Course',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: localSelectedCourse == null ? Colors.grey : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (localSelectedCourse != null)
                              GestureDetector(
                                onTap: () {
                                  bottomSheetSetState(() {
                                    localSelectedCourse = null;
                                  });
                                  setState(() {
                                    selectedCourse = null;
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
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
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
                  Padding(
                    padding:  EdgeInsets.only(top: 0.sp, bottom: 0),
                    child: Row(
                      children: [
                        SizedBox(width: 5.sp),
                        Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.sp),
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
                      value: localSelectedCategory,
                      onChanged: (String? value) {
                        bottomSheetSetState(() {
                          localSelectedCategory = value;
                        });
                        setState(() {
                          selectedCategory = localSelectedCategory;
                        });
                      },
                      customButton: Container(
                        height: 50.sp,
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
                                localSelectedCategory ?? 'Select Category',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: localSelectedCategory == null ? Colors.grey : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (localSelectedCategory != null)
                              GestureDetector(
                                onTap: () {
                                  bottomSheetSetState(() {
                                    localSelectedCategory = null;
                                  });
                                  setState(() {
                                    selectedCategory = null;
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
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
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
                  Padding(
                    padding:  EdgeInsets.only(top: 0.sp, bottom: 0),
                    child: Row(
                      children: [
                        SizedBox(width: 5.sp),
                        Text(
                          'Select Type',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: const Row(
                        children: [
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Select Type',
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
                      value: localSelectedQuota,
                      onChanged: (String? value) {
                        bottomSheetSetState(() {
                          localSelectedQuota = value;
                        });
                        setState(() {
                          selectedQuota = localSelectedQuota;
                        });
                      },
                      customButton: Container(
                        height: 50.sp,
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
                                localSelectedQuota ?? 'Select Type',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: localSelectedQuota == null ? Colors.grey : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (localSelectedQuota != null)
                              GestureDetector(
                                onTap: () {
                                  bottomSheetSetState(() {
                                    localSelectedQuota = null;
                                  });
                                  setState(() {
                                    selectedQuota = null;
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
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
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
                  SizedBox(height: 50.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            bottomSheetSetState(() {
                              localSelectedCourse = null;
                              localSelectedCategory = null;
                              localSelectedQuota = null;
                            });
                            setState(() {
                              selectedCourse = null;
                              selectedCategory = null;
                              selectedQuota = null;
                            });
                            _resetFilters();
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 40.sp,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  HexColor('#5e19a1'),
                                  Colors.redAccent.shade200,
                                ],
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
                                'Reset',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCourse = localSelectedCourse;
                              selectedCategory = localSelectedCategory;
                              selectedQuota = localSelectedQuota;
                            });
                            _applyFilters();
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 40.sp,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  HexColor('#5e19a1'),
                                  Colors.purple.shade200,
                                ],
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
                                'Apply',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
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
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tools_bg.jpg'),
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
                    lokjText ?? 'Access to this content is restricted.',
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
                        if (textType == 0) {
                          Navigator.pop(context);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } else if (textType == 1) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Homepage(initialIndex: 0),
                            ),
                                (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        textType == 0 ? 'Back' : 'Unlock Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
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
      child:Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/tools_bg.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Replace SliverAppBar with AppBar or a custom Container
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 30.sp,
                                width: 30.sp,
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
                            Text(
                              'State College List',
                              style: GoogleFonts.nunito(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Card(
                              elevation: 5,
                              color: HexColor('#124559'),
                              child: InkWell(
                                onTap: _showFilterBottomSheet,
                                child:  Padding(
                                  padding: EdgeInsets.all(8.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.filter_alt, color: Colors.white,size: 20,),
                                      SizedBox(width: 8),
                                      Text(
                                        'Advance Search',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
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
                  // Replace SliverToBoxAdapter with regular widgets in Column

                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.26,
                    child: Padding(
                      padding:  EdgeInsets.all(5.sp),
                      child: Column(
                        children: [
                          CounselorCard(),
                          Padding(
                            padding: EdgeInsets.only(top: 10.sp),
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return StateBestCollegesScreen(
                                          rank: widget.rank,
                                          score: widget.score,
                                          state: widget.state,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        HexColor('#2658a0'),
                                        HexColor('#5b1ca1')
                                      ],
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
                                            child: Image.asset(
                                              'assets/crown.png',
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8.sp),
                                          Text(
                                            'View Best Colleges',
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 18.sp,
                                        width: 18.sp,
                                        child: Icon(
                                          CupertinoIcons.right_chevron,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.only(top: 8.sp, bottom: 0),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.list,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 5.sp),
                                Text(
                                  'All Eligible Colleges Seats (${filteredCounseling.length.toString()})',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CounselingList section
                  Container(
                    decoration: BoxDecoration(
                      color: HexColor('#02134E'),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.57,
                      child: isLoading
                          ? PrimaryCircularProgressWidget()
                          :CounselingList(
                        filteredCounseling: filteredCounseling ?? [],
                        visibleItemCount: visibleItemCount,
                        icons: const [Icons.school, Icons.book, Icons.star],
                        color: const [
                          Colors.blue,
                          Colors.green,
                          Colors.red,
                          Colors.purple,
                          Colors.orangeAccent,
                          Colors.brown,
                          Colors.teal,
                          Colors.indigo,
                          Colors.cyan,
                          Colors.amber,
                          Colors.deepOrange,
                          Colors.deepPurple,
                          Colors.lightBlue,
                          Colors.lightGreen,
                          Colors.lime,
                          Colors.pink,
                          Colors.yellow,
                          Colors.grey,
                          Colors.blueGrey,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  // Load More button
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
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<List<SearchableDropdownMenuItem<int>>> getAnimeList({
    required int page,
    String? key,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final filteredCourses = (key != null && key.isNotEmpty)
        ? courseList.asMap().entries.where((entry) {
      return entry.value
          .toString()
          .toLowerCase()
          .contains(key.toLowerCase());
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
      return entry.value
          .toString()
          .toLowerCase()
          .contains(key.toLowerCase());
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
      return entry.value
          .toString()
          .toLowerCase()
          .contains(key.toLowerCase());
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

class _CounselorCardState extends State<CounselorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 0.sp),
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
                  colors: [HexColor('#FF5F6D'), HexColor('#FFC371')],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(3.sp),
              child: Row(
                children: [
                  SizedBox(
                    height: 40.sp,
                    width: 40.sp,
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
                        Text(
                          'Get personalized guidance now',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const CounselorPaymentPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.sp,
                              vertical: 0.sp,
                            ),
                          ),
                          child: Text(
                            'Click Here',
                            style: TextStyle(
                              fontSize: 13.sp,
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



class CounselingList extends StatefulWidget {
  final List<dynamic> filteredCounseling;
  final int visibleItemCount;
  final List<IconData> icons;
  final List<Color> color;

  const CounselingList({
    required this.filteredCounseling,
    required this.visibleItemCount,
    required this.icons,
    required this.color,
    Key? key,
  })  : assert(visibleItemCount >= 0, 'visibleItemCount must be non-negative'),
        super(key: key);

  @override
  _CounselingListState createState() => _CounselingListState();
}

class _CounselingListState extends State<CounselingList> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _initializeExpandedList();
  }

  @override
  void didUpdateWidget(CounselingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filteredCounseling != widget.filteredCounseling) {
      _initializeExpandedList();
    }
  }

  void _initializeExpandedList() {
    _isExpanded = List<bool>.filled(widget.filteredCounseling.length, false);
  }

  void _toggleExpanded(int index) {
    if (index >= 0 && index < _isExpanded.length) {
      setState(() {
        _isExpanded[index] = !_isExpanded[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filteredCounseling.isEmpty) {
      return const Center(child: Text('No colleges found'));
    }

    final List<IconData> safeIcons =
    widget.icons.isNotEmpty ? widget.icons : [Icons.school];
    final List<Color> safeColors =
    widget.color.isNotEmpty ? widget.color : [Colors.blue];

    return ListView.builder(
      itemCount: widget.filteredCounseling.length > widget.visibleItemCount
          ? widget.visibleItemCount
          : widget.filteredCounseling.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      itemBuilder: (context, index) {
        var college = widget.filteredCounseling[index];
        int iconIndex = index % safeIcons.length;
        int colorIndex = index % safeColors.length;

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1b2a5f).withOpacity(0.9),
                    safeColors[colorIndex].withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: safeColors[colorIndex].withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    safeIcons[iconIndex],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final text = college["college_name"] ?? 'Unknown Institute';
                    final textStyle = TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.white,
                    );

                    return RichText(
                      text: TextSpan(
                        style: textStyle,
                        children: [
                          TextSpan(
                            text: index < _isExpanded.length && _isExpanded[index]
                                ? text
                                : (text.length > 40
                                ? text.substring(0, 40) + '...'
                                : text),
                          ),
                          if (text.length > 40)
                            TextSpan(
                              text: index < _isExpanded.length && _isExpanded[index]
                                  ? ' See Less'
                                  : ' See More',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _toggleExpanded(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    college["course"] ?? 'Unknown Course',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing:  GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CounselorPaymentPage(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child:  Row(
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
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOut,
                      child: Container(
                        margin: const EdgeInsets.only(left: 0, top: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(1.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${category.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (college["SubCategory"] != null &&
                                  college["SubCategory"] != 'NO' &&
                                  college["SubCategory"] != '-' &&
                                  college["SubCategory"].toString().trim().isNotEmpty &&
                                  college["SubCategory"].toString().trim().toLowerCase() != 'null') ...[
                                const SizedBox(width: 2),
                                Text(
                                  "/",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  college["SubCategory"].toString().trim().toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
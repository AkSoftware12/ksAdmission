import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/KsTools/StateWise/state_mark_colloge_list_screen.dart';
import 'package:realestate/Utils/app_colors.dart';

import '../AllIndia/all_india_rank_list_screen.dart';

class StateWiseRankScreen extends StatefulWidget {

  final List<dynamic> state;

  const StateWiseRankScreen({super.key, required this.state});

  @override
  State<StateWiseRankScreen> createState() => _StateWiseRankScreenState();
}

class _StateWiseRankScreenState extends State<StateWiseRankScreen> {
  final TextEditingController rankController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  bool _isAgreed = true;
  String? selectedState;
  int? _selectedOption=0;


  void _findColleges() {
    if (selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a state')),
      );
      return;
    }
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the terms and conditions')),
      );
      return;
    }

    // Navigate to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StateCollegeListScreen(
              rank: rankController.text,
              score: marksController.text,
              state: selectedState!,
              // rank: rankController.text,
            ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: double.infinity,
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/tools_bg.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 35.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
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
                    SizedBox(width: 10.w),
                    Text(
                      'State Wise College List',
                      style: GoogleFonts.nunito(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView( // Wrap content in SingleChildScrollView
                    child: Center(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          padding: EdgeInsets.all(20.w),
                          margin: EdgeInsets.symmetric(vertical: 20.h),
                          // Add margin for better spacing
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                HexColor('#5e19a1'),
                                Colors.purple.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Enter Your Rank',
                                style: GoogleFonts.nunito(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Provide your Rank to find eligible colleges',
                                style: GoogleFonts.nunito(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20.h),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18.r,
                                              backgroundColor: HexColor(
                                                  '#124559'),
                                              child: Text(
                                                "1",
                                                style: GoogleFonts.nunito(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 60.w,
                                              height: 2,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          'Rank',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18.r,
                                              backgroundColor: Colors.white,
                                              child: Text(
                                                "2",
                                                style: GoogleFonts.nunito(
                                                  color: HexColor('#0D3C61'),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 60.w,
                                              height: 2,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          'Colleges',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18.r,
                                              backgroundColor: Colors.white,
                                              child: Text(
                                                "3",
                                                style: GoogleFonts.nunito(
                                                  color: HexColor('#0D3C61'),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          'Details',
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),

                                      ],
                                    ),

                                  ],
                                ),
                              ),

                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select State',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedState,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    hintText: 'Select State',
                                    hintStyle: GoogleFonts.nunito(
                                      color: Colors.grey.shade600,
                                      fontSize: 16.sp,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.h),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: widget.state.map((state) {
                                    return DropdownMenuItem<String>(
                                      value: state,
                                      child: Text(
                                        state,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedState = newValue;
                                    });
                                  },
                                ),
                              ),
                              // SizedBox(height: 16.h),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _selectedOption == 0,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedOption = 0;
                                                    marksController.clear();
                                                    rankController.clear();
                                                  } else {
                                                    // _selectedOption = 1; // Switch to Marks if All India Rank is deselected
                                                  }
                                                });
                                              },
                                              activeColor: Colors.blue,
                                            ),
                                            Text(
                                              'All India Rank',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _selectedOption == 1,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedOption = 1;
                                                    marksController.clear();
                                                    rankController.clear();// Select Marks
                                                  } else {
                                                    // _selectedOption = 0; // Switch to All India Rank if Marks is deselected
                                                  }
                                                });
                                              },
                                              activeColor: Colors.blue,
                                            ),
                                            Text(
                                              'Marks',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),                                    // All India Rank
                                    if (_selectedOption == 0)
                                      Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Your All India Rank:',
                                              style: GoogleFonts.nunito(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextFormField(
                                              keyboardType: TextInputType.number,
                                              controller: rankController,
                                              decoration: InputDecoration(
                                                hintText: 'Enter your Rank here',
                                                hintStyle: GoogleFonts.nunito(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 16.sp,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                                              ),
                                              style: GoogleFonts.nunito(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                        ],
                                      ),
                                    // Marks
                                    if (_selectedOption == 1)
                                      Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Your Marks:',
                                              style: GoogleFonts.nunito(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextFormField(
                                              keyboardType: TextInputType.number,
                                              controller: marksController,
                                              decoration: InputDecoration(
                                                hintText: 'Enter your Marks here',
                                                hintStyle: GoogleFonts.nunito(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 16.sp,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                                              ),
                                              style: GoogleFonts.nunito(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  Checkbox(
                                    value: _isAgreed,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAgreed = value ?? false;
                                      });
                                    },
                                    activeColor: HexColor('#00696f'),
                                    side: BorderSide(
                                        color: Colors.grey.shade100, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'I agree to the terms and conditions',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.h),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF124559),
                                      Color(0xFF01949A)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: _findColleges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    minimumSize: Size(double.infinity, 40.h),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 25.sp,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        'Find Eligible Colleges',
                                        style: GoogleFonts.nunito(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // Add padding at the bottom to avoid cutoff
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
        ],
      ),
    );
  }
}
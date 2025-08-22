import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HexColorCode/HexColor.dart';

import 'all_india_rank_list_screen.dart';

class AllIndiaRankScreen extends StatefulWidget {
  final List<dynamic> type;

  const AllIndiaRankScreen({super.key, required this.type});

  @override
  State<AllIndiaRankScreen> createState() => _AllIndiaRankScreenState();
}

class _AllIndiaRankScreenState extends State<AllIndiaRankScreen> {
  final TextEditingController rankController = TextEditingController();

  bool _isAgreed = true; // "I agree" selected by default
  String? _selectedQuota;
  final int currentStep = 1; // Change this to 2 or 3 to highlight other steps
  String? selectedState;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: HexColor('#f2f5ff'),
          height: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 1,
                child: Opacity(
                  // opacity: 0.3,
                  opacity: 1,
                  // set value between 0.0 (fully transparent) and 1.0 (fully opaque)
                  child: Image.asset(
                    'assets/toolbg.jpeg',
                    // 'assets/tools_bg.jpg',

                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25.sp, right: 25.sp),
                child: Column(
                  children: [
                    SizedBox(height: 50.sp),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40.sp,
                            width: 40.sp,
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
                        SizedBox(width: 10.sp),
                        Text(
                          'All India College List',
                          style: GoogleFonts.nunito(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15.sp, right: 15.sp, top: 15.sp),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                decoration: BoxDecoration(
                                  // color: HexColor('#A85eab'),
                                  borderRadius: BorderRadius.circular(25),
                                  // gradient: LinearGradient(
                                  //   colors: [
                                  //     Colors.white,
                                  //   HexColor('#A85eab'),
                                  //
                                  //   ],
                                  //   begin: Alignment.topCenter,
                                  //   end: Alignment.bottomCenter,
                                  // ),
                                  image: DecorationImage(
                                    image: AssetImage('assets/allbgimg.png',),
                                    // image: NetworkImage('https://png.pngtree.com/thumb_back/fh260/background/20190223/ourmid/pngtree-solid-color-matte-background-blue-gradient-wind-background-color-mattesolid-backgroundblue-image_84871.jpg'),
                                    // replace with your image path
                                    fit: BoxFit.cover,

                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.01),
                                      // set opacity here
                                      BlendMode.darken,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.sp),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 0),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Enter Your Rank',
                                            style: GoogleFonts.notoSans(
                                              fontSize: 25.sp,
                                              fontWeight: FontWeight.bold,
                                              // color: HexColor('#00696f'),
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Center(
                                            child: Text(
                                              'Provide your rank to find eligible colleges',
                                              style: GoogleFonts.nunito(
                                                fontSize: 19.sp,
                                                fontWeight: FontWeight.w500,
                                                // color: HexColor('#7b809a'),
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                           SizedBox(height: 20.sp),

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
                                                          radius: 18,
                                                          backgroundColor:
                                                              HexColor('#124559'),
                                                          child: Text(
                                                            "1",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,

                                                            ),
                                                          ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          // side: BorderSide(
                                                          //   color: Colors.white,
                                                          //   width: 2,
                                                          // ),
                                                        ),
                                                        Container(
                                                          width: 60.sp,
                                                          height: 2,
                                                          color: Colors.white,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      ' Rank',
                                                      style: const TextStyle(
                                                          color: Colors.white),
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
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Text(
                                                            "2",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF0D3C61),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          // side: BorderSide(
                                                          //   color: Colors.white,
                                                          //   width: 2,
                                                          // ),
                                                        ),
                                                        Container(
                                                          width: 60.sp,
                                                          height: 2,
                                                          color: Colors.white,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Colleges         ',
                                                      style: const TextStyle(
                                                          color: Colors.white),
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
                                                          radius: 18,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Text(
                                                            "3",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF0D3C61),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          // side: BorderSide(
                                                          //   color: Colors.white,
                                                          //   width: 2,
                                                          // ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Details',
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),

                                              ],
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

                                          SizedBox(height: 0.h),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Select Course',
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
                                                hintText: 'Select Course',
                                                hintStyle: GoogleFonts.nunito(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 16.sp,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(
                                                    vertical: 10.h),
                                              ),
                                              icon: const Icon(Icons.arrow_drop_down),
                                              items: widget.type.map((state) {
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
                                          SizedBox(height: 12.h),


                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 8.sp),
                                            child: Text(
                                              'Your All India Rank:',
                                              style: GoogleFonts.nunito(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),

                                            ),
                                          ),
                                          SizedBox(height: 8.sp),
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

                                          SizedBox(height: 8.sp),
                                          Container(
                                              height: 20.sp,
                                              child: Row(
                                                // mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Checkbox(
                                                    value: _isAgreed,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _isAgreed =
                                                            value ?? false;
                                                      });
                                                    },
                                                    activeColor:
                                                        HexColor('#00696f'),
                                                    side: BorderSide(
                                                        color: Colors
                                                            .grey.shade100,
                                                        width: 2),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4)),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  SizedBox(width: 8),
                                                  // checkbox aur text ke beech thoda gap
                                                  Text(
                                                    'I agree to the terms and conditions',
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 16.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(height: 20.sp),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ElevatedButton(
                                              onPressed:  () {

                                                if(rankController.text.isEmpty){
                                                  Fluttertoast.showToast(
                                                      msg: "Please Enter Your Rank",
                                                      toastLength: Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.red,
                                                      textColor: Colors.white,
                                                      fontSize: 14.sp
                                                  );


                                                }else{
                                                  FocusScope.of(context).unfocus();  // ye line add ki

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return AllIndiaCollegeListScreen(rank: rankController.text.toString(), type: selectedState!,);
                                                      },
                                                    ),
                                                  );
                                                }

                                                    },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                // disabledBackgroundColor: Colors.grey.shade300,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                minimumSize: const Size(
                                                    double.infinity, 50),
                                                elevation: 0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                    size: 25.sp,
                                                  ),
                                                  SizedBox(
                                                    width: 5.sp,
                                                  ),
                                                  Text(
                                                    ' Find Eligible Colleges',
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5.sp),

                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

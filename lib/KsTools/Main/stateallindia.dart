import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../baseurl/baseurl.dart';
import '../AllIndia/all_india_rank.dart';
import '../StateWise/state_wise.dart';

class PredictionOptionsScreen extends StatefulWidget {
  const PredictionOptionsScreen({super.key});

  @override
  State<PredictionOptionsScreen> createState() => _PredictionOptionsScreenState();
}

class _PredictionOptionsScreenState extends State<PredictionOptionsScreen> {
  bool _isAgreed = true; // "I agree" selected by default
  String? _selectedQuota;

  List<dynamic> stateList=[];
  List<dynamic> type=[];

  
  
  @override
  void initState() {
    super.initState();
    getStates();
  }
  
  Future<void>  getStates() async {
    final prefs=await SharedPreferences.getInstance();
    final token=prefs.getString('token');
    print(token);
    var response =await http.get(Uri.parse(counselingToolStates),
      headers: {
      'Content-Type':'application/json', 
        'Authorization':'Bearer$token'
      },
      // body: jsonEncode(
      //   {}
      // )
    );
    
    if(response.statusCode==200){
      final Map<String,dynamic> responseData=json.decode(response.body);
      if(responseData.containsKey('state')){
        setState(() {
          stateList=responseData['state'];
          type=responseData['courses'];
          print('All State : $stateList');
        });
      }else{
        throw Exception('Missing Key');
      }
    }else{
      print('Failed: ${response.statusCode}');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: [

          Container(
            color: HexColor('#f2f5ff'),
            height: double.infinity,
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1,
                  child: Opacity(
                    opacity: 0.3, // set value between 0.0 (fully transparent) and 1.0 (fully opaque)
                    child: Image.asset(
                      'assets/toolbg.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(left: 25.sp,right: 25.sp),
                  child: Column(
                    children: [
                      SizedBox(height:50.sp),

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
                          SizedBox(width:10.sp),

                          Text(
                            'Prediction Options',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
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
                                padding:  EdgeInsets.only(left: 25.sp,right: 25.sp,top: 15.sp),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(25),
                                    image: DecorationImage(
                                      image: const NetworkImage('https://i.pinimg.com/736x/c6/f4/c9/c6f4c9ea1548e66f89eec6ccb4c2569d.jpg'), // replace with your image path
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.01), // set opacity here
                                        BlendMode.darken,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Select Your Preferences',
                                          style: GoogleFonts.nunito(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            // color: HexColor('#00696f'),
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                          child: Text(
                                            'Enter your exam details to get college predictions',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              // color: HexColor('#7b809a'),
                                              color: Colors.white,

                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 2.sp),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.7,
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: HexColor('#00696f'),
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.1),
                                                          spreadRadius: 2,
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'ⓘ Note: Predictions are based on past data and are for guidance only. Actual results may vary.',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: 13.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8), // spacing between note and "View Video"

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),


                                        Padding(
                                          padding:  EdgeInsets.only(left: 0.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child:  Row(
                                              children: [
                                                Theme(
                                                  data: Theme.of(context).copyWith(
                                                    unselectedWidgetColor: Colors.grey.shade100,  // your custom inactive color here
                                                  ),
                                                  child: Checkbox(
                                                    value: _isAgreed,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _isAgreed = value ?? false;
                                                      });
                                                    },
                                                    activeColor: HexColor('#00696f'),
                                                  ),
                                                ),

                                                Expanded(
                                                  child: Text(
                                                    'I agree to the terms and conditions',
                                                    style: GoogleFonts.nunito(
                                                      fontSize: 16.sp,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ),
                                        ),

                                        const SizedBox(height: 20),


                                        Padding(
                                          padding:  EdgeInsets.only(left: 0.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child:  RadioListTile<String>(
                                              value: 'State Quota',
                                              groupValue: _selectedQuota,
                                              onChanged: _isAgreed
                                                  ? (value) {
                                                setState(() {
                                                  _selectedQuota = value;
                                                });
                                              }
                                                  : null,
                                              title: Text(
                                                'State Quota',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16.sp,
                                                  color: _isAgreed ? Colors.black87 : Colors.grey,
                                                ),
                                              ),
                                              activeColor:  HexColor('#00696f'),
                                            ),


                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        Padding(
                                          padding:  EdgeInsets.only(left: 0.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child:    RadioListTile<String>(
                                              value: 'All India Quota',
                                              groupValue: _selectedQuota,
                                              onChanged: _isAgreed
                                                  ? (value) {
                                                setState(() {
                                                  _selectedQuota = value;
                                                });
                                              }
                                                  : null,
                                              title: Text(
                                                'All India Quota',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 16.sp,
                                                  color: _isAgreed ? Colors.black87 : Colors.grey,
                                                ),
                                              ),
                                              activeColor:  HexColor('#00696f'),
                                            ),



                                          ),
                                        ),


                                        const SizedBox(height: 30),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF124559), Color(0xFF01949A)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: (_isAgreed && _selectedQuota != null)
                                                ? () {
                                              try {
                                                switch (_selectedQuota) {
                                                  case 'All India Quota':
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return AllIndiaRankScreen(type: type,);
                                                        },
                                                      ),
                                                    );
                                                    break;
                                                  case 'State Quota':
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return StateWiseRankScreen(state: stateList,);
                                                        },
                                                      ),
                                                    );
                                                    break;
                                                  default:
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Invalid quota selected.',
                                                          style: GoogleFonts.nunito(),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                }

                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: $e',
                                                      style: GoogleFonts.nunito(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                                : () {

                                              Fluttertoast.showToast(
                                                  msg:  _isAgreed
                                                      ? 'Please select a quota.'
                                                      : 'Please agree to the terms and conditions.',
                                                  toastLength: Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );

                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              minimumSize: const Size(double.infinity, 50),
                                              elevation: 0,
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Next',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 5.sp),
                                                Icon(
                                                  Icons.keyboard_double_arrow_right,
                                                  color: Colors.white,
                                                  size: 25.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
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
      )
    );
  }
}

import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../Utils/app_colors.dart';
import '../Counselor/counselor_payment.dart';

class StateBestCollegesScreen extends StatefulWidget {
  final String rank;
  final String score;
  final String state;

  const StateBestCollegesScreen({super.key, required this.rank, required this.score, required this.state,});

  @override
  State<StateBestCollegesScreen> createState() => _BestCollegesScreenState();
}

class _BestCollegesScreenState extends State<StateBestCollegesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _fatherNameController = TextEditingController();


  bool isLoading = false;
  List<dynamic> bestColleges = [];

  final List<IconData> icons = [
    Icons.school,
    Icons.local_hospital,
    Icons.local_hospital,
    Icons.school,
    Icons.nightlight_round,
    Icons.school,
  ];
  final List<Color> color = [
    Colors.blue,
    Colors.purple,
    Colors.redAccent,
    Colors.green,
    Colors.black,
    Colors.yellow,
    Colors.pink,
  ];
  final List<Color> color2 = [
    Colors.teal.shade200,
    Colors.purple.shade200,
    Colors.redAccent.shade200,
    Colors.green.shade200,
    Colors.yellow.shade200,
    Colors.pink.shade200,
  ];

  @override
  void initState() {
    super.initState();
    collegeList(widget.rank,widget.score,widget.state, '', '', '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  Future<void> collegeList(String rank,String score,String state, String course, String category, String quota) async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    // Construct the URL with query parameters for course, category, and quota


    var url = Uri.parse(counselingToolStatesTopTen);

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rank': rank,
        'score': score,
        'state': state,

      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('college')) {
        setState(() {
          bestColleges = responseData['college'];
          isLoading = false;


        });
      } else {
        throw Exception('Invalid API response: Missing "college" key');
      }
    } else {
      print('Failed: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeInOut,
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side:  BorderSide(color: HexColor('#5e19a1'), width: 2),
            ),
            title:  Text(
              'Connect With Your Counselor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HexColor('#5e19a1'),
                fontSize: 20,
              ),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: HexColor('#5e19a1'),
                          size: 24,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: HexColor('#5e19a1'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: HexColor('#5e19a1'),
                          size: 24,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your 10-digit contact number',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: HexColor('#5e19a1'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your contact number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                          return 'Please enter a valid 10-digit number';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    TextFormField(
                      controller: _fatherNameController,
                      decoration: InputDecoration(
                        labelText: 'Father\'s Name',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: HexColor('#5e19a1'),
                          size: 24,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: HexColor('#5e19a1'), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your father\'s full name',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: HexColor('#5e19a1'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your father\'s name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
            ),
            actions: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 00.sp),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 40.sp,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  HexColor('#5e19a1'),
                                  Colors.redAccent.shade200
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
                                'Cancel',
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
                    ),
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),




// Your existing widget code
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0.sp),
                        child: GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // Prepare the message with form data
                              String name = _nameController.text;
                              String contact = _contactController.text;
                              String fatherName = _fatherNameController.text;
                              String message = "Name: $name\nContact: $contact\nFather's Name: $fatherName";

                              // WhatsApp phone number (replace with the target number, including country code)
                              String phoneNumber = "+916397199758"; // Example: +91 for India, followed by the number

                              // Construct WhatsApp URL
                              String whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

                              // Launch WhatsApp
                              if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                                await launchUrl(Uri.parse(whatsappUrl));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open WhatsApp'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              // Show success snackbar
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Submitted: $name!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Undo logic can be added here
                                    },
                                  ),
                                ),
                              );

                              // Clear form fields
                              _nameController.clear();
                              _contactController.clear();
                              _fatherNameController.clear();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 40.sp,
                            width: MediaQuery.of(context).size.width * 0.3,
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
                                'Submit',
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
                    ),
                  ),
                ],
              )



            ],
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
            Container(
              color: HexColor('#f2f5ff'),
              height: double.infinity,
              child: Opacity(
                // opacity: 0.3,
                opacity: 1,
                child: Image.asset(
                  // 'assets/toolbg.jpeg',
                  'assets/tools_bg.jpg',

                  fit: BoxFit.cover,
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
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
                    'Best Colleges ',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  actions:  [
                    // GestureDetector(
                    //   onTap: (){
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const VideoPlayerScreen(),
                    //       ),
                    //     );
                    //   },
                    //
                    //     child: Icon(CupertinoIcons.play_circle))
                  ],
                  pinned: true,
                  floating: false,
                  snap: false,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      isLoading
                          ? PrimaryCircularProgressWidget()
                          : ListView.builder(
                        itemCount: bestColleges.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          var college = bestColleges[index];

                          int iconIndex = index % icons.length;
                          int colorIndex = index % color.length;
                          int colorIndex2 = index % color2.length;
                          return  GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CounselorPaymentPage(),
                                ),
                              );
                            },

                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                // border: Border(
                                //   left: BorderSide(color: color[colorIndex], width: 4),
                                //   right: BorderSide(color: color[colorIndex], width: 4),
                                // ),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.05),
                                //     blurRadius: 8,
                                //     offset: Offset(0, 4),
                                //   ),
                                // ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                leading: Container(
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                    color: color[colorIndex].withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    icons[iconIndex],
                                    color: color[colorIndex],
                                    size: 28,
                                  ),
                                ),
                                title: Text(
                                  college["college_name"] ?? 'Unknown Institute',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,

                                  ),
                                ),
                                subtitle:Text(
                                  '${college["course"] ?? "Unknown Course"}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,

                                  ),
                                ),
                              ),
                            ),
                          );




                        },
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








  Widget collegeCard({
    required String title,
    required String location,
    required String seats,
    required String established,
    required String rating,
    required String course,
    required String fees,
    required String cutoff,
    required String admissionRound,
    required String tag,
    required Color tagColor,
    required Color tagBackground,
    required LinearGradient cardGradient,
    required Color applyButtonColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 100.sp,
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                ),
                // Container(
                //   padding:
                //   const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: tagBackground,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Row(
                //     children: [
                //       const Icon(Icons.star, color: Colors.white, size: 14),
                //       const SizedBox(width: 4),
                //       Text(
                //         tag,
                //         style: TextStyle(color: tagColor, fontSize: 12),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    detailItem('Seats', seats),
                    detailItem('Established', established),
                    detailItem('Rating', rating),
                  ],
                ),
                const Divider(height: 24),
                detailRow('Course', course),
                detailRow('Fees', fees),
                detailRow('Cutoff Score', cutoff),
                detailRow('Admission Round', admissionRound),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'High Chance',
                      style: TextStyle(color: Colors.green),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: applyButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Apply Now'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget detailItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
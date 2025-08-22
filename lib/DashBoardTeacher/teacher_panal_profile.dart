import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../baseurl/baseurl.dart';

class ProfileTeacherScreen extends StatefulWidget {
  const ProfileTeacherScreen({super.key});

  @override
  State<ProfileTeacherScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<ProfileTeacherScreen> {
  bool _isLoading = false;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String experience = '';
  String qualification = '';
  String language = '';
  String subjectSpecialization = '';
  String avg_rating = '';
  String happy_student = '';
  String Reviews = '';

  @override
  void initState() {
    super.initState();
    fetchTeacherProfileData();
  }

  Future<void> fetchTeacherProfileData() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final Uri uri = Uri.parse(teacherProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() => _isLoading = false);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        nickname = jsonData['data']['name'] ?? '';
        userEmail = jsonData['data']['email'] ?? '';
        contact = jsonData['data']['contact'] ?? '';
        address = jsonData['data']['address'] ?? '';
        bio = jsonData['data']['bio'] ?? '';
        photoUrl = jsonData['data']['picture_data'] ?? '';
        qualification = jsonData['data']['qualification'] ?? '';
        experience = jsonData['data']['experience'] ?? '';
        language = jsonData['data']['language'] ?? '';
        subjectSpecialization = jsonData['data']['subject_special'] ?? '';
        happy_student = jsonData['data']['happy_student'].toString() ?? '';
        avg_rating = jsonData['data']['avg_rating'].toString() ?? '';
        Reviews = jsonData['data']['review_Count'].toString() ?? '';

      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),

            _buildInfoSection("Contact", contact, Icons.phone),
            _buildInfoSection("Address", address, Icons.location_on),
            _buildInfoSection("Subject", subjectSpecialization, Icons.book),
            _buildInfoSection("Languages", language, Icons.language),
            SizedBox(height: 10,),
            // _buildWalletBalance(),
            _buildStatRow(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: '$photoUrl',
                width: MediaQuery.of(context).size.width*0.2,
                height: MediaQuery.of(context).size.height*0.1,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey,
                  // Placeholder color
                  // You can customize the default image as needed
                  child: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                )
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: GoogleFonts.poppins(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey),
                    ),
                    Text(
                      qualification,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8), // Space between text and buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle edit profile action
                          },
                          icon: Icon(Icons.edit, size: 12.sp),
                          label: Text("Edit Profile",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.03),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle wallet action
                          },
                          icon: Icon(Icons.account_balance_wallet, size: 12.sp),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Wallet",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.03)),
                              SizedBox(width: 8), // Space between text and price
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee, size: 12.sp),
                                  Text("100.00", style: TextStyle(fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.width*0.03)),
                                ],
                              ), // Price
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("$experience Years", "Experience", Icons.work_history_outlined),
        _buildStatItem("$happy_student", "Happy Students", Icons.emoji_emotions),
        _buildStatItem("$avg_rating", "Rating", Icons.star),
        _buildStatItem("$Reviews", "Reviews", Icons.reviews),

      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 20.sp),
        SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.03, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        Text(label, style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.03, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Card(
        elevation: 3,
        child: ListTile(
          leading: Icon(icon, color: Colors.blueGrey),
          title: Text(title, style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.035, fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.03, color: Colors.blueGrey)),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About Me", style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.035, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(bio, style: GoogleFonts.poppins(fontSize:  MediaQuery.of(context).size.width*0.03, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}

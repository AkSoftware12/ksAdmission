import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:realestate/Utils/app_colors.dart';
import '../../baseurl/baseurl.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import 'ReviewList/review_list.dart';

class TeacherProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const TeacherProfileScreen({super.key, required this.data});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  List<dynamic> reviewlist = [];

  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hitReviewList(widget.data['id']);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ---------------- API (Same) ----------------
  Future<void> hitReviewList(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$reviewList$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('reviews')) {
        setState(() {
          reviewlist = responseData['reviews'];
        });
      } else {
        throw Exception('Invalid API response: Missing "reviews" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> hitReviewApi(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) throw Exception("Authorization token is missing.");

      final response = await http.post(
        Uri.parse(reviewPost),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "teacher_id": widget.data['id'],
          "review": _reviewController.text,
          "rating": _rating,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint("Review successful: $responseData");

        Fluttertoast.showToast(
          msg: "Review successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        _reviewController.clear();
        setState(() => _rating = 0.0);

        // optional: refresh list after submit (UI same, helpful)
        hitReviewList(widget.data['id']);
      } else {
        throw Exception('Failed to post review: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ---------------- UI Helpers ----------------
  TextStyle _titleStyle(Color c) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: c,
  );

  TextStyle _subStyle(Color c) => GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: c,
  );

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: homepageColor.withOpacity(0.12),
          ),
          child: Icon(icon, size: 18, color: homepageColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Color(0xFF010071),
              Color(0xFF0A1AFF),
              // homepageColor.withOpacity(0.95),
              // primaryColor.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: homepageColor.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.9)),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final name = (widget.data['name'] ?? 'N/A').toString();
    final subject = (widget.data['subject_special'] ?? 'N/A').toString();
    final language = (widget.data['language'] ?? 'N/A').toString();
    final qualification = (widget.data['qualification'] ?? 'N/A').toString();
    final bio = (widget.data['bio'] ?? 'N/A').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF010071),
                Color(0xFF0A1AFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){
                Navigator.of(context).pop();

              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'View teacher details & reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationList()),
                );
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Premium AppBar + Image
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              automaticallyImplyLeading: false,
              // title: Text(
              //   "Profile",
              //   style: GoogleFonts.poppins(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w800,
              //     color: Colors.white,
              //   ),
              // ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.data['picture_data'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/teacher_user.jpg',
                            fit: BoxFit.cover);
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [

                            Colors.black.withOpacity(0.10),
                            HexColor('#010071'),

                            // Colors.black.withOpacity(0.75),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // Bottom Glass Info
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            // color: Colors.white.withOpacity(0.12),
                            color:  HexColor('#010071'),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.18)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.18),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.25)),
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _miniChip(subject),
                                        _miniChip(language),
                                      ],
                                    ),
                                  ],
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

            // Body Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Qualification Card
                    _card(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: homepageColor.withOpacity(0.10),
                            ),
                            child: Icon(Icons.school_rounded,
                                color: homepageColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              qualification,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.work_history_outlined,
                            title: "Experience",
                            value: "${widget.data['experience']}/Year",
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _statCard(
                            icon: Icons.emoji_emotions_outlined,
                            title: "Happy Student",
                            value: "${widget.data['happy_student']}",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.star_rounded,
                            title: "Rating",
                            value: "${widget.data['avg_rating']}",
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _statCard(
                            icon: Icons.reviews_rounded,
                            title: "Reviews",
                            value: "${widget.data['review_Count']}",
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (_) => Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  child: UserProfileBottomSheet(
                                    reviewList: reviewlist,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // About
                    _sectionHeader("About Me",
                        icon: Icons.info_outline_rounded),
                    const SizedBox(height: 10),
                    _card(
                      child: Text(
                        bio,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Rate & Review
                    _sectionHeader("Rate and Review",
                        icon: Icons.rate_review_outlined),
                    const SizedBox(height: 10),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your rating",
                              style:
                              _titleStyle(Colors.blueGrey.shade900)),
                          const SizedBox(height: 10),
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              setState(() => _rating = rating);
                            },
                          ),
                          const SizedBox(height: 14),
                          Text("Write a review",
                              style: _subStyle(Colors.blueGrey.shade700)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: "Type your review here...",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey.shade300,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF6F8FC),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_rating <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please provide a rating before submitting.'),
                                    ),
                                  );
                                  return;
                                }
                                hitReviewApi(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0A1AFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Submit Rating",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

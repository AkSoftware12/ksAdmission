import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../baseurl/baseurl.dart';
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

  void _submitRating() {
    if (_rating > 0) {

      hitReviewApi(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating Submitted: $_rating \nReview: ${_reviewController.text}')),
      );
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating before submitting.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    hitReviewList(widget.data['id']);
  }
  Future<void> hitReviewList(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse('$reviewList$id'),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('reviews')) {
        setState(() {
          reviewlist = responseData['reviews'];
          print('List :-  $reviewlist');
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
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
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        },
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Authorization token is missing.");
      }

      final response = await http.post(
        Uri.parse(reviewPost),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "teacher_id": widget.data['id'],
          "review": _reviewController.text, // Use 24-hour format
          "rating":_rating // Use 24-hour format
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Navigator.pop(context);
        print("Review successful: $responseData");
        Fluttertoast.showToast(
          msg: "Review successful!",
          toastLength: Toast.LENGTH_SHORT,  // or Toast.LENGTH_LONG
          gravity: ToastGravity.BOTTOM,  // TOP, CENTER, BOTTOM
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        _reviewController.clear();
        setState(() {
          _rating = 0.0;
        });
      } else {
        throw Exception('Failed to book slot: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error booking slot: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.green.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(59),
        child: Column(
          children: [
            AppBar(
              elevation: 4,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Profile",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              flexibleSpace: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [homepageColor,primaryColor],
                    begin: Alignment.topCenter,  // Horizontal gradient starts from left
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              actions: [
                // Container(
                //   margin: EdgeInsets.only(right: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.2),
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: Icon(Icons.search, color: Colors.white),
                //     onPressed: () {
                //       // Future search functionality
                //     },
                //   ),
                // ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
            ),
            Container(
              height: 0,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, homepageColor],
                ),
              ),
            ),
          ],
        ),
      ),

      body:SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child:                     ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.network(
                    widget.data['picture_data'].toString(),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/teacher_user.jpg', // Ensure this image exists in your assets folder
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.data['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.data['subject_special']??'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,

                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    widget.data['language']??'N/A',

                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,

                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    widget.data['qualification']??'N/A',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),






            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("${widget.data['experience']}/Year", "Experience", Icons.work_history_outlined),
                _buildStatItem("${widget.data['happy_student']}", "Happy Student", Icons.emoji_emotions),
                _buildStatItem("${widget.data['avg_rating']}", "Rating", Icons.star),
                _buildStatItem("${widget.data['review_Count']}", "Reviews", Icons.reviews),
              ],
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "About Me",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.data['bio']??'N/A',
                textAlign: TextAlign.start,

                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Rate and Review",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child:  ElevatedButton(
                      onPressed: (){
                        hitReviewApi(context);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: homepageColor, // Added button color
                      ),
                      child: Text("Submit Rating", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.black), // Use the passed icon here
            onPressed: () {
              if(label=='Reviews') {
                showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => UserProfileBottomSheet(reviewList: reviewlist,
                ),
              );
              }
              // Future search functionality
            },
          ),
        ),

        SizedBox(height: 10,),

        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,

            color: Colors.blueGrey,
          ),

        ),
      ],
    );
  }
}


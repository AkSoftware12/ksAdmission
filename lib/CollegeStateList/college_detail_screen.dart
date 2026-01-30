import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/textSize.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HomePage/home_page.dart';

class CollegeDetailScreen extends StatelessWidget {
  final String state;
  final Map<String, dynamic> data;

  const CollegeDetailScreen({super.key, required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Universities Detail'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Everything you need to choose the right university",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )


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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0), // Rounded corners
              child: CachedNetworkImage(
                imageUrl: data["picture_urls"].toString(),
                height: 150.sp,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: PrimaryCircularProgressWidget()),
                // Loading indicator
                errorWidget: (context, url, error) => SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/no_image.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    data["university_name"].toString(),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "State:  $state ${'/'} ${data["country"].toString()}"),
                      Text(
                          "Univ Grade: ${data["university_grade"].toString().toUpperCase() }"),

                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("University Type: ${data["university_type"] == 1 ? 'Government' : data["university_type"] == 2 ? 'Private' : 'N/A'}"),

                      Text(
                          "Estd. Year: ${data["established_year"] ?? 'N/A'}"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Specialization: ${'Research'}"),

                      Text("NIRF Rank: ${data["nirfRank"] ?? 'N/A'}"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Fees: ${' ₹ ${data["min_fees"] ?? 'N/A'} - ${data["max_fees"] ?? 'N/A'}'}"),
                      Text(
                          "Medium: ${data["medium"].toString().toUpperCase()}"),
                    ],
                  ),
                  SizedBox(height: 5),



                ],
              ),
            ),

            Card(
              color: Colors.blueGrey.shade50,
              child: ExpansionTile(
                title: Text(
                  'University About'.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down),
                initiallyExpanded: true,
                children: [
                  Container(
                    width: double.infinity,

                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Text(
                          data['university_about'],
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: TextSizes.textsmall,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ], // Keeps it open by default


              ),
            ),

            Card(
              color: Colors.blueGrey.shade50,
              child: ExpansionTile(
                title: Text(
                  'Hostel'.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down),
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Text(
                          data['hostel_facilities'],
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: TextSizes.textsmall,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ], // Arrow icon
              ),
            ),
            Card(
              color: Colors.blueGrey.shade50,
              child: ExpansionTile(
                title: Text(
                  'about campus life'.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down),
                children: [
                  Container(
                    width: double.infinity,

                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Text(
                          data['about_campus_life'],
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: TextSizes.textsmall,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ], // Arrow icon
              ),
            ),

            Card(
              color: Colors.white,
              child: ExpansionTile(
                title: Text(
                  'course'.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                    child: data['course'] != null && data['course'].isNotEmpty
                        ? ListView.builder(
                      itemCount: data['course'].length,
                      // physics: NeverScrollableScrollPhysics(), // Uncomment if you want to disable scrolling
                      itemBuilder: (context, index) {
                        final course = data['course'][index];
                        return Card(
                          color: Colors.white,
                          child: ExpansionTile(
                            title: Text(
                              course['course_name']!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_drop_down),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Course Fees: ${course['fees'].toString()}"),
                                        Text("Course Duration: ${course['duration']}"),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Available Intake: ${course['available_intake'].toString()}"),
                                        Text("Program: ${course['program_type']}"),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Medium of Course: ${course['medium'].toString()}"),
                                        Text("Degree Awarded: ${course['course_name']}"),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: homepageColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Course Eligibility",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              course['eligibility'].toString(),
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ], // Arrow icon
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Text(
                        "No courses available.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )

                ], // Arrow icon
              ),
            ),
          ],
        ),
      ),
    );
  }
}

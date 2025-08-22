import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../HomeScreen/Year/SubjectScreen/webView.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/textSize.dart';
import 'doubt_full_image.dart';

class DoubtDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DoubtDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Doubt Detail',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: TextSizes.textmedium,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.sp), // No rounded corners
            ),
            color: primaryColor,
            child: Column(
              children: [
                Container(
                  height: 30.sp,
                  color: primaryColor,
                  child: Padding(
                    padding: EdgeInsets.all(5.sp),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Doubt  : ',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: TextSizes.textmedium,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor2,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${data['category']['name']}${'/'}${data['subject']['name']}',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: TextSizes.textmedium,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white, // Second color
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
                Padding(
                  padding: EdgeInsets.all(0.sp),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.sp),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoubtFullImage(
                                image:  data['picture_urls'].toString(),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                            height: 150.sp,
                            width: double.infinity,
                            child: Image.network(
                              data['picture_urls'].toString(),
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/no_image.jpg', // Path to your default image in the assets
                                  fit: BoxFit.fill,
                                );
                              },
                            )

                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Doubt Message : ',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: TextSizes.textmedium,
                              fontWeight: FontWeight.normal,
                              color: primaryColor2,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: '${data['message']}',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: TextSizes.textmedium,
                              fontWeight: FontWeight.normal,
                              color: Colors.white, // Second color
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30.sp,
            color: primaryColor2,
            child: Padding(
              padding: EdgeInsets.all(5.sp),
              child: Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Doubt Solved ',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: TextSizes.textmedium,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
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
          Expanded(
            child: ListView.builder(
              itemCount: data['doubtreply']?.length ?? 0, // Safely get length
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Reply : ',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: TextSizes.textmedium,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: TextSizes.textmedium,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange, // Second color
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: '   ',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: TextSizes.textmedium,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.orange, // Second color
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: data['doubtreply']![index]['reply_date']
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: TextSizes.textmedium,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.orange, // Second color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              if (data['doubtreply'] != null &&
                                  data['doubtreply']![index]['picture_urls'] != null &&
                                  data['doubtreply']![index]['picture_urls'].isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerPage(
                                      url: data['doubtreply']![index]['picture_urls'][0].toString(),
                                      title: '',
                                      category: '',
                                      Subject: '',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No PDF available for viewing.')),
                                );
                              }
                            },
                            child: Card(
                              elevation: 5,
                              color: primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(5.sp),
                                child: Text(
                                  'View Pdf',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.all(0.sp),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: SizedBox(
                                height: 150.sp,
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    if (data['doubtreply'] != null &&
                                      data['doubtreply']!.isNotEmpty &&
                                      data['doubtreply']![index]['picture_urls'] != null &&
                                      data['doubtreply']![index]['picture_urls'].isNotEmpty &&
                                      index < data['doubtreply']![index]['picture_urls'].length) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DoubtFullImage(
                                          image: data['doubtreply']![index]['picture_urls'][index].toString(),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Handle the error, e.g., show a message to the user
                                    print("Data is not valid or index is out of bounds.");
                                  }

                                  },
                                  child:Image.network(
                                    data['doubtreply'] != null &&
                                        data['doubtreply']!.isNotEmpty &&
                                        index < data['doubtreply']!.length &&
                                        data['doubtreply']![index]['picture_urls'] != null &&
                                        data['doubtreply']![index]['picture_urls'].isNotEmpty &&
                                        index < data['doubtreply']![index]['picture_urls'].length
                                        ? data['doubtreply']![index]['picture_urls'][index]?.toString() ??
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWz9tftw9qculFH1gxieWkxL6rbRk_hrXTSg&s'
                                        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWz9tftw9qculFH1gxieWkxL6rbRk_hrXTSg&s',
                                    fit: BoxFit.fill,
                                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                      return Image.asset('assets/no_image.jpg', fit: BoxFit.fill);
                                    },
                                  )

                                )))),
                    Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Doubt Solve Message : ',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: TextSizes.textmedium,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: data['doubtreply']?[index]['doubt_reply']
                                      ?.toString() ??
                                  "No reply",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: TextSizes.textmedium,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white, // Second color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

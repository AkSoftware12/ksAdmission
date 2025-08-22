import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Utils/app_colors.dart';
import '../../../../Utils/textSize.dart';
import '../webView.dart';

class PdfListAdvance extends StatefulWidget {
  final Map<String, dynamic> data;

  const PdfListAdvance({super.key, required this.data});

  @override
  State<PdfListAdvance> createState() => _PdfListAdvanceState();
}

class _PdfListAdvanceState extends State<PdfListAdvance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.data['name'].toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.data['notes_urls']?.length ?? 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                    url: widget.data['notes_urls']![index]['value'].toString(),
                    title: widget.data['notes_urls']![index]['key'].toString(),
                    category: '',
                    Subject: '',
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: Container(
                    height: 60.sp,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${index + 1} .   ${widget.data['notes_urls']![index]['key'].toString()}',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: TextSizes.textsmall2,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(5.sp),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(10.sp)
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.sp),
                          topLeft: Radius.circular(10.sp),
                          topRight: Radius.circular(5.sp),
                          bottomRight: Radius.circular(5.sp),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1.sp),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.sp, right: 8.sp),
                          child: Text(
                            widget.data['name'].toString(),
                            style: GoogleFonts.radioCanada(
                              textStyle: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

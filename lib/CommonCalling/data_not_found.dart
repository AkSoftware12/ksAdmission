import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DataNotFoundWidget extends StatelessWidget {
  const DataNotFoundWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 450.sp,
        child: Container(
          child: Center(
              child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10.sp),
                  child:
                  Stack(
                    children: [
                      Image.asset('assets/data_not.png'),
                      Center(child: Padding(
                        padding:  EdgeInsets.only(top: 108.sp),
                        child: Text('data not found ',
                          style: GoogleFonts.radioCanada(
                            textStyle: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ))
                    ],
                  ))),
        ),
      ),
    );
  }
}

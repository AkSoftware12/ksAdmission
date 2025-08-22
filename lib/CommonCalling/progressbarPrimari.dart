import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_colors.dart';

class  PrimaryCircularProgressWidget extends StatelessWidget {
  const PrimaryCircularProgressWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ), // Show progress bar here
    );
  }
}

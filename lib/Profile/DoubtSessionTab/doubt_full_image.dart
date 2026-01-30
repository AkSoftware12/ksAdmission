import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../HomePage/home_page.dart';
import '../../Utils/app_colors.dart';

class DoubtFullImage extends StatefulWidget {
  final String image ;
  const DoubtFullImage({super.key, required this.image});

  @override
  State<DoubtFullImage> createState() => _DoubtFullImageState();
}

class _DoubtFullImageState extends State<DoubtFullImage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
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
                  'Full Image ', // ✅ dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'View the doubt image in full clarity',
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

      backgroundColor: Colors.black,
        body:  Center(
          child: InteractiveViewer(
            panEnabled: true, // Allow panning
            minScale: 0.5,    // Minimum zoom scale
            maxScale: 4.0,
            child:Image.network(
              widget.image ?? '',
              fit: BoxFit.fill,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Image.asset('assets/no_image.jpg', fit: BoxFit.fill);
              },
            )

          ),
        ),

    );
  }
}

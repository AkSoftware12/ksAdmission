import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../HomePage/home_page.dart';
import '../../HomeScreen/Year/SubjectScreen/webView.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/textSize.dart';
import 'doubt_full_image.dart';

class DoubtDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DoubtDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryName = (data['category']?['name'] ?? '').toString();
    final subjectName = (data['subject']?['name'] ?? '').toString();
    final doubtTitle = "$categoryName / $subjectName".trim();
    final doubtImage = (data['picture_urls'] ?? '').toString();
    final doubtMsg = (data['message'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                ),
                child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doubt Detail',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Clear your doubts with real-time expert support',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
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

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Doubt main card
            _DoubtMainCard(
              title: doubtTitle.isEmpty ? "Doubt" : doubtTitle,
              imageUrl: doubtImage,
              message: doubtMsg,
              onImageTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoubtFullImage(image: doubtImage),
                  ),
                );
              },
            ),

            SizedBox(height: 8.h),

            // ✅ Section header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0A1AFF).withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 10.w,
                    width: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Doubt Solved Replies",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${data['doubtreply']?.length ?? 0}",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5.h),

            // ✅ Replies list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 18.h),
                itemCount: data['doubtreply']?.length ?? 0,
                itemBuilder: (context, index) {
                  final reply = data['doubtreply']?[index] ?? {};
                  final replyDate = (reply['reply_date'] ?? '').toString();
                  final replyMsg = (reply['doubt_reply'] ?? 'No reply').toString();
                  final pics = reply['picture_urls'];
                  final hasPics = pics != null && pics is List && pics.isNotEmpty;

                  // UI wise: first image show
                  final firstImage = hasPics ? pics[0].toString() : "";

                  return _ReplyCard(
                    index: index + 1,
                    replyDate: replyDate,
                    replyMessage: replyMsg,
                    imageUrl: firstImage,
                    hasImage: hasPics,
                    onPdfTap: () {
                      if (hasPics) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(
                              url: pics[0].toString(),
                              title: '',
                              category: '',
                              Subject: '',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No PDF available for viewing.')),
                        );
                      }
                    },
                    onImageTap: () {
                      if (hasPics) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoubtFullImage(image: pics[0].toString()),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------
/// ✅ Premium Widgets (UI only)
/// ---------------------------

class _DoubtMainCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String message;
  final VoidCallback onImageTap;

  const _DoubtMainCard({
    required this.title,
    required this.imageUrl,
    required this.message,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
          // colors: [Colors.blue, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white.withOpacity(0.20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6.w),
                        Text(
                          "DOUBT",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: GestureDetector(
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 165.h,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/no_image.jpg', fit: BoxFit.cover);
                          },
                        ),
                      ),
                      Positioned(
                        right: 10.w,
                        top: 10.h,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 5.h),

            // Message
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doubt Message",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.90),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      message.isEmpty ? "—" : message,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.92),
                        height: 1.35,
                      ),
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
}

class _ReplyCard extends StatelessWidget {
  final int index;
  final String replyDate;
  final String replyMessage;
  final String imageUrl;
  final bool hasImage;
  final VoidCallback onPdfTap;
  final VoidCallback onImageTap;

  const _ReplyCard({
    required this.index,
    required this.replyDate,
    required this.replyMessage,
    required this.imageUrl,
    required this.hasImage,
    required this.onPdfTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0A1AFF).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.reply_rounded, size: 16, color: Colors.orange),
                        SizedBox(width: 6.w),
                        Text(
                          "Reply $index",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      replyDate.isEmpty ? "—" : replyDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // View PDF button
                  InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: onPdfTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.20),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6.w),
                          Text(
                            "View PDF",
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image (optional)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: GestureDetector(
                onTap: hasImage ? onImageTap : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 165.h,
                        width: double.infinity,
                        child: hasImage
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/no_image.jpg', fit: BoxFit.cover);
                          },
                        )
                            : Container(
                          color: const Color(0xFFF3F4F6),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported_outlined,
                                  color: Color(0xFF9CA3AF)),
                              SizedBox(height: 6.h),
                              Text(
                                "No image attached",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasImage)
                        Positioned(
                          right: 10.w,
                          top: 10.h,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 5.h),

            // Reply message
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doubt Solve Message",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      replyMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF374151),
                        height: 1.35,
                      ),
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
}

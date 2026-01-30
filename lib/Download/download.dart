import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';

import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../PdfPathOpen/pdf_path_open.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import 'db.dart';
import 'dart:io';

class DownloadPdf extends StatefulWidget {
  const DownloadPdf({super.key});

  @override
  State<DownloadPdf> createState() => _DownloadPdfState();
}

class _DownloadPdfState extends State<DownloadPdf> {
  List<Map<String, dynamic>> _downloads = [];
  bool isLoading = false;

  void _openPDF(String filePath) {
    OpenFilex.open(filePath);
  }

  @override
  void initState() {
    super.initState();
    _fetchDownloads();
  }

  Future<void> _fetchDownloads() async {
    setState(() => isLoading = true); // ✅ START LOADER

    try {
      final data = await DBHelper.instance.getDownloads();

      setState(() {
        _downloads = data; // agar null aa sakta hai to: data ?? []
      });
    } catch (e) {
      setState(() {
        _downloads = [];
      });
    }

    setState(() => isLoading = false); // ✅ STOP LOADER
  }

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
              colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
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
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Downloaded',
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
                    "Access your saved videos & PDFs offline",
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

      body: isLoading
          ? const PrimaryCircularProgressWidget()
          : _downloads.isEmpty
          ? const Center(child: DataNotFoundWidget())
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _downloads.length,
              itemBuilder: (context, index) {
                final download = _downloads[index];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Stack(
                    children: [
                      // 🔹 MAIN CARD
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: HexColor('#0e4ccc').withOpacity(.25),
                            width: 1,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: HexColor('#0e4ccc').withOpacity(.25),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),

                          // 🔹 PDF ICON
                          leading: Container(
                            height: 46.h,
                            width: 46.h,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Image.asset(logo, height: 26.h),
                            ),
                          ),

                          // 🔹 TITLE
                          title: Text(
                            download['fileName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: HexColor('#0e4ccc'),
                            ),
                          ),

                          // 🔹 SUBTITLE
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              download['fileDate'],
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // 🔹 DELETE BUTTON
                          trailing: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _deleteFile(
                              download['id'],
                              download['filePath'],
                              download['fileName'],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8.sp),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20.sp,
                              ),
                            ),
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPathPage(
                                  pdfPath: download['filePath'],
                                  title: download['fileName'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 🔹 CATEGORY BADGE
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: HexColor('#0e4ccc').withOpacity(.25),
                              width: 1,
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: HexColor('#0e4ccc').withOpacity(.25),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            '${download['fileCat']} • ${download['fileSub']}',
                            style: GoogleFonts.poppins(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w500,
                              color: HexColor('#0e4ccc'),
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

  Future<void> _deletePDF(int id, String filePath) async {
    try {
      // Delete file from storage
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove entry from SQLite
      await DBHelper.instance.deleteDownload(id);

      // Refresh the list
      await _fetchDownloads();
    } catch (e) {
      print('Delete Error: $e');
    }
  }

  void _deleteFile(int id, String filePath, String fileName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 Icon
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.red.shade700],
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                /// 📝 Title
                Text(
                  "Delete File?",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                /// 📄 Description
                Text(
                  "Are you sure you want to delete\n$fileName ?\nThis action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 22),

                /// 🔘 Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _deletePDF(id, filePath);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Text(
                                "$fileName deleted successfully",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

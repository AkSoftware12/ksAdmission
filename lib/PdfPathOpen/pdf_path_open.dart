import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_content/secure_content.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../Utils/app_colors.dart';



class PdfViewerPathPage extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfViewerPathPage({super.key, required this.pdfPath, required this.title});
  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPathPage> {
  File? pdfFile; // Declare the file object
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isLoading = true; // Start with loading set to true

  @override
  void initState() {
    super.initState();
    loadPdfFile(); // Load the PDF file
  }

  Future<void> loadPdfFile() async {
    if (File(widget.pdfPath).existsSync()) {
      setState(() {
        pdfFile = File(widget.pdfPath);
        isLoading = false; // Set loading to false after loading file
      });
    } else {
      debugPrint('File not found: ${widget.pdfPath}');
      setState(() {
        isLoading = false; // Stop loading even if file is not found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    widget.title,
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
                    "Access your  PDFs Offline and Online",
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],

      ),

      body: SecureWidget(
        isSecure: true,
        builder: (context, onInit, onDispose) => Stack(
          children: [
            if (isLoading)
              PrimaryCircularProgressWidget()
            else if (pdfFile == null)
              DataNotFoundWidget() // Handle missing file case
            else
              SfPdfViewer.file(pdfFile!),
          ],
        ),
      ),
    );
  }
}

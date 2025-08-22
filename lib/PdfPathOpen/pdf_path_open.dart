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
        backgroundColor: primaryColor,
        title: Text(
          widget.title,
          style: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
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

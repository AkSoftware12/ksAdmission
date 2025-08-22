import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';

import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarPrimari.dart';
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
    final data = await DBHelper.instance.getDownloads();
    setState(() {
      _downloads = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('${'Downloaded'}', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? PrimaryCircularProgressWidget()
          : Column(
              children: [
                _downloads.isEmpty
                    ? Center(child: DataNotFoundWidget())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _downloads.length,
                          itemBuilder: (BuildContext context, int index) {
                            final download = _downloads[index];

                            return Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(3.sp),
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            00.sp,
                                          ),
                                          child: SizedBox(
                                            height: 40.sp,
                                            width: 40.sp,
                                            child: Image.asset(logo),
                                          ),
                                        ),
                                        title: Text(
                                          download['fileName'],
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: TextSizes.textsmall,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${download['fileDate']}',
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  fontSize: TextSizes.textsmall,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _deleteFile(
                                                download['id'],
                                                download['filePath'],
                                                download['fileName'],
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PdfViewerPathPage(
                                                    pdfPath:
                                                        '${download['filePath']}',
                                                    title:
                                                        '${download['fileName']}',
                                                  ),
                                            ),
                                          );
                                        },
                                        // onTap: () => _openPDF(download['filePath']),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      margin: EdgeInsets.all(3),

                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        // borderRadius: BorderRadius.circular(10.sp)
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.sp),
                                          topLeft: Radius.circular(10.sp),
                                          topRight: Radius.circular(10.sp),
                                          bottomRight: Radius.circular(10.sp),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(1.sp),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 8.sp,
                                            right: 8.sp,
                                          ),
                                          child: Text(
                                            '${download['fileCat']} / ${download['fileSub']}',
                                            style: GoogleFonts.radioCanada(
                                              textStyle: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                      ),
              ],
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
    // Confirm deletion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete $fileName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deletePDF(id, filePath);

              // Perform deletion logic here
              Navigator.pop(context); // Close dialog
              // Show a confirmation message, e.g., using a Snackbar
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$fileName deleted')));
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:open_filex/open_filex.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:realestate/Utils/app_colors.dart';
// import 'package:secure_content/secure_content.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//
// import '../../../CommonCalling/data_not_found.dart';
// import '../../../CommonCalling/progressbarWhite.dart';
// import '../../../CommonCalling/progressbarPrimari.dart';
//
// class PdfViewerPage extends StatefulWidget {
//   final String url;
//   final String title;
//   const PdfViewerPage({super.key, required this.url, required this.title});
//
//
// @override
// State<PdfViewerPage> createState() => _PdfViewerPageState();
// }
//
// class _PdfViewerPageState extends State<PdfViewerPage> {
//
//   ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
//   bool downloadCompleted = false;
//   bool isDownloading = false;
//   File? Pfile;
//   bool isLoading = false;
//   Future<void> loadNetwork() async {
//     setState(() {
//       isLoading = true;
//     });
//     var url = '${widget.url.toString()}';
//     final response = await http.get(Uri.parse(url));
//     final bytes = response.bodyBytes;
//     final filename = basename(url);
//     final dir = await getApplicationDocumentsDirectory();
//     var file = File('${dir.path}/$filename');
//     await file.writeAsBytes(bytes, flush: true);
//     setState(() {
//       Pfile = file;
//     });
//
//     print(Pfile);
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//
//   @override
//   void initState() {
//     // loadNetwork();
//     super.initState();
//   }
//   Future<void> downloadAndOpenPDF(String url, String filename, int index) async {
//
//
//     try {
//       Dio dio = Dio();
//
//       // Request permission to write to external storage
//       PermissionStatus status = await Permission.manageExternalStorage.request();
//
//       if (status.isGranted) {
//         // Get the directory to store the downloaded file
//         Directory? directory;
//         if (Platform.isAndroid) {
//           directory = await getExternalStorageDirectory();
//           String newPath = "";
//           List<String> folders = directory!.path.split("/");
//           for (int x = 1; x < folders.length; x++) {
//             String folder = folders[x];
//             if (folder != "Android") {
//               newPath += "/" + folder;
//             } else {
//               break;
//             }
//           }
//           newPath = newPath + "/Download";
//           directory = Directory(newPath);
//         } else {
//           directory = await getApplicationDocumentsDirectory();
//         }
//
//         if (!await directory.exists()) {
//           await directory.create(recursive: true);
//         }
//
//         String filePath = '${directory.path}/$filename.pdf';
//
//         // Start the download
//         await dio.download(
//           url,
//           filePath,
//           onReceiveProgress: (received, total) {
//             if (total != -1) {
//               setState(() {
//               });
//             }
//           },
//         );
//
//
//
//         // Open the downloaded PDF file
//         OpenFilex.open(filePath);
//       } else {
//         // Handle permission denied scenario
//       }
//     } catch (e) {
//       setState(() {
//       });
//
//       // Handle download failure
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: widget.url=='null'? primaryColor : Colors.white,
//       appBar: AppBar(
//         backgroundColor: widget.url=='null'? primaryColor : Colors.white,
//         iconTheme: IconThemeData(color:  widget.url=='null'? Colors.white : Colors.black,),
//         title: Text(
//           "${widget.title.toString()}",
//           style: GoogleFonts.roboto(
//             textStyle: TextStyle(
//                 color:  widget.url=='null'? Colors.white : Colors.black,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding:  EdgeInsets.all(0.sp),
//             child: Padding(
//               padding:  EdgeInsets.only(right: 13.sp),
//               child: GestureDetector(
//                 onTap: (){
//                   downloadAndOpenPDF(
//                       widget.url.toString(),
//                       widget.title,
//                      0 );
//                 },
//                   child: Icon(Icons.download_sharp,color:  widget.url=='null'? Colors.white : Colors.black,size: 25.sp,)),
//             ),
//           )
//         ],
//       ),
//       body:   Stack(
//         children: [
//          (widget.url=='null')
//               ? DataNotFoundWidget()
//               : isLoading
//              ? PrimaryCircularProgressWidget()
//              :
//
//          PDFView(
//            // filePath: Pfile!.path.replaceAll(RegExp(r"\s+"), ""),
//            filePath: Pfile?.path,
//
//         pageFling: true,
//            enableSwipe: true,
//
//            swipeHorizontal: true,
//            autoSpacing: false,
//            pageSnap: false,
//            fitEachPage: false,
//            fitPolicy: FitPolicy.BOTH,
//            onRender: (pages) {
//              print("Rendered $pages pages");
//            },
//            onPageChanged: (page, total) {
//              print("Current page: $page/$total");
//            },
//            onError: (error) {
//              print("Error: $error");
//            },
//            onPageError: (page, error) {
//              print("Error on page $page: $error");
//            },
//
//          )
//         ],
//       )
//     );
//   }
//
// }
//
//
//
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_content/secure_content.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarPrimari.dart';
import '../../../Download/db.dart';
import '../../../HexColorCode/HexColor.dart';

/// Represents Homepage for Navigation
class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  final String Subject;
  final String? category;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
    required this.category,
    required this.Subject,
  });

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<PdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isLoading = false;
  double progress = 0.0;
  bool isDownloading = false;
  bool _isLoading = false;
  bool _isDownloaded = false; // To track if file is downloaded

  List<Map<String, dynamic>> _downloads = [];

  @override
  void initState() {
    super.initState();
    _fetchDownloads();
    checkFileStatus();
  }

  Future<void> downloadAndOpenPDF(String url, String filename) async {
    bool isDownloading = true;
    double downloadProgress = 0.0;

    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    try {
      Dio dio = Dio();

      // Request permission to write to external storage
      PermissionStatus status = await Permission.manageExternalStorage
          .request();

      if (status.isGranted) {
        // Get the directory to store the downloaded file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> folders = directory!.path.split("/");
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Download";
          directory = Directory(newPath);
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        String filePath = '${directory.path}/$filename.pdf';

        // Start the download
        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadProgress = received / total;
              });
            }
          },
        );

        setState(() {
          isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed: $filePath')),
        );

        // Open the downloaded PDF file
        OpenFilex.open(filePath);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> _downloadPDF(
    String url,
    String name,
    String cat,
    String subject,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      DateTime currentDate = DateTime.now();
      String formattedDate =
          "${currentDate.year}-${currentDate.month}-${currentDate.day}";
      final filePath = '${dir.path}/${widget.title}.pdf';

      // Download the file
      await Dio().download(url, filePath);

      // Save file info in SQLite
      await DBHelper.instance.insertDownload({
        'fileName': '${name}',
        'fileCat': '${cat}',
        'fileSub': '${subject}',
        'fileDate': '${formattedDate}',
        'filePath': filePath,
      });

      // Refresh the list
      // await _fetchDownloads();

      setState(() {
        _isDownloaded = true;
      });
    } catch (e) {
      print('Download Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDownloads() async {
    final data = await DBHelper.instance.getDownloads();
    setState(() {
      _downloads = data;
    });
  }

  Future<void> checkFileStatus() async {
    final dbHelper = DBHelper.instance;
    final exists = await dbHelper.doesFileExist(widget.title);
    setState(() {
      _isDownloaded = exists;
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: HexColor('#fbfdf9'),
          // Set the background color to white
          content: Image.asset('assets/downloadedCom.gif'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Container(
                width: double.infinity,
                height: 40.sp,
                decoration: BoxDecoration(
                  color: HexColor('#79af4a'),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Center(
                  child: Text(
                    'OK',
                    style: GoogleFonts.radioCanada(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              color: Colors.black,
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
            (widget.url == 'null')
                ? DataNotFoundWidget()
                : isLoading
                ? PrimaryCircularProgressWidget()
                : SfPdfViewer.network('${widget.url}', key: _pdfViewerKey),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_isDownloaded) {
            _downloadPDF(
              '${widget.url}',
              '${widget.title}',
              '${widget.category}',
              '${widget.Subject}',
            );
          }
        },
        backgroundColor: Colors.blueGrey,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _isDownloaded
            ? GestureDetector(
                onTap: () {
                  _showDialog(context);
                },
                child: Icon(Icons.check, color: Colors.green, size: 25.sp),
              )
            : const Icon(Icons.download, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

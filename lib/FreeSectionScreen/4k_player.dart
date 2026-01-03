import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../HexColorCode/HexColor.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';

class FullScreenNetworkVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool live;

  const FullScreenNetworkVideoPlayer({
    super.key,
    required this.videoUrl, required this.live, required this.title,
  });

  @override
  State<FullScreenNetworkVideoPlayer> createState() =>
      _FullScreenNetworkVideoPlayerState();
}

class _FullScreenNetworkVideoPlayerState
    extends State<FullScreenNetworkVideoPlayer> {
  late BetterPlayerController _controller;

  /// 🔹 Dummy PDF list (API se replace kar sakte ho)
  final List<String> pdfList = [
    'Electric Charges Notes.pdf',
    'Important Questions.pdf',
    'Numericals Practice.pdf',
    'Previous Year Questions.pdf',
  ];

  @override
  void initState() {
    super.initState();
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      liveStream: widget.live, // true if HLS live stream
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fit: BoxFit.contain,
        aspectRatio: 9 / 16,
        allowedScreenSleep: false,
        autoDispose: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: true,
          enableFullscreen: true,
          enablePlayPause: true,
          enableSkips: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#010071'),
      appBar: AppBar(
        backgroundColor: HexColor('#010071'),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white
          ),
          textAlign: TextAlign.start,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 200.sp,
              child: BetterPlayer(
                controller: _controller,
              ),
            ),
            /// 📄 PDF SECTION
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5.sp),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PDF BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#010071'),
                          padding: EdgeInsets.symmetric(vertical: 0.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Open all PDFs / first PDF
                        },
                        icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
                        label:  Text('PDF',style: TextStyle(color: Colors.white,fontSize: 13.sp,fontWeight: FontWeight.bold),),
                      ),
                    ),

                    SizedBox(height: 20.sp),

                    /// PDF LIST
                    widget.live?
                    Expanded(
                      child: ListView.separated(
                        itemCount: pdfList.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          return Container(
                            padding:  EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: HexColor('#0e4ccc').withOpacity(.25), blurRadius: 6, spreadRadius: 1)
                                ],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: HexColor('#0e4ccc').withOpacity(.25),width: 1)
                            ),

                            // child: Row(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //
                            //     /// Thumbnail
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(10),
                            //       child: Container(
                            //         height: 50.sp,
                            //         width: 50.sp,
                            //         decoration: BoxDecoration(
                            //           color: Colors.grey.shade100,
                            //           borderRadius: BorderRadius.circular(10)
                            //         ),
                            //         child: Center(
                            //           child: Icon(
                            //             Icons.picture_as_pdf,
                            //             color: Colors.red,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 12),
                            //
                            //     /// Title + Top Icons + Buttons Column
                            //     Expanded(
                            //       child: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //
                            //           Row(
                            //             children: [
                            //               Expanded(
                            //                 child: Text(
                            //                   pdfList[index],
                            //                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            //                   maxLines: 1,
                            //                   overflow: TextOverflow.ellipsis,
                            //                 ),
                            //               ),
                            //               const SizedBox(width: 10),
                            //               Icon(Icons.share, color: Colors.black54)
                            //             ],
                            //           ),
                            //           const SizedBox(height: 10),
                            //           Row(
                            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //             children: [
                            //               // WATCH BUTTON
                            //               Expanded(
                            //                 child: SizedBox(
                            //                   height: 25.sp,
                            //                   child: ElevatedButton.icon(
                            //                     style: ElevatedButton.styleFrom(
                            //                       backgroundColor:  HexColor('#010071'),// Blue
                            //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            //                       padding: EdgeInsets.symmetric(vertical:0),
                            //                     ),
                            //                     icon: Icon(Icons.download,color: Colors.white,),
                            //                     label: Text("Download", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
                            //                     onPressed: () {
                            //
                            //                       // Navigator.push(
                            //                       //   context,
                            //                       //   MaterialPageRoute(
                            //                       //     builder: (_) => FullScreenNetworkVideoPlayer(
                            //                       //       videoUrl: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                            //                       //     ),
                            //                       //   ),
                            //                       // );
                            //
                            //                     },
                            //                   ),
                            //                 ),
                            //               ),
                            //
                            //               SizedBox(width: 10),
                            //
                            //               // PDF BUTTON
                            //               Expanded(
                            //                 child: SizedBox(
                            //                   height: 25.sp,
                            //                   child: ElevatedButton.icon(
                            //                     style: ElevatedButton.styleFrom(
                            //                       backgroundColor: Color(0xFFFF9800), // Orange
                            //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            //                       padding: EdgeInsets.symmetric(vertical: 0),
                            //                     ),
                            //                     icon: Icon(Icons.picture_as_pdf,color: Colors.white,),
                            //                     label: Text("View", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
                            //                     onPressed: () {
                            //                       Navigator.push(
                            //                         context,
                            //                         MaterialPageRoute(
                            //                           builder: (context) => PdfViewerPage(
                            //                             url: 'https://www.eks-intec.com/wp-content/uploads/2025/01/Sample-pdf.pdf',
                            //                             title: 'Test',
                            //                             category: '',
                            //                             Subject: '',
                            //                           ),
                            //                         ),
                            //                       );
                            //                     },
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           )
                            //
                            //         ],
                            //       ),
                            //     ),
                            //
                            //   ],
                            // ),
                          );

                        },
                      ),
                    ):
                    Expanded(
                      child: ListView.separated(
                        itemCount: pdfList.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          return Container(
                            padding:  EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: HexColor('#0e4ccc').withOpacity(.25), blurRadius: 6, spreadRadius: 1)
                                ],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: HexColor('#0e4ccc').withOpacity(.25),width: 1)
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 50.sp,
                                    width: 50.sp,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                /// Title + Top Icons + Buttons Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              pdfList[index],
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(Icons.share, color: Colors.black54)
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // WATCH BUTTON
                                          Expanded(
                                            child: SizedBox(
                                              height: 25.sp,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:  HexColor('#010071'),// Blue
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: EdgeInsets.symmetric(vertical:0),
                                                ),
                                                icon: Icon(Icons.download,color: Colors.white,),
                                                label: Text("Download", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
                                                onPressed: () {

                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (_) => FullScreenNetworkVideoPlayer(
                                                  //       videoUrl: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                                                  //     ),
                                                  //   ),
                                                  // );

                                                },
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: 10),

                                          // PDF BUTTON
                                          Expanded(
                                            child: SizedBox(
                                              height: 25.sp,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFFFF9800), // Orange
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: EdgeInsets.symmetric(vertical: 0),
                                                ),
                                                icon: Icon(Icons.picture_as_pdf,color: Colors.white,),
                                                label: Text("View", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PdfViewerPage(
                                                        url: 'https://www.eks-intec.com/wp-content/uploads/2025/01/Sample-pdf.pdf',
                                                        title: 'Test',
                                                        category: '',
                                                        Subject: '',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )

                                    ],
                                  ),
                                ),

                              ],
                            ),
                          );

                        },
                      ),
                    )
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

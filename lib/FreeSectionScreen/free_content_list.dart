import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../HexColorCode/HexColor.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';
import '4k_player.dart';

class FreeDemoClassPage extends StatelessWidget {

  final List<Map<String, String>> classList = [
    {"title": "Electric Charges and Fields - 1", "img": "https://i.postimg.cc/CBXFV7R6/Chat-GPT-Image-Dec-29-2025-01-59-13-PM.png"},
    {"title": "Electric Charges and Fields - 2", "img": "https://i.postimg.cc/xjXMm3gN/Chat-GPT-Image-Dec-29-2025-02-32-10-PM.png"},
    {"title": "Solutions - 1", "img": "https://i.postimg.cc/7CZtnyK3/Chat-GPT-Image-Dec-29-2025-01-50-17-PM.png"},
    {"title": "Solutions - 2", "img": "https://i.postimg.cc/Y4TNLcZ2/Chat-GPT-Image-Dec-29-2025-01-54-02-PM.png"},
    {"title": "Sexual reproduction in flowering plants - 1", "img": "https://i.postimg.cc/56XdsKnD/Chat-GPT-Image-Dec-29-2025-02-34-31-PM.png"},
    {"title": "Sexual reproduction in flowering plants - 2", "img": "https://i.postimg.cc/3y7qQtFJ/Chat-GPT-Image-Dec-29-2025-02-35-29-PM.png"},
    {"title": "Human Reproduction - 1", "img": "https://i.postimg.cc/nsH3PCnd/Chat-GPT-Image-Dec-29-2025-02-36-40-PM.png"},
  ];

   FreeDemoClassPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HexColor('#010071'),
        elevation: 0,
        title: const Text("Free-Demo Class",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: const [
          Icon(Icons.share, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: classList.length,
        itemBuilder: (context, index) {
          return  Container(
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
                  child: Image.network(
                    classList[index]["img"]!,
                    height: 60.sp,
                    width: 100,
                    fit: BoxFit.fill,
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
                              classList[index]["title"]!,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.download, color: Colors.black54),
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
                                icon: Icon(Icons.play_circle_fill,color: Colors.white,),
                                label: Text("Watch", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
                                onPressed: () {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenNetworkVideoPlayer(
                                        videoUrl: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                                        live: false,
                                        title: '${ classList[index]["title"]}',
                                      ),
                                    ),
                                  );

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
                                label: Text("PDF", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white)),
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
    );
  }

}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import 'package:realestate/CommonCalling/progressbarPrimari.dart';
import 'package:realestate/baseurl/baseurl.dart';

import '../ApiModel/api_responses.dart'; // FreeContentResponse
import '../ApiModel/livefree.dart';      // ContentItem, ContentPdf
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';
import '4k_player.dart';

class FreeContentApi {
  static Future<List<ContentItem>> fetchFreeContent(int demoId) async {
    final url = Uri.parse('$getFreeContentData$demoId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      final parsed = FreeContentResponse.fromJson(jsonMap);

      if (parsed.status == true) return parsed.data;

      throw Exception(parsed.message.isNotEmpty
          ? parsed.message
          : 'Something went wrong');
    } else {
      throw Exception('API Error: ${res.statusCode}');
    }
  }
}

class FreeDemoClassPage extends StatefulWidget {
  final int demoId; // ✅ dynamic id (e.g. 5)

  const FreeDemoClassPage({super.key, required this.demoId});

  @override
  State<FreeDemoClassPage> createState() => _FreeDemoClassPageState();
}

class _FreeDemoClassPageState extends State<FreeDemoClassPage> {
  bool _loading = true;
  String? _error;
  List<ContentItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await FreeContentApi.fetchFreeContent(widget.demoId);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openVideo(ContentItem item) {
    final url = item.playableUrl; // ✅ videoUrl > meetingUrl
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenNetworkVideoPlayer(
          videoUrl: url,
          live: false,
          title: item.title,
          item: item,
        ),
      ),
    );
  }

  void _openPdf(ContentPdf pdf) {
    Navigator.pop(context); // close bottomsheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          url: pdf.url,
          title: pdf.title.isEmpty ? 'PDF' : pdf.title,
          category: '',
          Subject: '',
        ),
      ),
    );
  }

  void _showPdfSheet(ContentItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final pdfs = item.pdfs;

        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .45,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.18),
                  blurRadius: 28,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    height: 5,
                    width: 64,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF010071).withOpacity(.10),
                          const Color(0xFFFF9800).withOpacity(.12),
                          const Color(0xFFFF3D3D).withOpacity(.10),
                        ],
                      ),
                      border: Border.all(color: Colors.black.withOpacity(.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: pdfs.isEmpty ? Colors.grey : Colors.red,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pdfs.isEmpty ? "No PDF Available" : "PDF Notes",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                pdfs.isEmpty
                                    ? "This lecture has no attached PDFs"
                                    : "Tap any PDF to open",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: pdfs.isEmpty
                                ? Colors.grey.shade400
                                : const Color(0xFF010071),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            pdfs.isEmpty ? "0 PDF" : "${pdfs.length} PDFs",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BODY
                  if (pdfs.isEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.folder_off_rounded,
                              size: 44,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No PDFs Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Teacher hasn’t uploaded\nany PDFs for this lecture yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 6),
                        itemCount: pdfs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final pdf = pdfs[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openPdf(pdf),
                              child: Ink(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF010071),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.06),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(.10),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        pdf.title.isEmpty
                                            ? "PDF ${i + 1}"
                                            : pdf.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF010071),
                                      size: 26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  // CLOSE
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF010071),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(ContentItem item) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: HexColor('#0e4ccc').withOpacity(.25),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: HexColor('#0e4ccc').withOpacity(.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 60.sp,
                  width: 100,
                  color: Colors.black12,
                ),
                Image.network(
                  item.thumbnail,
                  height: 60.sp,
                  width: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 60.sp,
                          width: 100,
                          color: Colors.black12,
                        ),
                        const PrimaryCircularProgressWidget(),
                      ],
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 60.sp,
                    width: 100,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Title + Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Share.share(
                          'https://play.google.com/store/apps/details?id=com.ksadmission&pcampaignid=web_share',
                        );
                      },
                      child: const Icon(
                        Icons.share,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // WATCH
                    Expanded(
                      child: SizedBox(
                        height: 25.sp,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor('#010071'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          icon: const Icon(Icons.play_circle_fill,
                              color: Colors.white),
                          label: const Text(
                            "Watch",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => _openVideo(item),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // PDF
                    Expanded(
                      child: SizedBox(
                        height: 25.sp,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.white),
                          label: Text(
                            item.pdfs.isEmpty ? "No PDF" : "PDF",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => _showPdfSheet(item),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back,
                    size: 25, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FREE LEARNING CONTENT',
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
                    "Watch videos & read PDFs – all in one place",
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
      body: _loading
          ? const Center(child: PrimaryCircularProgressWidget())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      )
          : _items.isEmpty
          ? const Center(child: Text("No free demo classes found"))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _items.length,
          itemBuilder: (_, index) => _buildCard(_items[index]),
        ),
      ),
    );
  }
}

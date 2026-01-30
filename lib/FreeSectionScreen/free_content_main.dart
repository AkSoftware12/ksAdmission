import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:realestate/HexColorCode/HexColor.dart';
import 'package:realestate/baseurl/baseurl.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../Utils/image.dart';
import 'free_content_list.dart';

/// ===============================
/// ✅ MODEL
/// ===============================
class FreeContentItem {
  final int id;
  final String title;
  final String className;
  final String thumbnail;

  FreeContentItem({
    required this.id,
    required this.title,
    required this.className,
    required this.thumbnail,
  });

  factory FreeContentItem.fromJson(Map<String, dynamic> json) {
    return FreeContentItem(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      className: (json['class'] ?? '').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
    );
  }
}

/// ===============================
/// ✅ API SERVICE
/// ===============================
class FreeContentApi {
  static final String url = getFreeContent;

  static Future<List<FreeContentItem>> fetchFreeContent() async {
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(res.body);

      if (jsonMap['status'] == true) {
        final List list = (jsonMap['data'] ?? []) as List;
        return list.map((e) => FreeContentItem.fromJson(e)).toList();
      } else {
        throw Exception(jsonMap['message'] ?? "Something went wrong");
      }
    } else {
      throw Exception("Server Error: ${res.statusCode}");
    }
  }
}

/// ===============================
/// ✅ SCREEN
/// ===============================
class FreeContentPage extends StatefulWidget {
  const FreeContentPage({super.key});

  @override
  State<FreeContentPage> createState() => _FreeContentPageState();
}

class _FreeContentPageState extends State<FreeContentPage>
    with SingleTickerProviderStateMixin {
  bool isGrid = false;

  bool isLoading = true;
  String? errorMsg;

  List<FreeContentItem> content = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final data = await FreeContentApi.fetchFreeContent();
      setState(() {
        content = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                    'FREE CONTENT',
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
                    "Watch free demo classes & sample videos",
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
        actions: [
          AnimatedScale(
            scale: 1,
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => setState(() => isGrid = !isGrid),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor('#010071').withOpacity(.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGrid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isGrid ? "List View" : "Grid View",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],      ),



      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(logo),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (rect) => LinearGradient(
                                  colors: [
                                    HexColor('#0e4ccc'),
                                    Colors.blueAccent
                                  ],
                                ).createShader(rect),
                                child: Text(
                                  "Explore Classes",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: .8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 18, color: HexColor('#0e4ccc')),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Learn free with high quality lessons!",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(.65),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: PrimaryCircularProgressWidget(),
      );
    }

    if (errorMsg != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 38, color: HexColor('#0e4ccc')),
              const SizedBox(height: 10),
              Text(
                "Failed to load content",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                errorMsg!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#0e4ccc'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (content.isEmpty) {
      return Center(
        child: Text(
          "No Free Content Found",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: isGrid ? buildGridView() : buildListView(),
    );
  }

  // ------------------ List View Style -------------------
  Widget buildListView() {
    return ListView.separated(
      itemCount: content.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = content[i];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FreeDemoClassPage(demoId: item.id,)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, HexColor('#eaf2ff')],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: HexColor('#0e4ccc').withOpacity(.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: "thumb_${item.id}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      item.thumbnail,
                      height: 75,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 75,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 75,
                          width: 100,
                          alignment: Alignment.center,
                          child: const PrimaryCircularProgressWidget(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HexColor('#0e4ccc').withOpacity(.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#0e4ccc'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: HexColor('#0e4ccc'),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------ Grid View Style -------------------
  Widget buildGridView() {
    return GridView.builder(
      itemCount: content.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .93,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        final item = content[i];

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FreeDemoClassPage(demoId: item.id,)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: HexColor('#0e4ccc').withOpacity(.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Hero(
                  tag: "thumb_${item.id}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      item.thumbnail,
                      height: 120.sp,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120.sp,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.broken_image_outlined,
                            size: 40, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 120.sp,
                          child: const Center(
                            child: PrimaryCircularProgressWidget(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.play_circle_fill_rounded,
                              size: 20, color: HexColor('#0e4ccc')),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HexColor('#0e4ccc').withOpacity(.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#0e4ccc'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

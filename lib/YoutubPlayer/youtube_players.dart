import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../HomePage/home_page.dart';
import '../Plan/plan.dart';
import '../baseurl/baseurl.dart';
import 'package:http/http.dart' as http;

class VideoPlayer extends StatefulWidget {
  final String url;
  final String title;
  final int? videoId;
  final String videoStatus; // "locked" or "unlocked"

  const VideoPlayer({
    super.key,
    required this.url,
    required this.title,
    required this.videoId,
    required this.videoStatus,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerYoutubeState();
}

class _VideoPlayerYoutubeState extends State<VideoPlayer> {
  late YoutubePlayerController _controller;

  /// **Check if video is unlocked**
  bool get isVideoUnlocked => widget.videoStatus == "unlocked";

  @override
  void initState() {
    super.initState();
    fetchVideoData();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
      // ..addListener(_trackVideoTime);

    print(widget.url);
  }


  void _playVideo(String url) {
    _controller.load(YoutubePlayer.convertUrlToId(url)!);
  }

  bool _isLoading = false;
  List<dynamic> videoList = [];

  Future<void> fetchVideoData() async {
    setState(() {
      _isLoading = true;
    });
    final Uri uri = Uri.parse('${getnextlecture}${widget.videoId}');
    final response = await http.get(uri);

    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData.containsKey('nextlectures')) {
        setState(() {
          videoList = jsonData['nextlectures'];
        });
      }
    } else {
      throw Exception('Failed to load video data');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
                child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title, // ✅ dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Offline Lecture • Jab Chaaho Tab Padho',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
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
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
        ),
        builder: (context, player) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🎥 VIDEO PLAYER
                Container(
                  color: Colors.black,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  ),
                ),

                /// 📌 TITLE CARD
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// ▶️ UP NEXT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Up Next",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🎞 VIDEO GRID
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: videoList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 16 / 10,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        _playVideo(videoList[index]['video_url']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                '${baseUrlImage}${videoList[index]['thumbnail']}',
                                fit: BoxFit.cover,
                              ),

                              /// ▶️ PLAY ICON
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.6),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),

                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

}

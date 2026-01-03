import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.title,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Video List',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _playVideo(videoList[index]['video_url']);
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${baseUrlImage}${videoList[index]['thumbnail'].toString()}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

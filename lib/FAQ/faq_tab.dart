import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/FAQ/faq.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../CommonCalling/progressbarPrimari.dart';
import '../Help/help.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class FaqTabScreen extends StatefulWidget {
  @override
  State<FaqTabScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqTabScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('FAQ', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Questions'),
            Tab(text: 'Video'),
            Tab(text: 'Chat Help'),
          ],
          labelColor: Colors.white, // Selected tab color
          unselectedLabelColor: Colors.grey,
          indicatorColor: homepageColor, // Underline color
          onTap: (index) {
            _pageController.jumpToPage(index); // Jump to the page when tab is clicked
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController?.animateTo(index); // Change tab when page is swiped
        },
        children: [
          FaqScreen(appBar: '',),
          FullScreenVideoPlayer(),
          HelpScreen(appBar: '',),
        ],
      ),
    );
  }
}





class FullScreenVideoPlayer extends StatefulWidget {
  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  // late VideoPlayerController _controller;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.asset('assets/videoplayback.mp4')
    //   ..initialize().then((_) {
    //     setState(() {});
    //   })
    //   ..setLooping(true)
    //   ..play().then((_) {
    //     setState(() {
    //       _isPlaying = true;
    //     });
    //   });
    //
    // _controller.addListener(() {
    //   setState(() {
    //     _currentPosition = _controller.value.position;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // _controller.value.isInitialized
          //     ? SizedBox(
          //   width: double.infinity,
          //   height: double.infinity,
          //   child: AspectRatio(
          //     aspectRatio: _controller.value.aspectRatio,
          //     child: VideoPlayer(_controller),
          //   ),
          // )
          //     : Center(child: PrimaryCircularProgressWidget()),
        ],
      ),
      // bottomNavigationBar: Container(
      //   color: Colors.grey[850], // Set your desired color here
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       // VideoProgressIndicator(
      //       //   _controller,
      //       //   allowScrubbing: true,
      //       //   colors: VideoProgressColors(playedColor: Colors.red),
      //       // ),
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               _formatDuration(_currentPosition),
      //               style: TextStyle(color: Colors.white),
      //             ),
      //             Text(
      //               _formatDuration(_controller.value.duration),
      //               style: TextStyle(color: Colors.white),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.redAccent,
      //   onPressed: () {
      //     setState(() {
      //       if (_controller.value.isPlaying) {
      //         _controller.pause();
      //       } else {
      //         _controller.play();
      //       }
      //       _isPlaying = _controller.value.isPlaying;
      //     });
      //   },
      //   child: Icon(
      //     _isPlaying ? Icons.pause : Icons.play_arrow,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
  }
}

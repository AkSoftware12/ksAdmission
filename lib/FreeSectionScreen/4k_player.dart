import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../ApiModel/livefree.dart'; // ContentItem, ContentPdf
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';

class FullScreenNetworkVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool live;
  final ContentItem? item;

  const FullScreenNetworkVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.live,
    required this.title,
    this.item,
  });

  @override
  State<FullScreenNetworkVideoPlayer> createState() =>
      _FullScreenNetworkVideoPlayerState();
}

class _FullScreenNetworkVideoPlayerState extends State<FullScreenNetworkVideoPlayer>
    with WidgetsBindingObserver {
  late BetterPlayerController _controller;

  bool _isPlaying = true;

  // ✅ YouTube-like Live Chat (same screen, same bottom container)
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(name: "System", text: "Welcome to live chat ✅", time: "Now"),
    _ChatMsg(name: "Student", text: "Sir doubt hai", time: "Now"),
    _ChatMsg(name: "You", text: "Haan bolo", time: "Now", isMe: true),
  ];

  void _sendMsg() {
    final t = _chatCtrl.text.trim();
    if (t.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(name: "You", text: t, time: "Now", isMe: true));
      _chatCtrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 60), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Screen never sleep
    WakelockPlus.enable();

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      liveStream: widget.live,
      useAsmsSubtitles: false,
      useAsmsTracks: false,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fit: BoxFit.contain,
        aspectRatio: 9 / 16,
        allowedScreenSleep: false,
        autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: true,
          enableFullscreen: true,
          enablePlayPause: true,
          enableSkips: false,
          enableProgressBar: widget.live ? false : true,
          enableProgressText: widget.live ? false : true,
        ),
        eventListener: (event) async {
          if (!mounted) return;

          if (widget.live &&
              event.betterPlayerEventType ==
                  BetterPlayerEventType.hideFullscreen) {
            await _controller.pause();
            await Future.delayed(const Duration(milliseconds: 200));
            await _controller.play();
          }

          if (event.betterPlayerEventType ==
              BetterPlayerEventType.openFullscreen ||
              event.betterPlayerEventType ==
                  BetterPlayerEventType.hideFullscreen) {
            if (_isPlaying) await WakelockPlus.enable();
          }

          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            _isPlaying = true;
            await WakelockPlus.enable();
          } else if (event.betterPlayerEventType == BetterPlayerEventType.pause ||
              event.betterPlayerEventType == BetterPlayerEventType.finished) {
            _isPlaying = false;
            await WakelockPlus.disable();
          }
        },
      ),
      betterPlayerDataSource: dataSource,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && _isPlaying) {
        await WakelockPlus.enable();
      }

      // ✅ start at bottom (latest)
      Future.delayed(const Duration(milliseconds: 80), () {
        if (_chatScroll.hasClients) {
          _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _controller.dispose();

    _chatCtrl.dispose();
    _chatScroll.dispose();

    super.dispose();
  }

  /// 🔁 App background / foreground handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        await WakelockPlus.enable();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeItem = widget.item ??
        ContentItem(
          id: 0,
          title: widget.title,
          thumbnail: "",
          pdfs: const [],
        );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
                child:
                const Icon(Icons.arrow_back, size: 25, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
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
                    widget.live
                        ? "Join live classes & interact with teachers in real time"
                        : "Watch recording & download notes",
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
      body: SafeArea(
        child: Column(
          children: [
            // ✅ top video
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(controller: _controller),
                  ),

                  widget.live? Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.h),
                      width: 40.sp,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.white),
                          SizedBox(width: 3.w),
                          Text(
                            "LIVE",
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):SizedBox()

                ],
              ),
            ),

            // ✅ bottom section
            Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.all(5.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: widget.live ? _liveUi() : _pdfUi(safeItem),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ✅ LIVE UI (YouTube-like)
  // =========================================================
  Widget _liveUi() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            // color: const Color(0xFF010071),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.red.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Live Comments",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),

        // Messages
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: _messages.isEmpty
                ? Center(
              child: Text(
                "No messages yet",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            )
                : ListView.builder(
              controller: _chatScroll,
              padding: EdgeInsets.all(12.w),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ytMsgTile(_messages[i]),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // Composer
        Container(
          padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF010071),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatCtrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMsg(),
                  decoration: InputDecoration(
                    hintText: "Say something…",
                    hintStyle: TextStyle(
                      fontSize: 12.5.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: _sendMsg,
                  borderRadius: BorderRadius.circular(15),
                  splashColor: Colors.white.withOpacity(0.25),
                  highlightColor: Colors.white.withOpacity(0.12),
                  child: Ink(
                    height: 44.h,
                    width: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _ytMsgTile(_ChatMsg m) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: m.isMe ? HexColor('#010071') : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                m.name.isNotEmpty ? m.name[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: m.isMe ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      m.time,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  m.text,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== PDF UI =====================

  Widget _pdfUi(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#010071'),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: Text(
              'PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (item.pdfs.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 6),
              itemCount: item.pdfs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final pdf = item.pdfs[i];
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
                              pdf.title.isEmpty ? "PDF ${i + 1}" : pdf.title,
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
      ],
    );
  }

  void _openPdf(ContentPdf pdf) {
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
}

class _ChatMsg {
  final String name;
  final String text;
  final String time;
  final bool isMe;

  _ChatMsg({
    required this.name,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}

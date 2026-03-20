import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:realestate/Plan/plan.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../ApiModel/livefree.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../HomeScreen/Year/SubjectScreen/webView.dart';

class FullScreenNetworkVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool live;
  final bool isLocked;
  final ContentItem? item;

  const FullScreenNetworkVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.live,
    required this.title,
    required this.isLocked,
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

  // ✅ 24-Hour Trial Reset System
  late Timer _trialTimer;
  int _trialSecondsRemaining = 300;
  bool _trialStarted = false;
  bool _trialExpired = false;
  late SharedPreferences _prefs;
  int _timerStartTime = 0;
  int? _savedRemainingTime = null;

  // ✅ 24-Hour Keys
  late String _trialExpiredKey;
  late String _trialStartTimeKey;
  late String _lastResetTimeKey;
  late String _totalTrialUsedKey;

  // ✅ LIVE POSITION TRACKING
  late Duration _lastLivePosition = Duration.zero;
  DateTime? _lastPositionUpdateTime;

  // ✅ YouTube-like Live Chat
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(name: "System", text: "Welcome to live chat ✅", time: "Now"),
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

  // ✅ Update live stream position
  void _updateLivePosition(Duration position) {
    if (widget.live) {
      _lastLivePosition = position;
      _lastPositionUpdateTime = DateTime.now();
      print('📍 Live position synced: ${position.inSeconds}s');
    }
  }

  // ✅ Check & Reset Trial if 24h passed
  Future<void> _checkAnd24hReset() async {
    int? lastResetTime = _prefs.getInt(_lastResetTimeKey);
    int nowTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    print('📅 Last reset: $lastResetTime, Now: $nowTime');

    if (lastResetTime == null) {
      await _prefs.setInt(_lastResetTimeKey, nowTime);
      print('🔄 First reset time set: $nowTime');
      return;
    }

    int elapsedSeconds = nowTime - lastResetTime;
    int elapsedHours = elapsedSeconds ~/ 3600;

    print('⏰ Elapsed hours since last reset: $elapsedHours');

    if (elapsedSeconds >= 86400) {
      print('🔥 24-HOUR RESET TRIGGERED!');

      await _prefs.remove(_trialExpiredKey);
      await _prefs.remove(_trialStartTimeKey);
      await _prefs.remove('trial_paused_${widget.videoUrl.hashCode}');
      await _prefs.remove('trial_paused_seconds_${widget.videoUrl.hashCode}');
      await _prefs.remove(_totalTrialUsedKey);

      await _prefs.setInt(_lastResetTimeKey, nowTime);

      setState(() {
        _trialExpired = false;
        _trialStarted = false;
        _trialSecondsRemaining = 300;
      });

      print('✅ Trial reset successful! New 5-min available');
    }
  }

  // ✅ Load Trial Status from SharedPreferences
  Future<void> _loadTrialStatus() async {
    _prefs = await SharedPreferences.getInstance();

    _trialExpiredKey = 'trial_expired_${widget.videoUrl.hashCode}';
    _trialStartTimeKey = 'trial_start_${widget.videoUrl.hashCode}';
    _lastResetTimeKey = 'trial_last_reset_${widget.videoUrl.hashCode}';
    _totalTrialUsedKey = 'trial_used_${widget.videoUrl.hashCode}';

    String pausedTimeKey = 'trial_paused_${widget.videoUrl.hashCode}';
    String pausedSecondsKey = 'trial_paused_seconds_${widget.videoUrl.hashCode}';

    await _checkAnd24hReset();

    bool alreadyExpired = _prefs.getBool(_trialExpiredKey) ?? false;

    if (alreadyExpired) {
      setState(() {
        _trialExpired = true;
        _trialSecondsRemaining = 0;
        _trialStarted = true;
      });
      print('❌ Trial already expired!');
      return;
    }

    int? pausedAt = _prefs.getInt(pausedTimeKey);
    int? pausedSeconds = _prefs.getInt(pausedSecondsKey);

    if (pausedAt != null && pausedSeconds != null) {
      print('⏸️ Resuming from pause: $pausedSeconds seconds remaining');

      setState(() {
        _trialSecondsRemaining = pausedSeconds;
        _trialStarted = true;
      });

      await _prefs.remove(pausedTimeKey);
      await _prefs.remove(pausedSecondsKey);

      int? savedStartTime = _prefs.getInt(_trialStartTimeKey);
      if (savedStartTime != null) {
        _timerStartTime = savedStartTime;
        _continueTrialTimer(savedStartTime);
      }
      return;
    }

    int? savedStartTime = _prefs.getInt(_trialStartTimeKey);

    if (savedStartTime != null) {
      _timerStartTime = savedStartTime;

      int elapsedSeconds =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - savedStartTime;
      int remaining = 300 - elapsedSeconds;

      print('⏱️ Fresh load: $remaining seconds left (elapsed: $elapsedSeconds)');

      if (remaining <= 0) {
        setState(() {
          _trialExpired = true;
          _trialSecondsRemaining = 0;
          _trialStarted = true;
        });
        await _prefs.setBool(_trialExpiredKey, true);
        print('❌ Trial expired on load!');
        return;
      }

      setState(() {
        _trialSecondsRemaining = remaining;
        _trialStarted = true;
      });

      _continueTrialTimer(savedStartTime);
    }
  }

  // ✅ Start Trial Timer (first play)
  void _startTrialTimer() {
    if (!_trialStarted && widget.isLocked && !_trialExpired) {
      _trialStarted = true;

      int startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _timerStartTime = startTime;
      _prefs.setInt(_trialStartTimeKey, startTime);

      print('🚀 Starting trial timer from: $startTime');

      _continueTrialTimer(startTime);
    }
  }

  // ✅ Continue Trial Timer
  void _continueTrialTimer(int startTime) {
    if (_trialTimer.isActive) {
      _trialTimer.cancel();
    }

    _timerStartTime = startTime;

    _trialTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      int elapsedSeconds =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - startTime;
      int remaining = 300 - elapsedSeconds;

      setState(() {
        _trialSecondsRemaining = remaining > 0 ? remaining : 0;
      });

      if (remaining <= 0 && !_trialExpired) {
        _trialExpired = true;
        timer.cancel();

        _prefs.setBool(_trialExpiredKey, true);

        print('❌ Trial expired!');

        if (_isPlaying) {
          try {
            _controller.pause();
          } catch (e) {
            print('Error pausing: $e');
          }
        }

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _showSubscriptionPopup(context);
          }
        });
      }
    });
  }

  // ✅ Subscription Popup
  void _showSubscriptionPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              HexColor('#010071'),
                              HexColor('#0A1AFF'),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 46.sp,
                              width: 46.sp,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 26.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Trial Expired",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    child: Text(
                                      "Your 5-minute free trial has ended. Please subscribe to continue.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                        child: Column(
                          children: [
                            Text(
                              "Premium Features Unlock करें",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _modernPremiumFeature("🎥", "Full Live Class Access",
                                "Complete live streaming without limits"),
                            SizedBox(height: 8.h),
                            _modernPremiumFeature("📄", "PDF Notes Download",
                                "Download all class materials instantly"),
                            SizedBox(height: 8.h),
                            _modernPremiumFeature(
                                "⏺️", "Recording Playback", "Watch classes anytime, anywhere"),

                            SizedBox(height: 18.h),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      side: BorderSide(color: HexColor('#010071')),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    child: Text(
                                      "Maybe Later",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: HexColor('#010071'),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _goToSubscription();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HexColor('#010071'),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.flash_on_rounded,
                                            size: 18.sp, color: Colors.white),
                                        SizedBox(width: 6.w),
                                        Text(
                                          "Subscribe Now",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -14.h,
              right: 12.w,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 34.sp,
                  width: 34.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(Icons.close_rounded, size: 18.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Modern Premium Feature Tile
  Widget _modernPremiumFeature(String emoji, String title, String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: HexColor('#0A1AFF').withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: HexColor('#010071'),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToSubscription() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlanScreen(appBar: 'abb')),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _trialTimer = Timer(Duration.zero, () {});

    WakelockPlus.enable();

    _loadTrialStatus();

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

          // ✅ Track live position
          if (widget.live && event.betterPlayerEventType == BetterPlayerEventType.play) {
            try {
              _updateLivePosition(_controller.videoPlayerController?.value.position ?? Duration.zero);
            } catch (e) {
              print('Error tracking position: $e');
            }
          }

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

            if (widget.isLocked && _trialExpired) {
              try {
                await _controller.pause();
                await Future.delayed(const Duration(milliseconds: 50));
              } catch (e) {
                print('Error pausing on expired: $e');
              }

              if (mounted) {
                _showSubscriptionPopup(context);
              }
              return;
            }

            _startTrialTimer();
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

      Future.delayed(const Duration(milliseconds: 80), () {
        if (_chatScroll.hasClients) {
          _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
        }
      });
    });


    joinLiveClass();
  }

  Future<void> joinLiveClass() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // Current date time in this format: 2026-03-20 16:50:00
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    var url = Uri.parse(joinClass);
    var response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "live_class_id": widget.item?.id,
        "joined_at": currentTime,
      }),
    );

    print("Time Sent: $currentTime");
    print(response.body);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();

    try {
      if (!_trialExpired && _trialStarted && _timerStartTime > 0) {
        String pausedTimeKey = 'trial_paused_${widget.videoUrl.hashCode}';
        String pausedSecondsKey = 'trial_paused_seconds_${widget.videoUrl.hashCode}';

        int pausedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        print('⏸️ Pausing timer - remaining: $_trialSecondsRemaining seconds');

        _prefs.setInt(pausedTimeKey, pausedAt);
        _prefs.setInt(pausedSecondsKey, _trialSecondsRemaining);

        if (_trialTimer.isActive) {
          _trialTimer.cancel();
        }
      } else if (_trialTimer.isActive) {
        _trialTimer.cancel();
      }
    } catch (e) {
      print('Error in dispose: $e');
    }

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
      print('📱 App RESUMED');

      if (_isPlaying) {
        await WakelockPlus.enable();
      }

      await _checkAnd24hReset();

      if (widget.isLocked && _trialStarted && !_trialExpired) {
        _resumeTimerWithLiveSync();
      }

      // ✅ For LIVE streams: ensure player is still synced with server
      if (widget.live && _isPlaying) {
        try {
          await _controller.pause();
          await Future.delayed(const Duration(milliseconds: 300));
          await _controller.play();
          print('🔄 Live stream re-synced');
        } catch (e) {
          print('Error re-syncing live: $e');
        }
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print('📱 App PAUSED/DETACHED');

      if (_trialTimer.isActive) {
        _trialTimer.cancel();
      }
      await WakelockPlus.disable();
    }
  }

  // ✅ Resume Timer (from background) - LIVE SYNC VERSION
  void _resumeTimerWithLiveSync() {
    if (!widget.isLocked || !_trialStarted || _trialExpired || _timerStartTime <= 0) {
      return;
    }

    int elapsedSeconds =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - _timerStartTime;
    int remaining = 300 - elapsedSeconds;

    print('⏱️ Resuming from background: $remaining seconds left (elapsed: $elapsedSeconds)');

    if (remaining <= 0) {
      setState(() {
        _trialExpired = true;
        _trialSecondsRemaining = 0;
      });
      _prefs.setBool(_trialExpiredKey, true);
      print('❌ Trial expired while in background!');

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isPlaying) {
          try {
            _controller.pause();
            _showSubscriptionPopup(context);
          } catch (e) {
            print('Error pausing: $e');
          }
        }
      });
      return;
    }

    // ✅ For LIVE streams, warn if trial about to expire (< 15 sec warning)
    if (widget.live && remaining < 15) {
      if (_isPlaying) {
        try {
          _controller.pause();
        } catch (e) {
          print('Error pausing live: $e');
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('⏰ Trial Expiring Soon'),
          content: Text('Your 5-minute trial expires in ${remaining}s'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Exit & Subscribe'),
            )
          ],
        ),
      );
      return;
    }

    _continueTrialTimer(_timerStartTime);
  }

  // ✅ Format timer (MM:SS)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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

                  if (widget.live)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.red.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, size: 8, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  "LIVE",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.isLocked && !_trialExpired)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined,
                                        size: 8, color: Colors.white),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _formatTime(_trialSecondsRemaining),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

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

  Widget _liveUi() {
    return Column(
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
        )
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
                    "Teacher hasn't uploaded\nany PDFs for this lecture yet.",
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
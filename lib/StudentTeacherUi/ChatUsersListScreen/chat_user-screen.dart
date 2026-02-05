import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../../Utils/image.dart';

class ChatUserScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String image;
  final String currentUser;
  final String chatUser;
  final bool canSend;


  const ChatUserScreen({
    super.key,
    required this.chatId,
    required this.userName,
    required this.image,
    required this.currentUser,
    required this.chatUser,
    this.canSend = true,
  });

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final _db = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  final _msg = TextEditingController();
  final _scroll = ScrollController();

  late final String _chatId;
  bool _uploading = false;

  // ✅ Your Cloudinary Cloud Name (from your screenshot)
  static const String cloudName = "djg2bfwki";

  // ✅ Put your UNSIGNED preset name here (example: chat_unsigned)
  static const String uploadPreset = "chat_unsigned";

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId.isNotEmpty
        ? widget.chatId
        : buildChatId(widget.currentUser, widget.chatUser);
  }

  @override
  void dispose() {
    _msg.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------------- SEND TEXT ----------------
  Future<void> sendText() async {
    final text = _msg.text.trim();
    if (text.isEmpty) return;

    _msg.clear();

    await _sendMessage({"type": "text", "text": text});
  }

  // ---------------- PICK + SEND IMAGE ----------------
  Future<void> pickAndSendImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1400,
    );
    if (picked == null) return;

    setState(() => _uploading = true);

    try {
      final file = File(picked.path);
      final url = await _uploadToCloudinary(file);

      await _sendMessage({"type": "image", "imageUrl": url});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ---------------- CLOUDINARY UPLOAD ----------------
  Future<String> _uploadToCloudinary(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..fields["folder"] = "chat_images/$_chatId"
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw Exception("Cloudinary error ${streamed.statusCode}: $body");
    }

    final jsonMap = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = (jsonMap["secure_url"] ?? "").toString();

    if (secureUrl.isEmpty) {
      throw Exception("Cloudinary: secure_url missing: $body");
    }
    return secureUrl;
  }

  // ---------------- FIRESTORE SEND ----------------
  Future<void> _sendMessage(Map<String, dynamic> payload) async {
    await _db.collection("chats").doc(_chatId).collection("messages").add({
      ...payload,
      "senderId": widget.currentUser,
      "receiverId": widget.chatUser,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _db.collection("chats").doc(_chatId).set({
      "users": [widget.currentUser, widget.chatUser],
      "lastMessage": payload["type"] == "text" ? payload["text"] : "📷 Image",
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final name = widget.userName.isEmpty ? "Chat" : widget.userName;

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

            const SizedBox(width: 10),

            // 🔹 Profile Image (Circular)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: widget.image.isNotEmpty
                  ? NetworkImage(widget.image)
                  : null,
              child: widget.image.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
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
                    "Online",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

          if (widget.canSend)
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.videocam_rounded),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => NotificationList()),
                // );
              },
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Opacity(
                      opacity: 0.09, // Adjust the opacity
                      child: Image.asset(logo),
                    ),
                  ),
                ),
                _buildChatList(),
              ],
            ),
          ),

          if (!widget.canSend)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_rounded, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Chat slot expired. You can only view messages.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection("chats")
          .doc(_chatId)
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) return const _EmptyChatState();

        final items = _buildChatItems(docs);

        return ListView.builder(
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            if (it is _DateChipItem) return _DateChip(text: it.label);

            final m = it as _MessageItem;
            final isMe = m.senderId == widget.currentUser;

            return _MessageBubble(item: m, isMe: isMe);
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF121826),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _uploading ? null : pickAndSendImage,
                      icon: const Icon(
                        Icons.image_rounded,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _msg,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: "Type a message…",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => sendText(),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _uploading ? null : sendText,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF010071),
                      Color(0xFF0A1AFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _uploading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DATE CHIPS + ITEMS ----------------
  List<_ChatListItem> _buildChatItems(List<QueryDocumentSnapshot> docs) {
    final items = <_ChatListItem>[];
    DateTime? lastDay;

    for (final d in docs) {
      final m = d.data() as Map<String, dynamic>;

      final type = (m["type"] ?? "text").toString();
      final senderId = (m["senderId"] ?? "").toString();

      DateTime? dt;
      final ts = m["createdAt"];
      if (ts is Timestamp) dt = ts.toDate();

      final day = dt == null ? null : DateTime(dt.year, dt.month, dt.day);

      if (day != null && (lastDay == null || day != lastDay)) {
        items.add(_DateChipItem(_humanDayLabel(day)));
        lastDay = day;
      }

      items.add(
        _MessageItem(
          type: type,
          senderId: senderId,
          text: (m["text"] ?? "").toString(),
          imageUrl: (m["imageUrl"] ?? "").toString(),
          timeText: dt == null ? "" : DateFormat('hh:mm a').format(dt),
        ),
      );
    }

    return items;
  }
}

// ===================== UI PIECES =====================

class _MessageBubble extends StatelessWidget {
  final _MessageItem item;
  final bool isMe;

  const _MessageBubble({required this.item, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFF1D4ED8) : const Color(0xFF111827);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (item.type == "text")
              Text(
                item.text.trim(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),

            if (item.type == "image" && item.imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullImageView(url: item.imageUrl),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    height: 200,
                    width: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, w, p) {
                      if (p == null) return w;
                      return Container(
                        height: 200,
                        width: 220,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      width: 220,
                      alignment: Alignment.center,
                      color: Colors.white10,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),
            Text(
              item.timeText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.70),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class _FullImageView extends StatefulWidget {
  final String url;

  const _FullImageView({required this.url});

  @override
  State<_FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<_FullImageView> {
  String _message = '';


  Future<void> _saveNetworkImage() async {
    setState(() => _message = 'Saving network image...');

    final bool? success = await GallerySaver.saveImage(widget.url);
    setState(() {
      _message =
      success == true ? 'Network image saved!' : 'Failed to save image';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _saveNetworkImage,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(widget.url),
        ),
      ),
    );
  }
}


class _DateChip extends StatelessWidget {
  final String text;

  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade400, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: Color(0xFF6366F1),
            ),
            SizedBox(height: 12),
            Text(
              "Say hi 👋",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Start the conversation",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ===================== HELPERS =====================

abstract class _ChatListItem {}

class _MessageItem extends _ChatListItem {
  final String type; // text / image
  final String senderId;
  final String text;
  final String imageUrl;
  final String timeText;

  _MessageItem({
    required this.type,
    required this.senderId,
    required this.text,
    required this.imageUrl,
    required this.timeText,
  });
}

class _DateChipItem extends _ChatListItem {
  final String label;

  _DateChipItem(this.label);
}

String _humanDayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (day == today) return "Today";
  if (day == yesterday) return "Yesterday";
  return DateFormat('dd MMM, yyyy').format(day);
}

String buildChatId(String a, String b) {
  final x = a.trim();
  final y = b.trim();
  return (x.compareTo(y) < 0) ? "${x}_$y" : "${y}_$x";
}

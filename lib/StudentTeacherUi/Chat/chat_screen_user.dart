import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';


class ChatUserScreen extends StatefulWidget {
  final String image;
  final String chatId;
  final String userName;
  final User currentUser;
  final dynamic chatUser;


  const ChatUserScreen({
    Key? key,
    required this.chatId,
    required this.userName,
    required this.image,
    required this.currentUser,
    required this.chatUser,
  }) : super(key: key);

  @override
  State<ChatUserScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatUserScreen> {
  TextEditingController messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController artistController = TextEditingController();
  bool _isComposing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }



  void _sendMessage() {
    if (messageController.text.trim().isNotEmpty) {
      String chatRoomId =
          getChatRoomId(widget.currentUser.uid, widget.chatUser['uid']);
      _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': messageController.text.trim(),
        'sender': widget.currentUser.uid,
        'receiver': widget.chatUser['uid'],
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false, // New field for message seen status
      });
      messageController.clear();
    }
  }

// Mark messages as seen when chat is opened
  void _markMessagesAsSeen() {
    String chatRoomId =
        getChatRoomId(widget.currentUser.uid, widget.chatUser['uid']);

    _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiver', isEqualTo: widget.currentUser.uid)
        .where('seen', isEqualTo: false)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({'seen': true});
      }
    });
  }

  // void _sendMessage() {
  //   if (messageController.text.trim().isNotEmpty) {
  //     String chatRoomId =
  //         getChatRoomId(widget.currentUser.uid, widget.chatUser['uid']);
  //     _firestore
  //         .collection('chats')
  //         .doc(chatRoomId)
  //         .collection('messages')
  //         .add({
  //       'text': messageController.text.trim(),
  //       'sender': widget.currentUser.uid,
  //       'receiver': widget.chatUser['uid'],
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //     messageController.clear();
  //   }
  // }

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FocusNode focusNodeNickname = FocusNode();
  Timer? timer;
  bool _isPressed = false;

  String id = '';
  String userId = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String userEmail = '';

  List<dynamic> apiData = [];


  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Handle the selected file here
      String filePath = file.path ?? "";
      print('Selected file path: $filePath');
    } else {
      // User canceled the picker
      print('User canceled file picking');
    }
  }

  @override
  void initState() {
    super.initState();
    _updateUserStatus(true);
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    _updateUserStatus(false);
    timer?.cancel();
    super.dispose();
  }

  void _updateUserStatus(bool isOnline) {
    _firestore.collection('users').doc(widget.currentUser.uid).update({
      'isOnline': isOnline,
      'lastSeen': isOnline ? FieldValue.serverTimestamp() : Timestamp.now(),
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return "N/A"; // Default text if timestamp is null
    }

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('hh:mm a').format(dateTime); // Formats as 12-hour time with AM/PM
    }

    return timestamp.toString(); // Fallback for unexpected types
  }


  @override
  Widget build(BuildContext context) {
    String chatRoomId =
        getChatRoomId(widget.currentUser.uid, widget.chatUser['uid']);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          title: Row(
            children: [

              CircleAvatar(
                backgroundColor:Colors.grey.withOpacity(0.1),
                child: Text(widget.chatUser['name'][0].toUpperCase(),style: TextStyle(color: Colors.white),),
              ),
              SizedBox(width: 5.sp,),
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(widget.chatUser['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    bool isOnline = snapshot.data!['isOnline'] ?? false;
                    Timestamp? lastSeenTimestamp = snapshot.data!['lastSeen'];
                    String lastSeen = lastSeenTimestamp != null
                        ? _formatTimestamp(lastSeenTimestamp)
                        : 'Unknown';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.chatUser['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp)),
                        Text(
                          isOnline ? 'Online' : 'Last seen: $lastSeen',
                          style: TextStyle(
                              color: isOnline ? Colors.green : Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  }
                  return Text(widget.chatUser['name'],
                      style: TextStyle(color: Colors.white));
                },
              ),
            ],
          ),
          backgroundColor: primaryColor,
          actions: [
            // GestureDetector(
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) {
            //     //       return VideoCallScreen(
            //     //         id: widget.chatId.toString(),
            //     //       ); // Pass ID to MainScreen
            //     //     },
            //     //   ),
            //     // );
            //   },
            //   child: Icon(Icons.video_call, color: Colors.white, size: 25.sp),
            // ),
            SizedBox(
              width: 30.sp,
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Opacity(
                            opacity: 0.1, // 20% visible
                            child: SizedBox(
                              // height: 150.sp,
                              // width: 150.sp,
                              child: Image.asset(
                                'assets/logo2.png',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 80.sp),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('chats')
                                  .doc(chatRoomId)
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                var messages = snapshot.data!.docs;

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    var message = messages[index];
                                    bool isMe = message['sender'] ==
                                        widget.currentUser.uid;

                                    return Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: isMe ? 54.sp : 6.sp,
                                          right: isMe ? 6.sp : 54.sp,
                                          bottom: 6.sp,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp, vertical: 8.sp),
                                        decoration: BoxDecoration(
                                            color: isMe
                                                ? primaryColor
                                                : primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              16.sp,
                                            )),
                                        child: Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message['text'],
                                              style: TextStyle(
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 13.sp),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "  ${_formatTimestamp(message['timestamp']).toString()}",
                                                  // End time
                                                  style: TextStyle(
                                                      color: isMe
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 10.sp),
                                                ),
                                                if (isMe) ...[
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(
                                                    Icons.done_all,
                                                    size: 12.sp,
                                                    color: message['seen']
                                                        ? Colors.blue
                                                        : Colors.white70,
                                                  )
                                                ]
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                // ListView.builder(
                                //   reverse: true,
                                //   itemCount: messages.length,
                                //   itemBuilder: (context, index) {
                                //     var message = messages[index];
                                //     bool isMe = message['sender'] == widget.currentUser.uid;
                                //
                                //     return Align(
                                //       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                //       child: Bubble(
                                //         margin: BubbleEdges.only(
                                //           left: isMe ? 54.sp : 6.sp,
                                //           right: isMe ? 6.sp : 54.sp,
                                //           bottom: 6.sp,
                                //         ),
                                //         padding: BubbleEdges.symmetric(horizontal: 12.sp, vertical: 8.sp),
                                //         nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
                                //         color: isMe ? primaryColor : primaryColor.withOpacity(0.2),
                                //         child: Column(
                                //           crossAxisAlignment:
                                //           isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                //           children: [
                                //             Text(
                                //               message['text'],
                                //               style: TextStyle(
                                //                 color: isMe ? Colors.white : Colors.black,
                                //                 fontSize: 13.sp,
                                //               ),
                                //             ),
                                //             Row(
                                //               mainAxisSize: MainAxisSize.min,
                                //               children: [
                                //                 Text(
                                //                   "  ${_formatTimestamp(message['timestamp']).toString()}",
                                //                   style: TextStyle(
                                //                     color: isMe ? Colors.white : Colors.black,
                                //                     fontSize: 10.sp,
                                //                   ),
                                //                 ),
                                //                 if (isMe) ...[
                                //                   const SizedBox(width: 4),
                                //                   Icon(
                                //                     Icons.done_all,
                                //                     size: 12.sp,
                                //                     color: message['seen'] ? Colors.blue : Colors.white70,
                                //                   )
                                //                 ]
                                //               ],
                                //             )
                                //           ],
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // );
                              },
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(8.sp),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                width: MediaQuery.of(context).size.width,
                                height: 55.sp,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30.sp),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.sp, vertical: 10.sp),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(30.sp),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => UserChatScreen(
                                          //
                                          //     ),
                                          //   ),
                                          // );

                                          // setState(() {
                                          //   _showEmoji = !_showEmoji;
                                          //   if (_showEmoji) {
                                          //     FocusScope.of(context).unfocus();
                                          //   }
                                          // });
                                        },
                                        icon:  Icon(Icons.attach_file,
                                            color:primaryColor
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          onTap: () {
                                            // if (_showEmoji) {
                                            //   setState(() {
                                            //     _showEmoji = false;
                                            //   });
                                            // }
                                          },
                                          controller: messageController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            hintText: "Type a message",
                                            filled: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              borderSide: BorderSide.none,
                                            ),
                                            fillColor:
                                                Theme.of(context).cardColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      IconButton(
                                        onPressed:
                                             _sendMessage ,
                                        icon: Icon(
                                          Icons.send,
                                          color:primaryColor
                                             ,
                                        ),
                                      )
                                    ],
                                  ),

                                  // Row(children: [
                                  //   Flexible(
                                  //       child: TextFormField(
                                  //     controller: messageController,
                                  //     style:
                                  //         const TextStyle(color: Colors.white),
                                  //     decoration: InputDecoration(
                                  //       hintText: "Send a message...",
                                  //       hintStyle: TextStyle(
                                  //           color: Colors.white,
                                  //           fontSize: 14.sp),
                                  //       border: InputBorder.none,
                                  //     ),
                                  //   )),
                                  //   const SizedBox(
                                  //     width: 12,
                                  //   ),
                                  //   GestureDetector(
                                  //     onTap: _openFilePicker,
                                  //     child: Container(
                                  //       height: 40.sp,
                                  //       width: 40.sp,
                                  //       decoration: BoxDecoration(
                                  //         color: primaryColor,
                                  //         borderRadius:
                                  //             BorderRadius.circular(30.sp),
                                  //       ),
                                  //       child: const Center(
                                  //         child: Icon(
                                  //           Icons.attach_file,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   SizedBox(
                                  //     width: 12.sp,
                                  //   ),
                                  //   GestureDetector(
                                  //     onTap: () async {
                                  //       // final message = messageController.text;
                                  //       // if (messageController.text.isNotEmpty) {
                                  //       //   setState(() {
                                  //       //     messageController.clear();
                                  //       //   });
                                  //       // }
                                  //
                                  //       _sendMessage();
                                  //     },
                                  //     child: Container(
                                  //       height: 40.sp,
                                  //       width: 40.sp,
                                  //       decoration: BoxDecoration(
                                  //         color: primaryColor,
                                  //         borderRadius:
                                  //             BorderRadius.circular(30.sp),
                                  //       ),
                                  //       child: const Center(
                                  //           child: Icon(
                                  //         Icons.send_sharp,
                                  //         color: Colors.white,
                                  //       )),
                                  //     ),
                                  //   )
                                  // ]
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  // const _BottomInputField(),
                ],
              ),
            ),
          ],
        ));
  }

  CustomClipper<Path>? get clipperOnType {
    return null;
  }
}

import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/baseurl/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../StreamChat/UserChatScreen/user_chat_screen.dart';
import '../../StudentTeacherUi/Chat/chat_screen_user.dart';
import '../../Utils/app_colors.dart';
import '../StudentProfile/student_profile.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';




class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<StudentListScreen> {
  late final StreamChatClient client;
  bool isLoading = true;
  List<dynamic> bookingList = [];

  @override
  void initState() {
    super.initState();
    _initChat();
    hitBookingList();
  }
  Future<void> _initChat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cureentUserId = prefs.getString('id');
    client = StreamChatClient(
      '7ay3vn4gdvqn', // 🔑 API Key
      logLevel: Level.INFO,
    );

    /// ✅ devToken for testing
    await client.connectUser(
      User(id: cureentUserId.toString(), extraData: {
        'name': 'Teacher',
      }),
      '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMjYifQ.SOPp70DTU_DzUdHZiEI4pqdcl5qO4YBGunQLhQv7REs''',
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> hitBookingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(studentListBooking),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('bookings')) {
        setState(() {
          bookingList = responseData['bookings'];
          print('List :-  $bookingList');
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: bookingList.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                return AppointmentCard(booking: bookingList[index], client: client,);
              },
            ),
    );
  }
}


class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final StreamChatClient client;

  const AppointmentCard(
      {super.key, required this.booking, required this.client});

  // Future<void> _startChat(BuildContext context) async {
  //   try {
  //     final teacherId = booking['teacher']['id']?.toString();
  //     if (teacherId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Teacher ID not found')),
  //       );
  //       return;
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Starting chat...')),
  //     );
  //
  //     final channel = client.channel(
  //       'messaging',
  //       id: '${client.state.currentUser!.id}_$teacherId',
  //       extraData: {
  //         'members': [
  //           client.state.currentUser!.id,
  //           teacherId,
  //         ],
  //         'name': 'Chat with ${booking['teacher']['name']}',
  //       },
  //     );
  //
  //     await channel.watch();
  //
  //     // Show chat in a modal bottom sheet
  //     showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       builder: (context) => DraggableScrollableSheet(
  //         initialChildSize: 0.9,
  //         minChildSize: 0.5,
  //         maxChildSize: 0.95,
  //         builder: (context, scrollController) => Container(
  //           decoration: BoxDecoration(
  //             color: primaryColor,
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: StreamChannel(
  //             channel: channel,
  //             child: ChannelPage(scrollController: scrollController),
  //           ),
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to start chat: $e')),
  //     );
  //   }
  // }


  // Future<void> startChatWithNewUser(BuildContext context) async {
  //   final client = StreamChat.of(context).client;
  //   final currentUserId = client.state.currentUser?.id ?? "";
  //
  //   const newUserId = "ak_f28d9dd9-092d-42cb-be99-affe75ae11a9"; // 👤 jisko msg bhejna hai
  //
  //   final channel = client.channel(
  //     'messaging',
  //     extraData: {
  //       'members': ['flutter7', newUserId],
  //     },
  //   );
  //
  //   await channel.watch();
  //
  //   await channel.sendMessage(
  //     Message(text: "Hello $newUserId 👋, welcome to chat!"),
  //   );
  //
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => StreamChannel(
  //           channel: channel,
  //           child: const ChannelPage(),
  //         ),
  //       ),
  //     );
  //
  // }


  // Future<void> _startNewChat(BuildContext context) async {
  //   final currentUserId = client.state.currentUser?.id ?? "";
  //   const newUserId = "ak_f28d9dd9-092d-42cb-be99-affe75ae11a9"; // 👤 jisko msg bhejna hai
  //
  //   final channel = client.channel(
  //     'messaging',
  //     extraData: {
  //       'members': ['flutter7', newUserId],
  //     },
  //   );
  //
  //   await channel.watch();
  //
  //   await channel.sendMessage(
  //     Message(text: "Hello ${'Ravikant saini'} 👋, welcome to chat!"),
  //   );
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => StreamChat(
  //         client: client,
  //         child: StreamChannel(
  //           channel: channel,
  //           child: const NewChatScreen(),
  //         ),
  //       ),
  //     ),
  //   );
  // }


  Future<void> _startNewChat(BuildContext context, String newUserId, String userName,String currentUserId) async {
    // final currentUserId = client.state.currentUser?.id ?? "";

    print('NewUserId $newUserId');
    print('User Name $userName');

    try {
      // 1. Pehle check karo user exist karta hai ya nahi
      await client.queryUsers(
        filter: Filter.equal('id', newUserId),
      ).then((response) async {
        if (response.users.isEmpty) {
          // 2. User nahi mila → abhi create kar do
          await client.updateUsers([
            User(id: newUserId, extraData: {
              'name': userName, // 👤 user ka naam
            })
          ]);
        }
      });

      // 3. Ab channel banao dono members ke sath
      final channel = client.channel(
        'messaging',
        extraData: {
          'members': [currentUserId, newUserId],
        },
      );

      await channel.watch();

      // 4. Agar fresh user hai to ek welcome message bhej do
      await channel.sendMessage(
        Message(text: "Hello $userName 👋, welcome to chat!"),
      );

      // 5. Navigate to Chat Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StreamChat(
                client: client,
                child: StreamChannel(
                  channel: channel,
                  child:  NewChatScreen(client: client,channel: channel,),
                ),
              ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error while starting chat: $e");
    }
  }
  Future<void> loadUsers(BuildContext context,String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cureentUserId = prefs.getString('id');
    try {
      final response = await client.queryUsers(
        filter: Filter.exists('id'),
        sort: [SortOption.asc('name')],
      );

      final allUsers = response.users;

      // yaha id match check karenge
      final matchedUser =
      allUsers.firstWhere((u) => u.id == id, orElse: () => User(id: ""));

      if (matchedUser.id.isNotEmpty) {
        // ✅ match mil gaya → direct chat open
        _startNewChat(context, booking['user']['id'].toString(),
            booking['user']['name'].toString(),cureentUserId!);
      } else {

      }
    } catch (e) {
      debugPrint("❌ Error loading users: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                      booking['user']['picture_data'].toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/teacher_user.jpg',
                            // Ensure this image exists in your assets folder
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['user']['name'].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '',
                            // widget.booking['user']['category']['name'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${booking['user']['district'].toString()} ${'/'} ${booking['user']['state'].toString()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            booking['user']['bio'].toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(booking['slot']['date'].toString()),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(booking['slot']['start_time'].toString()),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(booking['unique_id'].toString()),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Ensures button takes up remaining space
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(100, 40), // Set reasonable size
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentProfileScreen(
                                id: booking['user']['id'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Prevents unnecessary stretching
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Aligns content properly
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                              size: 20,
                            ),
                            // Your chosen icon
                            SizedBox(width: 8),
                            // Adds spacing between icon and text
                            Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          loadUsers(context, booking['user']['id'].toString());
                        },

                        // _startNewChat(context, booking['teacher']['id'].toString(),
                        //         booking['teacher']['name'].toString()),
                        // onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         NewChatPage(
                        //
                        //         ),
                        //   ),
                        // );
                        //   // startChatWithNewUser(context);
                        // },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade500, Colors.green.shade200],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              "Chat",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 15),
                    SizedBox(width: 3),
                    Text(
                      '4.7',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        ,
      )
      ,
    );
  }
}


// class AppointmentCard extends StatefulWidget {
//   final Map<String, dynamic> booking;
//   final StreamChatClient client;
//
//   AppointmentCard({required this.booking, required this.client});
//
//
//
//   Future<void> _startNewChat(BuildContext context, String newUserId, String userName,String currentUserId) async {
//     // final currentUserId = client.state.currentUser?.id ?? "";
//
//     print('NewUserId $newUserId');
//     print('User Name $userName');
//
//     try {
//       // 1. Pehle check karo user exist karta hai ya nahi
//       await client.queryUsers(
//         filter: Filter.equal('id', newUserId),
//       ).then((response) async {
//         if (response.users.isEmpty) {
//           // 2. User nahi mila → abhi create kar do
//           await client.updateUsers([
//             User(id: newUserId, extraData: {
//               'name': userName, // 👤 user ka naam
//             })
//           ]);
//         }
//       });
//
//       // 3. Ab channel banao dono members ke sath
//       final channel = client.channel(
//         'messaging',
//         extraData: {
//           'members': [currentUserId, newUserId],
//         },
//       );
//
//       await channel.watch();
//
//       // 4. Agar fresh user hai to ek welcome message bhej do
//       await channel.sendMessage(
//         Message(text: "Hello $userName 👋, welcome to chat!"),
//       );
//
//       // 5. Navigate to Chat Screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               StreamChat(
//                 client: client,
//                 child: StreamChannel(
//                   channel: channel,
//                   child: const NewChatScreen(),
//                 ),
//               ),
//         ),
//       );
//     } catch (e) {
//       debugPrint("❌ Error while starting chat: $e");
//     }
//   }
//   Future<void> loadUsers(BuildContext context,String id) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? cureentUserId = prefs.getString('id');
//     try {
//       final response = await client.queryUsers(
//         filter: Filter.exists('id'),
//         sort: [SortOption.asc('name')],
//       );
//
//       final allUsers = response.users;
//
//       // yaha id match check karenge
//       final matchedUser =
//       allUsers.firstWhere((u) => u.id == id, orElse: () => User(id: ""));
//
//       if (matchedUser.id.isNotEmpty) {
//         // ✅ match mil gaya → direct chat open
//         _startNewChat(context, booking['teacher']['id'].toString(),
//             booking['teacher']['name'].toString(),cureentUserId!);
//       } else {
//
//       }
//     } catch (e) {
//       debugPrint("❌ Error loading users: $e");
//     }
//   }
//
//   @override
//   State<AppointmentCard> createState() => _AppointmentCardState();
// }
//
// class _AppointmentCardState extends State<AppointmentCard> {
//   bool isCompleted = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       color: Colors.green.shade100,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         widget.booking['user']['picture_data'].toString(),
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Image.asset(
//                             'assets/teacher_user.jpg',
//                             // Ensure this image exists in your assets folder
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     ),
//
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.booking['user']['name'].toString(),
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             '',
//                             // widget.booking['user']['category']['name'].toString(),
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             '${widget.booking['user']['district'].toString()} ${'/'} ${widget.booking['user']['state'].toString()}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             widget.booking['user']['bio'].toString() ?? '',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w400,
//                               color: Colors.blueGrey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 5),
//                 Divider(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today,
//                           size: 16,
//                           color: Colors.grey,
//                         ),
//                         SizedBox(width: 5),
//                         Text(widget.booking['slot']['date'].toString()),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Icon(Icons.access_time, size: 16, color: Colors.grey),
//                         SizedBox(width: 5),
//                         Text(widget.booking['slot']['start_time'].toString()),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.confirmation_number,
//                           size: 16,
//                           color: Colors.grey,
//                         ),
//                         SizedBox(width: 5),
//                         Text(widget.booking['unique_id'].toString()),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 5),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   // Align items properly
//                   children: [
//                     Expanded(
//                       // Ensures button takes up remaining space
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           minimumSize: Size(100, 40), // Set reasonable size
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => StudentProfileScreen(
//                                 id: widget.booking['user']['id'],
//                               ),
//                             ),
//                           );
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           // Prevents unnecessary stretching
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           // Aligns content properly
//                           children: [
//                             Icon(
//                               Icons.remove_red_eye,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             // Your chosen icon
//                             SizedBox(width: 8),
//                             // Adds spacing between icon and text
//                             Text(
//                               "View",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16.sp,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 5),
//
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           loadUsers(context, booking['teacher']['id'].toString());
//                         },
//
//                         // _startNewChat(context, booking['teacher']['id'].toString(),
//                         //         booking['teacher']['name'].toString()),
//                         // onTap: () {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) =>
//                         //         NewChatPage(
//                         //
//                         //         ),
//                         //   ),
//                         // );
//                         //   // startChatWithNewUser(context);
//                         // },
//                         borderRadius: BorderRadius.circular(12),
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Colors.green.shade500, Colors.green.shade200],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.green, width: 1),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               "Chat",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Expanded(
//                     //   child: StreamBuilder<QuerySnapshot>(
//                     //     stream: FirebaseFirestore.instance
//                     //         .collection('users')
//                     //         .snapshots(),
//                     //     builder: (context, snapshot) {
//                     //       if (!snapshot.hasData) {
//                     //         return Center(child: CircularProgressIndicator());
//                     //       }
//                     //
//                     //       var users = snapshot.data!.docs.where((user) {
//                     //         return user['email'] ==
//                     //             widget.booking['user']['email']
//                     //                 .toString(); // Filter users by email
//                     //       }).toList();
//                     //
//                     //       if (users.isEmpty) {
//                     //         return GestureDetector(
//                     //           onTap: () {
//                     //             showCustomDialog(context);
//                     //           },
//                     //           child: Card(
//                     //             color: primaryColor,
//                     //             shape: RoundedRectangleBorder(
//                     //               borderRadius: BorderRadius.circular(10),
//                     //             ),
//                     //             child: Padding(
//                     //               padding: EdgeInsets.all(10),
//                     //               child: Row(
//                     //                 children: [
//                     //                   Icon(
//                     //                     Icons.chat,
//                     //                     size: 18,
//                     //                     color: Colors.white,
//                     //                   ),
//                     //                   SizedBox(width: 8),
//                     //                   Text(
//                     //                     "Chat ${widget.booking['user']['email'].toString()}",
//                     //                     style: TextStyle(
//                     //                       color: Colors.white,
//                     //                       fontSize: 5.sp,
//                     //                     ),
//                     //                   ),
//                     //                 ],
//                     //               ),
//                     //             ),
//                     //           ),
//                     //         );
//                     //       }
//                     //
//                     //       return ListView.builder(
//                     //         shrinkWrap: true,
//                     //         // Important for nested lists
//                     //         physics: NeverScrollableScrollPhysics(),
//                     //         // Prevents scrolling conflict
//                     //         itemCount: 1,
//                     //         itemBuilder: (context, index) {
//                     //           var user = users[0];
//                     //           return GestureDetector(
//                     //             onTap: () {
//                     //               final currentUser =
//                     //                   FirebaseAuth.instance.currentUser;
//                     //               if (currentUser != null) {
//                     //                 Navigator.push(
//                     //                   context,
//                     //                   MaterialPageRoute(
//                     //                     builder: (context) => ChatUserScreen(
//                     //                       chatId: '',
//                     //                       userName: '',
//                     //                       image: '',
//                     //                       currentUser: currentUser,
//                     //                       chatUser: user,
//                     //                     ),
//                     //                   ),
//                     //                 );
//                     //               }
//                     //             },
//                     //             child: Card(
//                     //               color: primaryColor,
//                     //               shape: RoundedRectangleBorder(
//                     //                 borderRadius: BorderRadius.circular(10),
//                     //               ),
//                     //               child: Padding(
//                     //                 padding: EdgeInsets.all(10),
//                     //                 child: Row(
//                     //                   children: [
//                     //                     Icon(
//                     //                       Icons.chat,
//                     //                       size: 18,
//                     //                       color: Colors.white,
//                     //                     ),
//                     //                     SizedBox(width: 8),
//                     //                     Text(
//                     //                       "Chat",
//                     //                       style: TextStyle(color: Colors.white),
//                     //                     ),
//                     //                   ],
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //           );
//                     //         },
//                     //       );
//                     //     },
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 if (widget.booking['video_link'] != null) Divider(),
//                 if (widget.booking['video_link'] != null)
//                   /// Mark as Complete Checkbox
//                   SizedBox(
//                     height: 20.sp,
//                     child: Row(
//                       children: [
//                         Checkbox(
//                           value: isCompleted,
//                           onChanged: (bool? value) {
//                             setState(() {
//                               isCompleted = value ?? false;
//                             });
//                           },
//                           activeColor: Colors.green,
//                         ),
//                         Text(
//                           "Mark as Complete",
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.bold,
//                             color: isCompleted ? Colors.green : Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void showCustomDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),
//                 SizedBox(height: 10),
//                 Text(
//                   "Student  Not Found",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 // Text(
//                 //   "No teachers are available for chat at the moment. Please try again later.",
//                 //   textAlign: TextAlign.center,
//                 //   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                 // ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Text("OK", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../StreamChat/UserChatScreen/user_chat_screen.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';


class HistoryAppointmentScreen extends StatefulWidget {
  const HistoryAppointmentScreen({super.key});

  @override
  State<HistoryAppointmentScreen> createState() =>
      _HistoryAppointmentScreenState();
}

class _HistoryAppointmentScreenState extends State<HistoryAppointmentScreen> {
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
        'name': 'Flutter User',
      }),
      '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTAifQ.Ogjig8bW7ShsIu8MhqMGDFkdN2oUZ2pmkE4clquVsE4''',
    );

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _initializeStreamChat() async {
    // Initialize StreamChatClient
    client = StreamChatClient(
      '7ay3vn4gdvqn', // Replace with your Stream API key
      logLevel: Level.INFO,
    );

    await client?.connectUser(
      User(id: 'flutter7', extraData: {
        'name': 'Flutter User',
      }),
      // is user ka token (server se generate hota hai)
      '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZmx1dHRlcjcifQ.3VfXnMHV28DFYfQsJld3zjaLiqr1rwpE-srCErqjeL0''',
    );

    // // Fetch user ID and Stream token
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? userId = prefs.getString('user_id'); // Assuming user_id is stored during login
    // final String? streamToken = await _fetchStreamToken(userId);
    //
    // if (userId != null && streamToken != null) {
    //   try {
    //
    //     await client!.connectUser(
    //       User(id: 'flutter7', extraData: {
    //         'name': 'Flutter User',
    //       }),
    //       // is user ka token (server se generate hota hai)
    //       '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZmx1dHRlcjcifQ.3VfXnMHV28DFYfQsJld3zjaLiqr1rwpE-srCErqjeL0''',
    //     );
    //     // await client!.connectUser(
    //     //   User(
    //     //     id: userId,
    //     //     extraData: {'name': 'User Name'}, // Adjust name dynamically if available
    //     //   ),
    //     //   streamToken,
    //     // );
    //     setState(() {}); // Update UI to reflect client initialization
    //   } catch (e) {
    //     print('Error connecting StreamChat user: $e');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to initialize chat: $e')),
    //     );
    //   }
    // } else {
    //   print('User ID or Stream token not found');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('User ID or Stream token not found')),
    //   );
    // }
  }

  // Function to fetch Stream token from backend
  Future<String?> _fetchStreamToken(String? userId) async {
    if (userId == null) return null;
    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_ENDPOINT'),
        // Replace with your backend endpoint
        body: json.encode({'user_id': userId}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['stream_token'];
      }
    } catch (e) {
      print('Error fetching Stream token: $e');
    }
    return null;
  }

  Future<void> hitBookingList() async {
    setState(() => isLoading = true); // ✅ start loading

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(getBooking),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('bookings')) {
          setState(() {
            // bookingList = responseData['bookings'];
            bookingList = (responseData['bookings'] ?? []) as List<dynamic>;

            print('List :- $bookingList');
          });
        } else {
          throw Exception('Invalid API response: Missing "bookings" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookings: $e')),
      );
    }finally {
      if (mounted) setState(() => isLoading = false); // ✅ stop loading
    }
  }


  // ✅ No Data Premium Card
  Widget _noDataCard() {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_off, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 12),
              const Text(
                "No Appointment Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Appointment list is currently empty.",
                style: TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // ✅ optional retry button
              InkWell(
                onTap: hitBookingList,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 18, color: Color(0xFF1E3C72)),
                      SizedBox(width: 8),
                      Text(
                        "Retry",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3C72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // Wrap the scaffold in StreamChat if client is initialized
    return StreamChat(
      client: client,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : bookingList.isEmpty
            ? _noDataCard() // ✅ empty state card
            : ListView.builder(
          padding: const EdgeInsets.all(5.0),
          itemCount: bookingList.length,
          itemBuilder: (context, index) {


            return AppointmentCard(
              booking: bookingList[index],
              client: client,
            );
          },
        ),

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
                  child:  NewChatScreen(client: client ,channel: channel,),
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
        _startNewChat(context, booking['teacher']['id'].toString(),
            booking['teacher']['name'].toString(),cureentUserId!);
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
                booking['teacher']['picture_data'].toString(),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/teacher_user.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['teacher']['name'].toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    booking['teacher']['qualification'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    booking['teacher']['language'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    booking['teacher']['bio']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:

                    const TextStyle(
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
        const SizedBox(height: 10),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(booking['slot']['date'].toString()),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(booking['slot']['start_time'].toString()),
              ],
            ),
            Row(
              children: [
                const Icon(
                    Icons.confirmation_number, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(booking['slot']['start_time'].toString()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
        Expanded(
        child: booking['status_text']?.toString() == "Pending"
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "Pending",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        )
            : booking['status_text']?.toString() == "Cancelled"
            ? InkWell(
          onTap: () {

            },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Cancelled",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        )
            : InkWell(
          onTap: () {
            // Implement complete functionality here
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Complete",
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
      const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    loadUsers(context, booking['teacher']['id'].toString());
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





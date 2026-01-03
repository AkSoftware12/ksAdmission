import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class NewChatScreen extends StatelessWidget {
  final StreamChatClient client;
  final Channel channel;

  const NewChatScreen({
    super.key,
    required this.client,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: client,
      child: StreamChannel(
        channel: channel,
        child: const Scaffold(
          appBar: StreamChannelHeader(),
          body: Column(
            children: [
              // Expanded(child: StreamMessageListView()),
              // StreamMessageInput(),
            ],
          ),
        ),
      ),
    );
  }
}



// class ResponsiveChat extends StatelessWidget {
//   const ResponsiveChat({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, sizingInformation) {
//         if (sizingInformation.isDesktop || sizingInformation.isTablet) {
//           return const SplitView();
//         }
//         return ChannelListPage(
//           onTap: (c) => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => StreamChannel(
//                 channel: c,
//                 child: ChannelPage(
//                   onBackPressed: (context) {
//                     Navigator.of(context, rootNavigator: true).pop();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class SplitView extends StatefulWidget {
//   const SplitView({super.key});
//
//   @override
//   _SplitViewState createState() => _SplitViewState();
// }
//
// class _SplitViewState extends State<SplitView> {
//   Channel? selectedChannel;
//
//   @override
//   Widget build(BuildContext context) {
//     return Flex(
//       direction: Axis.horizontal,
//       children: <Widget>[
//         Flexible(
//           child: ChannelListPage(
//             onTap: (channel) {
//               setState(() {
//                 selectedChannel = channel;
//               });
//             },
//             selectedChannel: selectedChannel,
//           ),
//         ),
//         Flexible(
//           flex: 2,
//           child: ClipPath(
//             child: Scaffold(
//               body: selectedChannel != null
//                   ? StreamChannel(
//                 key: ValueKey(selectedChannel!.cid),
//                 channel: selectedChannel!,
//                 child: const ChannelPage(showBackButton: false),
//               )
//                   : Center(
//                 child: Text(
//                   'Pick a channel to show the messages 💬',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class ChannelListPage extends StatefulWidget {
//   const ChannelListPage({
//     super.key,
//     this.onTap,
//     this.selectedChannel,
//   });
//
//   final void Function(Channel)? onTap;
//   final Channel? selectedChannel;
//
//   @override
//   State<ChannelListPage> createState() => _ChannelListPageState();
// }
//
// class _ChannelListPageState extends State<ChannelListPage> {
//   late final _listController = StreamChannelListController(
//     client: StreamChat.of(context).client,
//     filter: Filter.in_(
//       'members',
//       [StreamChat.of(context).currentUser!.id],
//     ),
//     channelStateSort: const [SortOption.desc('last_message_at')],
//     limit: 20,
//   );
//
//   /// ✅ Ye function new user ke saath chat start karega
//   Future<void> startChatWithNewUser() async {
//     final client = StreamChat.of(context).client;
//     final currentUserId = client.state.currentUser?.id ?? "";
//
//     const newUserId = "ak_f28d9dd9-092d-42cb-be99-affe75ae11a9"; // 👤 jisko msg bhejna hai
//
//     final channel = client.channel(
//       'messaging',
//       extraData: {
//         'members': ['flutter7', newUserId],
//       },
//     );
//
//     await channel.watch();
//
//     await channel.sendMessage(
//       Message(text: "Hello $newUserId 👋, welcome to chat!"),
//     );
//
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => StreamChannel(
//             channel: channel,
//             child: const ChannelPage(),
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       title: const Text("Chats"),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.add_comment),
//           onPressed: startChatWithNewUser, // 👈 yaha se naya chat start hoga
//         ),
//       ],
//     ),
//     body: StreamChannelListView(
//       onChannelTap: widget.onTap,
//       controller: _listController,
//       itemBuilder: (context, channels, index, defaultWidget) {
//         return defaultWidget.copyWith(
//           selected: channels[index] == widget.selectedChannel,
//         );
//       },
//     ),
//   );
// }

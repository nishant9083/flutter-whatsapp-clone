import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/call/controller/call_controller.dart';
import 'package:whatsapp_ui/features/call/screens/call_pickup_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp_ui/models/user_model.dart';
import 'package:whatsapp_ui/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          isGroupChat,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          // backgroundColor: appBarColor,
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[500]!,
                              highlightColor: Colors.grey[300]!,
                              child: const Text(''),
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[400]!,
                              highlightColor: Colors.grey[100]!,
                              child: const Text(''),
                            )
                          ],
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/user-profile',
                          arguments: snapshot.data,
                        );
                      },
                      child: Column(
                        children: [
                          Text(name),
                          Text(
                            snapshot.data!.isOnline ? 'online' : 'offline',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                recieverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
            BottomChatField(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ],
        ),
      ),
    );
  }
}

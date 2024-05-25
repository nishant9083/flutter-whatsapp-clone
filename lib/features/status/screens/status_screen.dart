import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';

import 'package:whatsapp_ui/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/status-screen';
  final Status status;
  const StatusScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  String formatChatTime(DateTime timeSent) {
    final now = DateTime.now();
    final difference = now.difference(timeSent);

    if (now.day == timeSent.day) {
      return DateFormat('hh:mm a').format(timeSent);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, hh:mm a').format(timeSent); // EEEE gives full name of the weekday
    } else {
      return DateFormat('d/M/yy').format(timeSent);
    }
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(StoryItem.pageImage(
        url: widget.status.photoUrl[i],
        controller: controller,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : Stack(
            fit: StackFit.expand,
            children: [
              StoryView(
                storyItems: storyItems,
                controller: controller,
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                },
                    onComplete: () {
            Navigator.pop(context);
                    },
              ),
              Positioned(
                top: 40,
                left: 10,
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.status.profilePic),
                  ),
                  title: Text(widget.status.username, style: const TextStyle(color: Colors.white),),
                  subtitle: Text(formatChatTime(widget.status.createdAt, ), style: const TextStyle(color: Colors.white)),
                ),
              ),
            ]
          ),
    );
  }
}

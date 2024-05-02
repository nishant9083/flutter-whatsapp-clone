import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/features/chat/widgets/audio_player.dart';
import 'package:whatsapp_ui/features/chat/widgets/video_player_item.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                  padding: const EdgeInsets.all(0),
                  // constraints: const BoxConstraints(
                  //   minWidth: 100,
                  // ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.play(UrlSource(message));
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                );
              })
            : type == MessageEnum.video
                ? VideoPlayerItem(
                    videoUrl: message,
                  )
                : type == MessageEnum.gif
                    ? CachedNetworkImage(
                        imageUrl: message,
                      )
                    : GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.black,
                                    ),
                                  ),
                                  InteractiveViewer(
                                    boundaryMargin: const EdgeInsets.all(20.0),
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    panEnabled: false,

                                    child: Center(
                                      child: CachedNetworkImage(
                                        imageUrl: message,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: message,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
  }
}

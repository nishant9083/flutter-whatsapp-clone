import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/message_reply_preview.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.recieverUserId,
            widget.isGroupChat,
          );
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }


  void captureImage() async {
    final File? image = await ImagePicker().pickImage(source: ImageSource.camera) as File;
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.recieverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectDocument() async {
    File? document = await pickDocument(context);
    if (document != null) {
      sendFileMessage(document, MessageEnum.document);
    }
  }

  void selectGIF() async {
    // final gif = await pickGIF(context);
    // if (gif != null) {
    //   ref.read(chatControllerProvider).sendGIFMessage(
    //         context,
    //         gif.url,
    //         widget.recieverUserId,
    //         widget.isGroupChat,
    //       );
    // }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: TextFormField(
                  focusNode: focusNode,
                  controller: _messageController,
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    } else {
                      setState(() {
                        isShowSendButton = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark? mobileChatBoxColor: lightMobileChatBoxColor,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: toggleEmojiKeyboardContainer,
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: selectGIF,
                              icon: const Icon(
                                Icons.gif,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffixIcon: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: captureImage,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (builder) => bottomSheet());
                            },
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Type a message!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 24,
                child: GestureDetector(
                  child: Icon(
                    isShowSendButton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                  onTap: sendTextMessage,
                ),
              ),
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onBackspacePressed: () {
                    _messageController.text = _messageController.text
                        .substring(0, _messageController.text.length - 1);
                  },
                  config: const Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    swapCategoryAndBottomBar:  false,
                    skinToneConfig: SkinToneConfig(),
                    categoryViewConfig: CategoryViewConfig(),
                    bottomActionBarConfig: BottomActionBarConfig(),
                    searchViewConfig: SearchViewConfig(),
                  ),
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });

                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  }),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bottomSheetIcons(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  SizedBox(width: 40),
                  bottomSheetIcons(Icons.video_collection, Colors.pink, "Video"),
                  SizedBox(width: 40),
                  bottomSheetIcons(Icons.insert_photo, Colors.purple, "Gallery")
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bottomSheetIcons(Icons.headset, Colors.orange, "Audio"),
                  SizedBox(width: 40),
                  bottomSheetIcons(Icons.location_pin, Colors.teal, "Location"),
                  SizedBox(width: 40),
                  bottomSheetIcons(Icons.person, Colors.blue, "Contact")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheetIcons(IconData icon, Color bgColor, String text) {
    return InkWell(
      onTap: () {
        if (text == "Document") {
          selectDocument();
        } else if (text == "Video") {
          selectVideo();
        } else if (text == "Gallery") {
          selectImage();
        } else if (text == "Audio") {
          // sendTextMessage();
        } else if (text == "Location") {
          // pickLocation();
        } else {
          // pickContact();
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: bgColor,
            radius: 30,
            child: Icon(icon, size: 29, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(text, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }
}

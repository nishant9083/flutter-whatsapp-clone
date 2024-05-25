import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/status/controller/status_controller.dart';
import 'package:whatsapp_ui/features/status/screens/status_screen.dart';
import 'package:whatsapp_ui/models/status_model.dart';

import '../widgets/status _number_indicator.dart';
import 'confirm_status_screen.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({Key? key}) : super(key: key);

  Future<XFile?> captureImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    return image;
  }

  String formatChatTime(DateTime timeSent) {
    final now = DateTime.now();
    final difference = now.difference(timeSent);

    if (now.day == timeSent.day) {
      return DateFormat('hh:mm a').format(timeSent);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(timeSent); // EEEE gives full name of the weekday
    } else {
      return DateFormat('d/M/yy').format(timeSent);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<Status>(
            stream: ref.watch(statusControllerProvider).getMyStatus(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const Text('My status'),
                  ),
                  leading: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const CircleAvatar(
                      radius: 30,
                    ),
                  ),
                  subtitle: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const Text('Tap to add status update'),
                  )
                );
              }
              else if(snapshot.data == null || snapshot.data!.photoUrl.isEmpty){
                return ListTile(
                  title: const Text('My status'),
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'
                    ),
                    radius: 30,
                  ),
                  subtitle: const Text('Tap to add status update'),
                  onTap: () async {
                    XFile? image = await captureImage();
                    if(image == null) return;
                    Navigator.pushNamed(
                      context,
                      ConfirmStatusScreen.routeName,
                      arguments: image,
                    );
                  },
                );
              }
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    StatusScreen.routeName,
                    arguments: snapshot.data,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                  child: ListTile(
                    title: const Text(
                      'My Status',
                    ),
                    leading: StatusAvatar(
                      imageUrl: snapshot.data!.profilePic,
                      totalStatuses: snapshot.data!.photoUrl.length,
                    ),
                    subtitle: const Text('Tap to view your status'),
                  ),
                ),
              );

            },
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 18.0, bottom: 10.0),
            child: Text(
              'Recent Updates',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          FutureBuilder<List<Status>>(
            future: ref.read(statusControllerProvider).getStatus(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container( width: 20, height: 15,color: Colors.white),
                        ),
                        leading: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: const CircleAvatar(
                            radius: 30,
                          ),
                        ),
                        subtitle: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child:Container(width: 10, height: 10, color: Colors.white),
                        )
                    );
                  },
                );
              }
              else if(snapshot.data!.isEmpty){
                return const Center(
                  child: Text('No status available'),
                );
              }
              return SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var statusData = snapshot.data![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              StatusScreen.routeName,
                              arguments: statusData,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(
                                statusData.username,
                              ),
                              leading: StatusAvatar(
                                imageUrl: statusData.profilePic,
                                totalStatuses: statusData.photoUrl.length,
                              ),
                              subtitle: Text(
                                formatChatTime(statusData.createdAt),
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: dividerColor, indent: 85),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

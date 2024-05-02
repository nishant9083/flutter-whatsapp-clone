import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'dart:io';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../../models/user_model.dart';
import '../../auth/controller/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  static const String routeName = '/profile-page';
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  File? image;
  Future<String> getUserId(WidgetRef ref) async {
    UserModel? user = await ref.read(authControllerProvider).getUserData();
    return user?.uid ?? '';
  }

  Future<File?> selectImage() async {
    File? img = await pickImageFromGallery(context);
    return img;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  // Get the screen height
                  // double screenHeight = MediaQuery.of(context).size.height;
                  // Get the keyboard height
                  double keyboardHeight =
                      MediaQuery.of(context).viewInsets.bottom;
                  // Calculate the available height
                  double availableHeight = 180 + keyboardHeight;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: availableHeight,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: myController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          CustomButton(
                              text: 'Save',
                              onPressed: () {
                                ref
                                    .read(authControllerProvider)
                                    .updateUserDataToFirebase(
                                        context, myController.text, image);
                                Navigator.pop(context);
                              })
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile picture and name
            FutureBuilder<String>(
              future: getUserId(ref),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Text('Error: ${snapshot.error ?? 'No data'}');
                } else {
                  return StreamBuilder<UserModel>(
                    stream: ref
                        .read(authControllerProvider)
                        .userDataById(snapshot.data ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        myController.text = snapshot.data!.name;
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 64.0,
                                    backgroundImage:
                                        NetworkImage(snapshot.data!.profilePic),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -0.2,
                                    child: CircleAvatar(
                                      backgroundColor: messageColor,
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.photo_camera_outlined),
                                        color: Colors.blue,
                                        onPressed: () async {
                                          // Handle edit profile action
                                          File? image = await selectImage();

                                          if (image != null) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Scaffold(
                                                  appBar: AppBar(
                                                    title: Text('Profile'),
                                                    actions: [
                                                      IconButton(
                                                        icon: Icon(Icons.check),
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                  authControllerProvider)
                                                              .updateUserDataToFirebase(
                                                                  context,
                                                                  snapshot.data!
                                                                      .name,
                                                                  image);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  body: Center(
                                                    child: Image.file(image),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                snapshot.data!.name,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'status',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Handle the case when there is no data
                        return Text('No data');
                      }
                    },
                  );
                }
              },
            ),

            // Divider
            Divider(height: 1.0),
            // Profile options
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                // Handle account option
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy'),
              onTap: () {
                // Handle privacy option
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chats'),
              onTap: () {
                // Handle chats option
              },
            ),
            // Add more options as needed
          ],
        ),
      ),
    );
  }
}

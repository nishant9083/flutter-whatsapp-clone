import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/group/widgets/select_contacts_group.dart';

final searchController = StateProvider<TextEditingController>((ref) => TextEditingController());
class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;
  final isSearchingProvider = StateProvider<bool>((ref) => false);

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
            context,
            groupNameController.text.trim(),
            image!,
            ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ref.watch(isSearchingProvider)
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  ref.read(isSearchingProvider.notifier).state = false;
                  ref.read(searchController.notifier).state.clear();
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              title: TextField(
                  autofocus: true,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: ref.read(searchController),
                  decoration: const InputDecoration(
                    hintText: 'Search contacts',
                  ),
                  ))
          : AppBar(
              title: const Text('Create Group'),
              actions: [
                IconButton(
                  onPressed: () {
                    ref.read(isSearchingProvider.notifier).state =
                        !ref.read(isSearchingProvider);
                  },
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                        ),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(
                          image!,
                        ),
                        radius: 64,
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                      labelText: 'Group Name',
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SelectContactsGroup(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}

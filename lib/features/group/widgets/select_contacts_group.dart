import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contacts/controller/select_contact_controller.dart';

import '../screens/create_group_screen.dart';

final selectedGroupContacts =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
  List<int> selectedContactsIndex = [];
  late VoidCallback _listener;
  final filteredContactsProvider = StateProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(getContactsProvider).when(
            data: (contactList) => contactList
                .where((element) => element['onChatBh'] == true)
                .toList(),
            error: (err, trace) => [],
            loading: () => [],
          ));

  @override
  void initState() {
    super.initState();
    _listener = () {
      if(mounted){
        setState(() {
          if (ref.read(searchController).text.isNotEmpty) {
            var data = ref.watch(getContactsProvider).asData?.value ?? [];
            ref.read(filteredContactsProvider.notifier).state =
                data.where((contact) {
              return contact['name'].toLowerCase().contains(
                      ref.read(searchController).text.toLowerCase()) &&
                  contact['onChatBh'] == true;
            }).toList();
          } else {
            var data = ref.watch(getContactsProvider).asData?.value ?? [];
            ref.read(filteredContactsProvider.notifier).state =
                data.where((contact) => contact['onChatBh'] == true).toList();
          }
        });
      }
    };
        ref.read(searchController).addListener(_listener);
  }



  void selectContact(int index, Map<String, dynamic> contact) {

    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.removeAt(selectedContactsIndex.indexOf(index));
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContacts.notifier)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
          data: (contactList) {
            return Expanded(
              child: ListView.builder(
                  itemCount: ref.watch(filteredContactsProvider).length,
                  itemBuilder: (context, index) {
                    final contact = ref.watch(filteredContactsProvider)[index];
                    return InkWell(
                      onTap: () => selectContact(index, contact),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            contact['name'],
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          leading: contact['profilePic'].isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(contact['profilePic']),
                            radius: 30,
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                            radius: 30,
                                ),
                          trailing: selectedContactsIndex.contains(index)
                              ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.done),
                          )
                              : null,
                          subtitle: Text(
                            contact['phones'][0].number.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          )
                        ),
                      ),
                    );
                  }),
            );
          },
          error: (err, trace) => ErrorScreen(
            error: err.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}

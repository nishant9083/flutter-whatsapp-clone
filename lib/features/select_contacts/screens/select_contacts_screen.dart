import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contacts/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  _SelectContactsScreenState createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends ConsumerState<SelectContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final isSearchingProvider = StateProvider<bool>((ref) => false);
  final filteredContactsProvider = StateProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(getContactsProvider).when(
            data: (contactList) => contactList,
            error: (err, trace) => [],
            loading: () => [],
          ));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void selectContact(WidgetRef ref, Map<String, dynamic> selectedContact,
      BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ref.watch(isSearchingProvider)
          ? AppBar(
              title: TextField(
                autofocus: true,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search contacts',
                  // border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    var data = ref.watch(getContactsProvider).asData?.value??[];
                    ref.read(filteredContactsProvider.notifier).state = data
                        .where((contact) => contact['name']
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  } else {

                    ref.read(filteredContactsProvider.notifier).state =
                        ref.watch(getContactsProvider).asData?.value??[];
                  }
                },
              ),
              leading: IconButton(
                onPressed: () {
                  ref.read(isSearchingProvider.notifier).state =
                      !ref.read(isSearchingProvider);
                  ref.read(filteredContactsProvider.notifier).state =
                      ref.read(getContactsProvider).asData?.value??[];
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(filteredContactsProvider.notifier).state =
                        ref.read(getContactsProvider).asData?.value ?? [];
                    _searchController.clear();
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                ),
              ],
            )
          : AppBar(
              title: const Text('Select contact'),
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) {
              return ListView.builder(
                  itemCount: ref.watch(filteredContactsProvider).length,
                  itemBuilder: (context, index) {
                    final contact = ref.watch(filteredContactsProvider)[index];
                    return InkWell(
                      onTap: () => selectContact(ref, contact, context),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            contact['name'],
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          leading: contact['profilePic'].isEmpty
                              ? const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                                  ),
                                  radius: 30,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(contact['profilePic']),
                                  radius: 30,
                                ),
                          subtitle:contact['phones'].isNotEmpty? Text(
                            contact['phones'][0].number.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ):null,
                        ),
                      ),
                    );
                  });
            },
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

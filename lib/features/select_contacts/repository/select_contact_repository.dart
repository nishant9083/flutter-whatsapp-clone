import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/models/user_model.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Map<String, dynamic>>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    List<Map<String, dynamic>> contactMap = contacts
        .map(
          (contact) => {
            'name': contact.displayName,
            'phones': contact.phones,
            'emails': contact.emails,
            'profilePic': '',
            'onChatBh': false
          },
        )
        .toList();
    for (var contact in contactMap) {
      if(contact['phones'].isEmpty ||
          contact['phones'][0].number.replaceAll(' ', '').length < 10 ||
          contact['phones'][0].number.replaceAll(' ', '').length > 13)continue;
      if (contact['phones'].isNotEmpty) {
        String contactPhoneNum = contact['phones'][0].number.replaceAll(' ', '');
        var userDocument = await firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: contactPhoneNum)
            .get();
        if (userDocument.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDocument.docs[0].data());
          contactMap[contactMap.indexOf(contact)]['profilePic'] = userData.profilePic;
          contactMap[contactMap.indexOf(contact)]['onChatBh'] = true;
        }
      }
    }
    return contactMap;
  }

  void selectContact(Map<String, dynamic> selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact['phones'][0].number.replaceAll(
          ' ',
          '',
        );
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
            },
          );
        }
      }

      if (!isFound) {
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

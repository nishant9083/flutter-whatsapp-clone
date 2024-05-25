import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-profile';
  final UserModel user;
  const UserProfileScreen(this.user, {Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // title: Text(widget.user.name),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: NetworkImage(widget.user.profilePic),
            ),
            const SizedBox(height: 10),
            Text(widget.user.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              )),
            const SizedBox(height: 10),
            Text(widget.user.phoneNumber,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(widget.user.isOnline ? 'Online' : 'Offline',
              style:  TextStyle(
                fontSize: 18.0,
                color: widget.user.isOnline ? Colors.green : Colors.grey[500],
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],

              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuPopup extends StatelessWidget {
  const MenuPopup({
    Key? key,
    required this.menus,
    required this.user,
  }) : super(key: key);

  final List<Map<String, dynamic>> menus;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (value) async {
          if (value == "Logout") {
            FirebaseAuth.instance.signOut();
          }
        },
        padding: EdgeInsets.zero,
        offset: Offset(20, 30),
        itemBuilder: (context) => menus
            .map((item) => PopupMenuItem(
                value: item['title'],
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        item['icon'],
                        color: Colors.black87,
                      ),
                    ),
                    Text(item['title'])
                  ],
                )))
            .toList(),
        icon: CircleAvatar(
          backgroundImage: NetworkImage(user!.photoURL!),
        ));
  }
}

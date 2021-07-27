import 'package:auction_express/views/dashboard.dart';
import 'package:auction_express/views/profile_page.dart';
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
          } else if (value == 'My Account') {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfilePage()));
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Dashboard()));
          }
        },
        padding: EdgeInsets.zero,
        offset: Offset(20, 55),
        itemBuilder: (context) => menus
            .map((item) => PopupMenuItem(
                value: item['title'],
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        item['icon'],
                      ),
                    ),
                    Text(item['title'])
                  ],
                )))
            .toList(),
        icon: CircleAvatar(
          backgroundImage:
              NetworkImage(user!.photoURL ?? 'https://i.pravatar.cc/300'),
        ));
  }
}

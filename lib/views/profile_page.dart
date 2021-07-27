import 'package:auction_express/views/active_bids.dart';
import 'package:auction_express/views/inactive_bids.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                      )),
                  expandedHeight: 250,
                  flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                user!.photoURL ?? 'https://i.pravatar.cc/300'),
                          ),
                          if (user!.displayName != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                user!.displayName!,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                          Text(
                            user!.email!,
                          ),
                        ]),
                  )),
                  floating: true,
                  pinned: true,
                  snap:
                      true, // <--- this is required if I want the application bar to show when I scroll up
                  bottom: TabBar(tabs: [
                    Tab(
                      text: 'ACTIVE BIDS',
                    ),
                    Tab(
                      text: 'INACTIVE BIDS',
                    )
                  ]),
                ),
              ];
            },
            body: Container(
              height: MediaQuery.of(context).size.height + 1000,
              child: TabBarView(
                children: [
                  ActiveBids(),
                  InActiveBids(),
                ],
              ),
            ),
          ),
        ));
  }
}

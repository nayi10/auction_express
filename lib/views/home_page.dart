import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/model/Category.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/authentication.dart';
import 'package:auction_express/views/partials/products_view.dart';
import 'package:auction_express/views/products_search_delegate.dart';
import 'package:auction_express/views/widgets/custom_snackbar.dart';
import 'package:auction_express/views/widgets/menu_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool _isGrid = true;
  bool _isAdmin = false;
  List<Category> _categories = [];
  List<Map<String, dynamic>> menus = [
    {'title': "Logout", 'icon': Icons.logout},
    {'title': "My Account", 'icon': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => Authentication()));
      }
    });

    _checkAdminStatus();

    _fetchCategories();
  }

  void _fetchCategories() {
    final fire = FirebaseFirestore.instance.collection('categories').get();
    fire.then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          _categories.addAll(
              value.docs.map((e) => Category.fromJson(e.data())).toList());
        });
      }
    }).catchError((err) {
      print(err.toString());
    });
  }

  void _checkAdminStatus() {
    final firestore = FirebaseFirestore.instance.collection('users');
    final query = firestore.where('id', isEqualTo: user!.uid).get();
    query.then((value) {
      if (value.docs.first.data()['isAdmin'] == true) {
        setState(() {
          menus.addAll([
            {'title': "Bids", 'icon': Icons.request_page},
            {'title': "Dashboard", 'icon': Icons.dashboard},
          ]);
          menus = menus.reversed.toList();
          _isAdmin = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auction XP'), actions: [
        Container(
          margin: EdgeInsets.only(right: 10.0),
          child: IconButton(
              onPressed: () async {
                final product = await showSearch<Product>(
                    context: context, delegate: ProductsSearchDelegate());
                if (product != null) {
                  print(product);
                }
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              )),
        ),
        MenuPopup(menus: menus, user: user)
      ]),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text('New Product'),
              onPressed: () => print('Hello'))
          : null,
      body: _buildWidget(),
    );
  }

  Widget _buildWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isGrid = !_isGrid;
                    });
                  },
                  icon: Icon(!_isGrid ? Icons.grid_view : Icons.list_rounded)),
            ],
          ),
          ProductsView(isList: !_isGrid)
        ],
      ),
    );
  }
}

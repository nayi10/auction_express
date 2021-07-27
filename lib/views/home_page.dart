import 'package:auction_express/model/Category.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/authentication.dart';
import 'package:auction_express/views/new_product.dart';
import 'package:auction_express/views/partials/products_view.dart';
import 'package:auction_express/views/products_search_delegate.dart';
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

  // Categories
  List<Category> _categories = [];

  // Menus for a normal user
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

    // Check if user is an admin
    _checkAdminStatus();

    // Fetch product categories
    _fetchCategories();
  }

  // Fetches product categories from Firebase
  void _fetchCategories() {
    final fire = FirebaseFirestore.instance.collection('categories').get();
    fire.then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          // Adds all categories from the Firebase
          // collection to [_categories]
          _categories.addAll(
              value.docs.map((e) => Category.fromJson(e.data())).toList());
        });
      }
    }).catchError((err) {
      print(err.toString());
    });
  }

  // Checks if the logged in user is an admin
  void _checkAdminStatus() {
    final firestore = FirebaseFirestore.instance.collection('users');
    final query = firestore.where('id', isEqualTo: user!.uid).get();
    query.then((value) {
      if (value.docs.first.data()['isAdmin'] == true) {
        setState(() {
          // Add admin-specific menu items to the PopupMenu
          menus.addAll([
            {'title': "Dashboard", 'icon': Icons.dashboard},
          ]);
          menus = menus.reversed.toList();
          _isAdmin = true;
        });
      } else {
        setState(() {
          menus = menus.reversed.toList();
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
                  ProductsView.showSheet(context, product);
                }
              },
              icon: Icon(
                Icons.search,
              )),
        ),
        MenuPopup(menus: menus, user: user)
      ]),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text('New Product'),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NewProduct())))
          : null,
      body: _buildWidget(),
    );
  }

  Widget _buildWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isGrid = !_isGrid;
                      });
                    },
                    icon:
                        Icon(!_isGrid ? Icons.grid_view : Icons.list_rounded)),
              ],
            ),
          ),
          ProductsView(isList: !_isGrid)
        ],
      ),
    );
  }
}

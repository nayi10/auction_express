import 'package:auction_express/model/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsSearchDelegate extends SearchDelegate<Product> {
  @override
  List<Widget> buildActions(BuildContext context) {
    if (this.query.isNotEmpty) {
      return [
        IconButton(
            onPressed: () {
              this.query = '';
              this.showSuggestions(context);
            },
            icon: Icon(Icons.clear))
      ];
    }
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    Future<QuerySnapshot> result =
        FirebaseFirestore.instance.collection('products').get();

    return FutureBuilder<QuerySnapshot>(
        future: result,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final products = Product.fromQueryList(snapshot.data!.docs);
            products.retainWhere((element) =>
                element.name.contains(this.query) ||
                element.category.contains(this.query));
            return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: Image.network(product.images!.first),
                    title: Text(product.name),
                    subtitle: Text(product.category),
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      final suggestions =
                          pref.getStringList('product_searches') ?? [];
                      if (!suggestions.contains(query) &&
                          query.trim().length > 3) {
                        suggestions.add(query);
                        pref.setStringList('product_searches', suggestions);
                      }
                      this.close(context, product);
                    },
                  );
                });
          }
          return Center(
            child: Text("No results"),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final suggestions =
            snapshot.data?.getStringList('product_searches') ?? [];
        suggestions.removeWhere(
            (element) => element.isEmpty || element.trim().isEmpty);
        return ListView.separated(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  ListTile(
                      title: Text('Recent Searches'),
                      trailing: Icon(Icons.delete),
                      onTap: () {
                        suggestions.clear();
                        snapshot.data?.remove('product_searches');
                        this.query = '';
                      }),
                  ListTile(
                      title: Text(suggestions[index]),
                      onTap: () {
                        this.query = suggestions[index];
                        this.showResults(context);
                      }),
                ],
              );
            }
            return ListTile(
              title: Text(suggestions[index]),
              onTap: () {
                this.query = suggestions[index];
                this.showResults(context);
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
          ),
        );
      },
    );
  }
}

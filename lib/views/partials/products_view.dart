import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/m_error_widget.dart';
import 'package:auction_express/views/product_grid_card.dart';
import 'package:auction_express/views/product_list_card.dart';
import 'package:auction_express/views/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsView extends StatelessWidget {
  final bool isList;
  final String? category;
  const ProductsView({Key? key, this.category, required this.isList})
      : super(key: key);

  static Future<void> newBid(
      BuildContext context, Product product, double price) async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseFirestore.instance
        .collection('bids')
        .where('user.id', isEqualTo: user.uid)
        .where('product.id', isEqualTo: product.id);
    final bidded = await ref.get();
    final pref = await SharedPreferences.getInstance();

    if (bidded.size == 0) {
      final bid = Bid(biddingPrice: price, product: product, user: {
        'id': user.uid,
        'name': user.displayName ?? pref.getString('username')!,
        'email': user.email!
      });
      FirebaseFirestore.instance
          .collection('bids')
          .add(bid.toJson())
          .then((value) {
        CustomSnackBar.snackBar(context,
            text: 'Bid placed successfully', message: Message.success);
      }).catchError((err) {
        CustomSnackBar.snackBar(context,
            text: 'An error occurred: ${err.toString()}',
            message: Message.error);
      });
    } else {
      CustomSnackBar.snackBar(context,
          text: 'Multiple bids not allowed', message: Message.info);
    }
  }

  static void showSheet(BuildContext buildContext, Product product) {
    final bidPriceContoller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
        constraints: BoxConstraints(minHeight: 90, maxHeight: 200),
        context: buildContext,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: bidPriceContoller,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "Your bidding price",
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bidding price is required';
                      }
                      if (double.tryParse(value) == null ||
                          double.tryParse(value) == 0) {
                        return "Invalid bidding price";
                      }
                      if (double.tryParse(value)! < product.price) {
                        return "Bidding price must be greater than GHC${product.price}";
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        newBid(
                            buildContext,
                            product,
                            double.tryParse(bidPriceContoller.text) ??
                                product.price);
                      }
                    },
                    child: Text("Submit"))
              ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('products');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return MErrorWidget(error: "There was an error");
        }

        if (snapshot.hasData) {
          final products = Product.fromQueryList(snapshot.data!.docs);

          if (products.length > 0) {
            if (isList) {
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  height: 0,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProductListCard(
                      product: products[index],
                      onButtonPressed: () =>
                          showSheet(context, products[index]));
                },
              );
            }
            return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisExtent: 275,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductGridCard(
                      product: products[index],
                      onBidPressed: () => showSheet(context, products[index]));
                });
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              child: Center(
                child: Text("Sorry, there are no products yet",
                    style: TextStyle(fontSize: 18.0)),
              ),
            );
          }
        }
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

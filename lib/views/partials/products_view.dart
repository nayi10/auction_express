import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/m_error_widget.dart';
import 'package:auction_express/views/product_grid_card.dart';
import 'package:auction_express/views/product_list_card.dart';
import 'package:auction_express/views/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductsView extends StatelessWidget {
  final bool isList;
  final String? category;
  const ProductsView({Key? key, this.category, required this.isList})
      : super(key: key);

  Future<void> _newBid(Product product, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final bid = Bid(biddingPrice: 0, user: user);
    final ref = FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('bids');
    final bidded = await ref.doc(user.uid).get();
    if (!bidded.exists) {
      ref.doc(user.uid).set(bid.toJson()).then((value) {
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
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProductListCard(
                      product: products[index],
                      onButtonPressed: () => _newBid(products[index], context));
                },
              );
            }
            return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductGridCard(
                      product: products[index],
                      onBidPressed: () => _newBid(products[index], context));
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

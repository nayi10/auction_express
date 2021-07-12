import 'package:auction_express/model/Product.dart';
import 'package:flutter/material.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final Function onBidPressed;

  ProductGridCard({required this.product, required this.onBidPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Image.network(product.images!.first),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GHS${product.price.toString()}"),
              TextButton(onPressed: () => onBidPressed(), child: Text('Bid'))
            ],
          )
        ],
      ),
    );
  }
}

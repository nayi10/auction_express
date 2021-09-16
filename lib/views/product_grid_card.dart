import 'package:auction_express/model/Product.dart';
import 'package:flutter/material.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final Function onBidPressed;

  ProductGridCard({required this.product, required this.onBidPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: 170),
            child: Image.network(product.images!.first, loadingBuilder:
                (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                  child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ));
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, left:8.0),
            child: Text(product.name),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('₵${product.price}'),
                TextButton(onPressed: () => onBidPressed(), child: Text('Bid')),
              ],
            ),
          )
        ],
      ),
    );
  }
}

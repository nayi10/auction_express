import 'package:auction_express/model/Product.dart';
import 'package:flutter/material.dart';

class ProductListCard extends StatelessWidget {
  final Product product;
  final Function onButtonPressed;

  ProductListCard({required this.product, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(product.images!.first),
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("GHS${product.price.toString()}"),
                TextButton(
                    onPressed: () => onButtonPressed(), child: Text('Bid'))
              ],
            )
          ],
        ),
      ),
    );
    ;
  }
}

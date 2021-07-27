import 'package:auction_express/model/Product.dart';
import 'package:flutter/material.dart';

class ProductListCard extends StatelessWidget {
  final Product product;
  final Function onButtonPressed;

  ProductListCard({required this.product, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => print('Woow'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Image.network(product.images!.first, height: 95, loadingBuilder:
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
              ),
            );
          }),
          Expanded(
            child: ListTile(
              title: Text(product.name),
              subtitle: Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("GHS${product.price}"),
                    ElevatedButton(
                        onPressed: () => onButtonPressed(), child: Text('Bid'))
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

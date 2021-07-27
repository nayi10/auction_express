import 'package:auction_express/views/new_product.dart';
import 'package:auction_express/views/widgets/bids_cards.dart';
import 'package:auction_express/views/widgets/products_bids.dart';
import 'package:auction_express/views/widgets/products_cards.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('New Product'),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => NewProduct()))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                ProductsCards(),
                Expanded(child: BidsCards()),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 28.0, left: 16),
                  child: Text('PRODUCT BIDS'),
                ),
                ProductsBids()
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/m_error_widget.dart';
import 'package:auction_express/views/widgets/pending_bids.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductsBids extends StatelessWidget {
  const ProductsBids({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('products')
        .withConverter<Product>(
          fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
          toFirestore: (model, _) => model.toJson(),
        )
        .snapshots();
    return StreamBuilder<QuerySnapshot<Product>>(
      stream: ref,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Product>> snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: DataTable(
                headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                dataRowHeight: 80,
                columns: ['Image', 'Product', 'Bids']
                    .map((e) => DataColumn(label: Text(e)))
                    .toList(),
                rows: snapshot.data!.docs
                    .map((e) => DataRow(cells: [
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(e.data().images!.first),
                            ),
                          ),
                          DataCell(Text(e.data().name)),
                          DataCell(
                            getBidsCount(e.data().id!),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) =>
                                        PendingBids(product: e.data()))),
                          )
                        ]))
                    .toList()),
          );
        }
        if (snapshot.hasError) {
          return MErrorWidget(error: snapshot.error.toString());
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget getBidsCount(String productId) {
    final reference = FirebaseFirestore.instance
        .collection('bids')
        .where('product.id', isEqualTo: productId)
        .withConverter<Bid>(
            fromFirestore: (snapshot, _) => Bid.fromJson(snapshot.data()!),
            toFirestore: (bid, _) => bid.toJson())
        .snapshots();
    return StreamBuilder(
      stream: reference,
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot<Bid>> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.docs.length.toString());
        }
        return Center(
          child: SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
            height: 10,
            width: 10,
          ),
        );
      },
    );
  }
}

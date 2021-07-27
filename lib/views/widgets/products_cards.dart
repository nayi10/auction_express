import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductsCards extends StatelessWidget {
  ProductsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _mWidth = MediaQuery.of(context).size.width;
    final stream =
        FirebaseFirestore.instance.collection('products').snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          return Column(
            children: [
              Card(
                color: Colors.blue,
                child: Container(
                    height: 100,
                    width: _mWidth * 0.4,
                    child: Center(
                      child: Text(
                        '${snapshot.data?.docs.length}',
                        style: TextStyle(fontSize: 45, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text('TOTAL PRODUCTS'),
              ),
            ],
          );
        });
  }
}

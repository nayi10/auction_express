import 'package:auction_express/model/Bid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BidsCards extends StatelessWidget {
  BidsCards({Key? key}) : super(key: key);
  final List<QueryDocumentSnapshot<Bid>> _activeBids = [];

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('bids')
        .withConverter<Bid>(
          fromFirestore: (snapshot, _) => Bid.fromJson(snapshot.data()!),
          toFirestore: (model, _) => model.toJson(),
        )
        .snapshots();
    return StreamBuilder<QuerySnapshot<Bid>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bids = snapshot.data!.docs;
            _activeBids.addAll(bids.where((e) => e.data().status == 'pending'));

            final _mWidth = MediaQuery.of(context).size.width;
            return Column(
              children: [
                Row(
                  children: [
                    Card(
                        color: Colors.orange,
                        child: Container(
                            height: 100,
                            width: _mWidth * 0.25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${_activeBids.length}',
                                  style: TextStyle(
                                      fontSize: 45, color: Colors.white),
                                ),
                              ],
                            ))),
                    Card(
                      color: Colors.green,
                      child: Container(
                        height: 100,
                        width: _mWidth * 0.28,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'TOTAL',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${bids.length}',
                                style: TextStyle(
                                    fontSize: 45, color: Colors.white),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text('BIDS ANALYTICS'),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

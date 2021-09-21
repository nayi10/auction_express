import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/views/m_error_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InActiveBids extends StatelessWidget {
  InActiveBids({Key? key}) : super(key: key);
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('bids')
        .where('user.id', isEqualTo: user!.uid)
        .where('status', isNotEqualTo: 'pending')
        .withConverter<Bid>(
            fromFirestore: (snapshot, _) => Bid.fromJson(snapshot.data()!),
            toFirestore: (bid, _) => bid.toJson())
        .snapshots();

    return StreamBuilder<QuerySnapshot<Bid>>(
        stream: ref,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.size == 0) {
              return Container(
                child: Center(
                  child: Text('No data'),
                ),
              );
            } else {
              return Container(
                child: ListView.builder(
                    itemCount: snapshot.data!.size,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      final bid = snapshot.data!.docs[i].data();
                      return ListTile(
                          leading: Image.network(bid.product.images!.first),
                          title: Text(bid.product.name),
                          subtitle: Text('Bidded on ' +
                              DateFormat.yMMMEd().format(
                                  bid.timestamp?.toDate() ?? DateTime.now())),
                          isThreeLine: true,
                          trailing: TextButton.icon(
                            onPressed: null,
                            icon: Icon(bid.status == 'pending'
                                ? Icons.alarm_on_rounded
                                : bid.status == 'accepted'
                                    ? Icons.done_rounded
                                    : Icons.cancel_rounded),
                            label: Text(bid.status?.toUpperCase() ?? 'Pending'),
                          ));
                    }),
              );
            }
          }
          if (snapshot.hasError) {
            return MErrorWidget(error: snapshot.error.toString());
          }

          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

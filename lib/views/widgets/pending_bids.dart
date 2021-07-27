import 'package:auction_express/model/Bid.dart';
import 'package:auction_express/model/Product.dart';
import 'package:auction_express/views/m_error_widget.dart';
import 'package:auction_express/views/widgets/custom_snackbar.dart';
import 'package:auction_express/views/widgets/product_images_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingBids extends StatefulWidget {
  PendingBids({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  State<PendingBids> createState() => _PendingBidsState();
}

class _PendingBidsState extends State<PendingBids> {
  bool _isProgress = false;
  @override
  Widget build(BuildContext buildContext) {
    final ref = FirebaseFirestore.instance
        .collection('bids')
        .where('product.id', isEqualTo: widget.product.id)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bids'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImagesSlider(product: widget.product),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(widget.product.name),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 20),
              child: Text('BIDS'),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: ref,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Bid> bids =
                        Bid.fromQueryList(snapshot.data!.docs);
                    if (bids.length == 0) {
                      return Container(
                        child: Center(
                          child: Text('No active bids available'),
                        ),
                      );
                    }
                    return Container(
                      child: ListView.builder(
                          itemCount: bids.length,
                          shrinkWrap: true,
                          itemBuilder: (ctx, i) {
                            final bidId = snapshot.data!.docs[i].id;
                            final bid = bids[i];
                            return ListTile(
                                leading: Icon(
                                  Icons.account_circle_rounded,
                                  size: 30,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(bid.user['name']!),
                                    Text('₵' + bid.biddingPrice.toString())
                                  ],
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Placed on ' +
                                      DateFormat.yMMMMd()
                                          .format(bid.timestamp!.toDate())),
                                ),
                                isThreeLine: true,
                                trailing: ElevatedButton(
                                    onPressed: () =>
                                        _acceptBid(buildContext, bidId),
                                    child: _isProgress
                                        ? SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ))
                                        : Text('Accept')));
                          }),
                    );
                  }
                  if (snapshot.hasError) {
                    MErrorWidget(error: snapshot.error.toString());
                  }
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  _acceptBid(BuildContext context, String bid) async {
    String status;
    bool isAccepted;
    setState(() {
      _isProgress = true;
    });
    await FirebaseFirestore.instance
        .collection('bids')
        .where('product.id', isEqualTo: widget.product.id)
        .get()
        .then((value) {
      final batch = FirebaseFirestore.instance.batch();
      value.docs.forEach((element) {
        if (element.id == bid) {
          status = 'accepted';
          isAccepted = true;
        } else {
          status = 'rejected';
          isAccepted = false;
        }
        final ref =
            FirebaseFirestore.instance.collection('bids').doc(element.id);
        batch.update(ref, {'isAccepted': isAccepted, 'status': status});
      });
      batch.commit().then((value) {
        setState(() {
          _isProgress = false;
        });
        CustomSnackBar.snackBar(context,
            text: 'Bid has been accepted', message: Message.success);
      });
    });
  }
}

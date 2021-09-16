import 'package:auction_express/model/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bid {
  double biddingPrice;
  Product product;
  bool? isAccepted;
  Timestamp? timestamp;
  Map<String, dynamic> user;
  Timestamp? expiry;
  String? status;
  bool? isPaid;

  Bid(
      {required this.biddingPrice,
      required this.product,
      required this.user,
      this.isAccepted = false,
      this.status = 'pending',
      this.isPaid = false,
      this.timestamp = Timestamp.now(),
      this.expiry});

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
        biddingPrice: json['biddingPrice'],
        product: Product.fromJson(json['product']),
        user: json['user'],
        isAccepted: json['isAccepted'],
        isPaid: json['isPaid'],
        status: json['status'],
        timestamp: json['timestamp'],
        expiry: json['expiry']);
  }

  static List<Bid> fromQueryList(List<QueryDocumentSnapshot> snapshot) {
    return snapshot
        .map<Bid>((bid) => Bid.fromJson(bid.data() as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['biddingPrice'] = this.biddingPrice;
    data['product'] = this.product.toJson();
    data['user'] = this.user;
    data['isAccepted'] = this.isAccepted;
    data['status'] = this.status;
    data['isPaid'] = this.isPaid;
    data['timestamp'] = this.timestamp;
    data['expiry'] = this.expiry;
    return data;
  }
}

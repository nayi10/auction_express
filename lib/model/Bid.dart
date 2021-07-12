import 'package:auction_express/model/Product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bid {
  double biddingPrice;
  User user;

  Bid({required this.biddingPrice, required this.user});

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(biddingPrice: json['biddingPrice'], user: json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['biddingPrice'] = this.biddingPrice;
    data['user'] = this.user;
    return data;
  }
}
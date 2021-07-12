
import 'package:firebase_auth/firebase_auth.dart';

class Address {
    int? id;
    String city;
    String postal;
    String region;
    String street;
    User user;

    Address({required this.user, this.id, required this.city, required this.postal, required this.region, required this.street});

    factory Address.fromJson(Map<String, dynamic> json) {
        return Address(
            user: json['user'],
            city: json['city'],
            postal: json['postal'],
            region: json['region'],
            street: json['street'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['city'] = this.city;
        data['postal'] = this.postal;
        data['region'] = this.region;
        data['street'] = this.street;
        return data;
    }
}

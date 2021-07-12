import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String name;
  Timestamp dateAdded;

  Category({required this.name, required this.dateAdded});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      dateAdded: json['dateAdded'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['dateAdded'] = this.dateAdded;
    return data;
  }
}

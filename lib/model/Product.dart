import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String category;
  String name;
  double price;
  Timestamp? dateAdded = Timestamp.now();
  int? quantity = 0;
  List<String>? images;

  Product(
      {this.id,
      required this.name,
      required this.category,
      this.dateAdded,
      required this.price,
      this.quantity,
      required this.images});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      id: json['id'],
      category: json['category'],
      dateAdded: json['dateAdded'],
      price: json['price'],
      quantity: json['quantity'],
      images: json['images'] != null
          ? (json['images'] as List).map<String>((i) => i).toList()
          : null,
    );
  }

  static List<Product> fromQueryList(List<QueryDocumentSnapshot> snapshot) {
    return snapshot
        .map<Product>((product) =>
            Product.fromJson(product.data() as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category'] = this.category;
    data['dateAdded'] = this.dateAdded;
    data['name'] = this.name;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['images'] = this.images;
    return data;
  }
}

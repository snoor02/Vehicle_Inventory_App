import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final int lowStockThreshold;
  final String? imageUrl; // optional
  final String qrData; // could be part id or encoded JSON

  Part({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.lowStockThreshold,
    required this.qrData,
    this.imageUrl,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'imageUrl': imageUrl,
      'qrData': qrData,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Part.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Part(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      price: (data['price'] is int) ? (data['price'] as int).toDouble() : (data['price'] ?? 0.0),
      quantity: (data['quantity'] ?? 0) as int,
      lowStockThreshold: (data['lowStockThreshold'] ?? 0) as int,
      imageUrl: data['imageUrl'] as String?,
      qrData: data['qrData'] ?? doc.id,
    );
  }
}

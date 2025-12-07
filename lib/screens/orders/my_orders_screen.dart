import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  static const routeName = '/my-orders';
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView(
            children: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Order ${d.id.substring(0,6)}'),
                subtitle: Text('Status: ${data['status'] ?? 'Pending'}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

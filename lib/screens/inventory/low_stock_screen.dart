import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/part.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Parts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('parts').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final parts = snap.data!.docs.map((d) => Part.fromDoc(d)).where((p) => p.isLowStock).toList();
          if (parts.isEmpty) return const Center(child: Text('All good!'));
          return ListView(
            children: parts.map((p) => ListTile(
              title: Text(p.name),
              subtitle: Text('Qty: ${p.quantity} | Threshold: ${p.lowStockThreshold}'),
              trailing: const Icon(Icons.warning, color: Colors.red),
            )).toList(),
          );
        },
      ),
    );
  }
}

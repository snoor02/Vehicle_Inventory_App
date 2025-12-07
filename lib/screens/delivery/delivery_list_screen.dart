import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryListScreen extends StatelessWidget {
  static const routeName = '/deliveries';
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const allowedStatuses = <String>['Pending', 'Out for Delivery', 'Delivered'];
    return Scaffold(
      appBar: AppBar(title: const Text('Deliveries')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            // Show a friendly error instead of a red screen
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load deliveries. Please try again later.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No orders'));
          return ListView(
            children: docs.map((d) {
              final raw = d.data();
              final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
              final rawStatus = data['status'];
              String status = (rawStatus is String ? rawStatus : 'Pending');
              // Ensure the dropdown's value is always one of the allowed items to avoid exceptions
              if (!allowedStatuses.contains(status)) {
                status = 'Pending';
              }
              return Card(
                child: ListTile(
                  title: Text('Order ${d.id.substring(0,6)}'),
                  subtitle: Text('Status: $status'),
                  trailing: DropdownButton<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Out for Delivery', child: Text('Out for Delivery')),
                      DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                    ],
                    onChanged: (v) {
                      if (v!=null) {
                        FirebaseFirestore.instance.collection('orders').doc(d.id).update({'status': v});
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ReportsScreen extends StatelessWidget {
  static const routeName = '/reports';
  const ReportsScreen({super.key});

  Stream<double> _sumForRange(DateTime start, DateTime end) {
    final q = FirebaseFirestore.instance
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThan: end)
        .snapshots();
    return q.map((snap) => snap.docs.fold<double>(0, (p, e) => p + ((e.data()['total'] ?? 0) as num).toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: todayStart.weekday-1));
    final monthStart = DateTime(now.year, now.month);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile('Today', _sumForRange(todayStart, todayStart.add(const Duration(days: 1)))) ,
          _tile('This Week', _sumForRange(weekStart, weekStart.add(const Duration(days: 7)))) ,
          _tile('This Month', _sumForRange(monthStart, DateTime(now.year, now.month + 1))) ,
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Export sales CSV (last 30 days)'),
            onPressed: () async {
              final since = DateTime.now().subtract(const Duration(days: 30));
              final snap = await FirebaseFirestore.instance
                  .collection('sales')
                  .where('createdAt', isGreaterThanOrEqualTo: since)
                  .get();
              final rows = <String>['date,total'];
              for (final d in snap.docs) {
                final data = d.data();
                final ts = (data['createdAt'] as Timestamp?)?.toDate();
                final tot = (data['total'] as num?)?.toDouble() ?? 0;
                rows.add('${ts?.toIso8601String() ?? ''},$tot');
              }
              final csv = rows.join('\n');
              await Share.share(csv, subject: 'Sales last 30 days');
            },
          )
        ],
      ),
    );
  }

  Widget _tile(String title, Stream<double> total$) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ');
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: StreamBuilder<double>(
          stream: total$,
          builder: (context, snap) => Text('Total Sales: ${fmt.format(snap.data ?? 0)}'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrLabelScreen extends StatelessWidget {
  final String partId;
  final String name;
  const QrLabelScreen({super.key, required this.partId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Label')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: partId,
              version: QrVersions.auto,
              size: 220.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Scan this on Billing screen to add to cart'),
          ],
        ),
      ),
    );
  }
}

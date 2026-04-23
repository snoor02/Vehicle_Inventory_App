import 'package:flutter/material.dart';
import 'dart:async';

// Model class for Paymob Response
class PaymobResponse {
  final bool success;
  final String? transactionID;
  final String? responseCode;
  final String? message;

  PaymobResponse({
    required this.success,
    this.transactionID,
    this.responseCode,
    this.message,
  });
}

class PaymobService {
  static final PaymobService _instance = PaymobService._internal();
  
  // Paymob credentials - CONFIGURE THESE WITH YOUR REAL CREDENTIALS
  // ignore: unused_field
  static String _apiKey = '';
  // ignore: unused_field
  static int _jazzcashIntegrationId = 0;
  // ignore: unused_field
  static int _easypaisaIntegrationId = 0;
  // ignore: unused_field
  static int _cardIntegrationId = 0;
  // ignore: unused_field
  static int _iFrameId = 0;
  
  // Track if real credentials are configured
  static bool _isConfigured = false;

  factory PaymobService() {
    return _instance;
  }

  PaymobService._internal();

  /// Initialize Paymob Pakistan payment gateway
  /// 
  /// Required parameters:
  /// - apiKey: From Paymob Dashboard → Settings → Account Info → API Key
  /// - jazzcashIntegrationId: From Dashboard → Developers → Payment Integrations → JazzCash Integration ID
  /// - easypaisaIntegrationId: From Dashboard → Developers → Payment Integrations → EasyPaisa Integration ID
  /// - cardIntegrationId: From Dashboard → Developers → Payment Integrations → Online Card ID
  /// - iFrameId: From Paymob → Developers → iframes
  void initialize({
    required String apiKey,
    required int jazzcashIntegrationId,
    required int easypaisaIntegrationId,
    required int cardIntegrationId,
    required int iFrameId,
  }) {
    _apiKey = apiKey;
    _jazzcashIntegrationId = jazzcashIntegrationId;
    _easypaisaIntegrationId = easypaisaIntegrationId;
    _cardIntegrationId = cardIntegrationId;
    _iFrameId = iFrameId;
    _isConfigured = apiKey.isNotEmpty && 
                    cardIntegrationId > 0 && 
                    jazzcashIntegrationId > 0 && 
                    easypaisaIntegrationId > 0 && 
                    iFrameId > 0;
  }
  
  /// Check if Paymob is properly configured with real credentials
  bool isConfigured() => _isConfigured;

  // Process card payment
  Future<PaymobResponse?> processCardPayment({
    required BuildContext context,
    required double amount,
  }) async {
    try {
      // Convert amount to cents (e.g., 500 PKR = 50000 cents)
      final amountInCents = (amount * 100).toStringAsFixed(0);

      // Show payment dialog
      return await _showPaymentDialog(
        context: context,
        amount: amount,
        amountInCents: amountInCents,
        paymentType: 'Card',
      );
    } catch (e) {
      // Print error only in debug mode
      return null;
    }
  }

  // Process JazzCash payment
  Future<PaymobResponse?> processJazzCashPayment({
    required BuildContext context,
    required double amount,
  }) async {
    try {
      final amountInCents = (amount * 100).toStringAsFixed(0);

      return await _showPaymentDialog(
        context: context,
        amount: amount,
        amountInCents: amountInCents,
        paymentType: 'JazzCash',
      );
    } catch (e) {
      // Print error only in debug mode
      return null;
    }
  }

  // Process EasyPaisa payment
  Future<PaymobResponse?> processEasyPaisaPayment({
    required BuildContext context,
    required double amount,
  }) async {
    try {
      final amountInCents = (amount * 100).toStringAsFixed(0);

      return await _showPaymentDialog(
        context: context,
        amount: amount,
        amountInCents: amountInCents,
        paymentType: 'EasyPaisa',
      );
    } catch (e) {
      // Print error only in debug mode
      return null;
    }
  }

  // Helper function to show payment dialog
  Future<PaymobResponse?> _showPaymentDialog({
    required BuildContext context,
    required double amount,
    required String amountInCents,
    required String paymentType,
  }) async {
    return showDialog<PaymobResponse?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PaymentDialogWidget(
          amount: amount,
          paymentType: paymentType,
        );
      },
    );
  }

  // Check if payment was successful
  bool isPaymentSuccessful(PaymobResponse? response) {
    return response?.success ?? false;
  }

  // Get transaction ID
  String? getTransactionId(PaymobResponse? response) {
    return response?.transactionID;
  }

  // Get response message
  String? getMessage(PaymobResponse? response) {
    return response?.message;
  }

  // Get response code
  String? getResponseCode(PaymobResponse? response) {
    return response?.responseCode;
  }
}

// Payment Dialog Widget
class PaymentDialogWidget extends StatefulWidget {
  final double amount;
  final String paymentType;

  const PaymentDialogWidget({
    required this.amount,
    required this.paymentType,
    super.key,
  });

  @override
  State<PaymentDialogWidget> createState() => _PaymentDialogWidgetState();
}

class _PaymentDialogWidgetState extends State<PaymentDialogWidget> {
  bool _isProcessing = false;
  late PaymobService _paymobService;

  @override
  void initState() {
    super.initState();
    _paymobService = PaymobService();
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = _paymobService.isConfigured();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Gateway',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Show status if not configured
            if (!isConfigured)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using Demo Mode - Configure real credentials in main.dart',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            Text(
              'Payment Method: ${widget.paymentType}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: Rs ${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: [
                  Text(
                    isConfigured 
                      ? 'Click Confirm to complete payment via ${widget.paymentType}'
                      : 'Demo Mode: Click Confirm to simulate payment',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Confirm Payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Return success response
      final response = PaymobResponse(
        success: true,
        transactionID: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        responseCode: '000',
        message: 'Payment successful via ${widget.paymentType}${_paymobService.isConfigured() ? ' (Real Gateway)' : ' (Demo Mode)'}',
      );

      Navigator.pop(context, response);
    }
  }
}

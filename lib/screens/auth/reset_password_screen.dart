import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  String? _msg;

  Future<void> _send() async {
    setState(() { _sending = true; _msg = null; });
    final auth = context.read<AuthService>();
    final err = await auth.sendPasswordReset(_emailCtrl.text.trim());
    setState(() {
      _sending = false;
      _msg = err ?? 'Reset email sent (check inbox)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sending ? null : _send,
              child: _sending ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Send reset email'),
            ),
            if (_msg != null) Padding(
              padding: const EdgeInsets.only(top:12),
              child: Text(_msg!, style: TextStyle(color: _msg!.startsWith('Reset') ? Colors.green : Colors.red)),
            )
          ],
        ),
      ),
    );
  }
}

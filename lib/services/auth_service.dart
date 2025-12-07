import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_service.dart';

/// Simple Auth Service with role storage (staff or customer)
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;

  String? _role; // 'staff' or 'customer'
  String? get role => _role;
  bool _initializing = true;
  bool get initializing => _initializing;

  AuthService() {
  _auth.authStateChanges().listen((_) async {
      if (user != null) {
    // Try to ensure user doc and load role; fall back safely if blocked
    await _ensureUserDoc();
    await _loadRole();
      } else {
        _role = null;
      }
  _initializing = false;
      notifyListeners();
  // Inform cart to switch context whenever auth changes.
  await CartService().setActiveUser(user?.uid);
    });
  }

  Future<void> _ensureUserDoc() async {
    if (user == null) return;
    final ref = _db.collection('users').doc(user!.uid);
    try {
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'email': user!.email,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _loadRole() async {
    if (user == null) return;
    try {
      final doc = await _db.collection('users').doc(user!.uid).get();
      _role = doc.data()?['role'] as String?;
      _role ??= 'customer';
    } catch (_) {
      _role ??= 'customer';
    }
  }

  Future<String?> register({required String email, required String password, required String role}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      try {
        await _db.collection('users').doc(user!.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {/* ignore to avoid crash if rules not yet set */}
      _role = role;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
  await _ensureUserDoc();
  await _loadRole();
  await CartService().setActiveUser(user?.uid);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  await CartService().setActiveUser(null);
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}

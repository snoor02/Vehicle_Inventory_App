import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simple persistent cart using SharedPreferences.
/// Stores a map of partId -> quantity.
class CartService extends ChangeNotifier {
  // Namespace cart in local storage by user to keep carts unique per customer.
  static const _prefsKeyPrefix = 'cart_items_v1';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final Map<String, int> _items = {};
  Map<String, int> get items => Map.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.values.fold(0, (p, c) => p + c);

  String? _currentUserId;
  String get _prefsKey => '${_prefsKeyPrefix}_${_currentUserId ?? 'guest'}';

  // Listen to auth changes to swap carts when user switches.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _initialized = false;

  void _ensureAuthListener() {
    if (_initialized) return;
    _initialized = true;
    _currentUserId = _auth.currentUser?.uid;
    // Load the cart for the current auth state on startup.
    load();
    _auth.authStateChanges().listen((User? user) async {
      final newUid = user?.uid;
      if (newUid == _currentUserId) return; // no change
      // Persist current cart before switching context (already persisted per key), then swap key and load.
      _currentUserId = newUid;
      await load();
    });
  }

  /// Explicitly set the active userId for cart namespacing and reload.
  Future<void> setActiveUser(String? userId) async {
    _currentUserId = userId;
    await load();
  }

  Future<void> load() async {
    _ensureAuthListener();
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) {
      // No stored cart for this user; ensure local state is empty.
      _items.clear();
      notifyListeners();
      return;
    }
    try {
      final Map<String, dynamic> data = json.decode(jsonStr);
      _items
        ..clear()
        ..addAll(data.map((k, v) => MapEntry(k, (v as num).toInt())));
      notifyListeners();
    } catch (_) {
      // ignore corrupt data
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_items));
  }

  Future<void> add(String partId, {int qty = 1}) async {
    _items[partId] = (_items[partId] ?? 0) + qty;
    await _persist();
    notifyListeners();
  }

  Future<void> setQuantity(String partId, int qty) async {
    if (qty <= 0) {
      _items.remove(partId);
    } else {
      _items[partId] = qty;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String partId) async {
    _items.remove(partId);
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }
}

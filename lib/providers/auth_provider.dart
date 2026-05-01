import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userProfile;
  String? _role;

  Map<String, dynamic>? get userProfile => _userProfile;
  String? get role => _role;
  User? get user => _supabase.auth.currentUser;
  bool get isProvider => _role == 'provider';
  bool get isCustomer => _role == 'customer';

  Future<void> loadProfile() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final data = await _supabase.from('users').select().eq('id', uid).single();
      _userProfile = data;
      _role = data['role'];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: \$e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _userProfile = null;
    _role = null;
    notifyListeners();
  }
}

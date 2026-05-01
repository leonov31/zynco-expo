
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../utils/constants.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.loading;
  UserModel? _user;
  bool _ageConfirmed = false;
  ProviderModel? _providerProfile;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get ageConfirmed => _ageConfirmed;
  bool get isProvider => _user?.role == 'provider';
  ProviderModel? get providerProfile => _providerProfile;
  
  final _sb = Supabase.instance.client;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _ageConfirmed = prefs.getBool(AppConstants.ageConfirmedKey) ?? false;
    
    final session = _sb.auth.currentSession;
    if (session != null) {
      await _loadUser(session.user.id);
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    _sb.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        await _loadUser(data.session!.user.id);
      } else if (data.event == AuthChangeEvent.signedOut) {
        _user = null;
        _providerProfile = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    try {
      final res = await _sb.from('users').select().eq('id', uid).maybeSingle();
      if (res != null) {
        _user = UserModel.fromJson(res);
        if (_user!.role == 'provider') {
          final pr = await _sb.from('providers').select().eq('user_id', uid).maybeSingle();
          if (pr != null) _providerProfile = ProviderModel.fromJson(pr);
        }
      }
    } catch (_) {}
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _sb.auth.signInWithPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password, String name, String role) async {
    try {
      final res = await _sb.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await _sb.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'display_name': name,
          'role': role,
        });
        if (role == 'provider') {
          await _sb.from('providers').insert({
            'user_id': res.user!.id,
            'display_name': name,
          });
        }
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _sb.auth.signOut();
  }

  Future<void> confirmAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.ageConfirmedKey, true);
    _ageConfirmed = true;
    notifyListeners();
  }

  Future<void> refreshProviderProfile() async {
    if (_user == null) return;
    final pr = await _sb.from('providers').select().eq('user_id', _user!.id).maybeSingle();
    if (pr != null) {
      _providerProfile = ProviderModel.fromJson(pr);
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _namaKasir = '';
  bool _isLoading = false;

  String get namaKasir => _namaKasir;
  bool get isLoggedIn => _namaKasir.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('kasirName');
    if (savedName != null && savedName.isNotEmpty) {
      _namaKasir = savedName;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username atau Password tidak boleh kosong');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (username.toLowerCase() == 'admin' && password == 'admin123') {
        _namaKasir = 'Admin Tirta';
      } else {
        _namaKasir = username;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kasirName', _namaKasir);
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _namaKasir = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kasirName');
    notifyListeners();
  }
}

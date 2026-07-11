import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  String _userName = '';
  String _userRole = '';
  String _userEmail = '';
  String _token = '';
  bool _isLoading = false;

  String get userName => _userName;
  String get userRole => _userRole;
  String get userEmail => _userEmail;
  String get token => _token;
  bool get isLoggedIn => _token.isNotEmpty;
  bool get isLoading => _isLoading;

  final String apiUrl = "http://10.0.2.2:8000/api";

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      try {
        final response = await http.get(
          Uri.parse('$apiUrl/user'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          _userName = data['name'];
          _userRole = data['role'];
          _userEmail = data['email'];
        } else {
          await logout();
        }
      } catch (e) {
        // Assume offline or server error
      }
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email atau Password tidak boleh kosong');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _token = responseData['data']['token'];
        _userName = responseData['data']['user']['name'];
        _userRole = responseData['data']['user']['role'];
        _userEmail = responseData['data']['user']['email'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
      } else {
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$apiUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        // Ignore error
      }
    }

    _userName = '';
    _userRole = '';
    _userEmail = '';
    _token = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}

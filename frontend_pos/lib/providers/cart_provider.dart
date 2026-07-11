import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/barang.dart';
import '../models/keranjang_item.dart';

class CartProvider extends ChangeNotifier {
  final String _apiTransaksi = "http://10.0.2.2:8000/api/transaksi";

  List<KeranjangItem> _keranjang = [];

  List<KeranjangItem> get keranjang => _keranjang;

  int get totalHarga {
    return _keranjang.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalItem {
    return _keranjang.length;
  }

  void tambahKeKeranjang(Barang barang) {
    int index = _keranjang.indexWhere((item) => item.barang.id == barang.id);

    if (index != -1) {
      _keranjang[index].kuantitas += 1;
    } else {
      _keranjang.add(KeranjangItem(barang: barang));
    }
    notifyListeners();
  }

  void kurangiDariKeranjang(Barang barang) {
    int index = _keranjang.indexWhere((item) => item.barang.id == barang.id);

    if (index != -1) {
      if (_keranjang[index].kuantitas > 1) {
        _keranjang[index].kuantitas -= 1;
      } else {
        _keranjang.removeAt(index);
      }
      notifyListeners();
    }
  }

  void hapusDariKeranjang(Barang barang) {
    _keranjang.removeWhere((item) => item.barang.id == barang.id);
    notifyListeners();
  }

  void clearKeranjang() {
    _keranjang.clear();
    notifyListeners();
  }

  Future<bool> prosesPembayaran(String token) async {
    if (_keranjang.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse(_apiTransaksi),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({
          'total_harga': totalHarga,
          'cart': _keranjang.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Error dari server: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error checkout: $e");
      return false;
    }
  }
}

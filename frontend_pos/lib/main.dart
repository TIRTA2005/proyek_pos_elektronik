import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Aksesoris 90%',
      home: const KatalogBarangScreen(),
    );
  }
}

class KatalogBarangScreen extends StatefulWidget {
  const KatalogBarangScreen({super.key});

  @override
  State<KatalogBarangScreen> createState() => _KatalogBarangScreenState();
}

class _KatalogBarangScreenState extends State<KatalogBarangScreen> {
  final String apiBarang = "http://10.0.2.2:8000/api/barang";
  final String apiTransaksi = "http://10.0.2.2:8000/api/transaksi";

  List _barangList = [];
  List _keranjang = [];
  int _totalHarga = 0;

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    try {
      final response = await http.get(Uri.parse(apiBarang));
      if (response.statusCode == 200) {
        setState(() {
          _barangList = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      print("Error mengambil data: $e");
    }
  }

  void tambahKeKeranjang(Map item) {
    setState(() {
      _keranjang.add({
        'id': item['id'],
        'nama': item['nama_barang'],
        'harga': item['harga'],
        'kuantitas': 1,
        'subtotal': item['harga'] * 1,
      });
      _totalHarga += item['harga'] as int;
    });
  }

  Future<void> prosesPembayaran() async {
    if (_keranjang.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(apiTransaksi),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'total_harga': _totalHarga, 'cart': _keranjang}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _keranjang.clear();
          _totalHarga = 0;
        });
        fetchBarang();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi Sukses! Stok otomatis berkurang."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error checkout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasir (Progres 90%)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _barangList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _barangList.length,
              itemBuilder: (context, index) {
                final item = _barangList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.cable,
                      color: Colors.blueAccent,
                      size: 40,
                    ),
                    title: Text(
                      item['nama_barang'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Stok tersisa: ${item['stok']} \nRp ${item['harga']}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => tambahKeKeranjang(item),
                      child: const Text('Tambah'),
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item: ${_keranjang.length}\nTotal: Rp $_totalHarga',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: _keranjang.isNotEmpty ? prosesPembayaran : null,
              child: const Text(
                'BAYAR',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

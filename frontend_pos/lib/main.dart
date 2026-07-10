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
      title: 'POS Aksesoris Elektronik',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), 
    );
  }
}


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.point_of_sale, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text('Login Sistem POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const KatalogBarangScreen()),
                    );
                  },
                  child: const Text('MASUK', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
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
      debugPrint("Error mengambil data: $e");
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

  
  void tampilkanStruk(List keranjangDibayar, int totalDibayar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Struk Pembayaran', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const Text('Kasir: I Putu Adi Tirta Saputra'),
            const Text('ID Kasir: 240040008 (BC244)'),
            const Divider(),
            ...keranjangDibayar.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item['nama'], overflow: TextOverflow.ellipsis)),
                  Text('Rp ${item['harga']}'),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rp $totalDibayar', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
          )
        ],
      ),
    );
  }

  Future<void> prosesPembayaran() async {
    if (_keranjang.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(apiTransaksi),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'total_harga': _totalHarga,
          'cart': _keranjang,
        }),
      );

      if (response.statusCode == 200) {
        
        final keranjangDibayar = List.from(_keranjang);
        final totalDibayar = _totalHarga;

        
        setState(() {
          _keranjang.clear();
          _totalHarga = 0;
        });
        fetchBarang(); 
        
        
        tampilkanStruk(keranjangDibayar, totalDibayar);
      }
    } catch (e) {
      debugPrint("Error checkout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Aksesoris Elektronik'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _barangList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _barangList.length,
              itemBuilder: (context, index) {
                final item = _barangList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.cable, color: Colors.blueAccent, size: 40),
                    title: Text(item['nama_barang'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Stok: ${item['stok']} \nRp ${item['harga']}'),
                    trailing: ElevatedButton(
                      onPressed: item['stok'] > 0 ? () => tambahKeKeranjang(item) : null,
                      child: Text(item['stok'] > 0 ? 'Tambah' : 'Habis'),
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
              ),
              onPressed: _keranjang.isNotEmpty ? prosesPembayaran : null,
              child: const Text('BAYAR', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
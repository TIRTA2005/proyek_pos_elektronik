import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/currency_format.dart';

class KatalogBarangScreen extends StatefulWidget {
  const KatalogBarangScreen({super.key});

  @override
  State<KatalogBarangScreen> createState() => _KatalogBarangScreenState();
}

class _KatalogBarangScreenState extends State<KatalogBarangScreen> {
  final String apiBarang = "http://10.0.2.2:8000/api/barang";
  List<Barang> _barangList = [];
  List<Barang> _filteredBarangList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBarang() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse(apiBarang),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        setState(() {
          _barangList = data.map((json) => Barang.fromJson(json)).toList();
          _filteredBarangList = _barangList;
          _isLoading = false;
        });
      } else {
        _showError('Gagal memuat data dari server');
      }
    } catch (e) {
      _showError('Tidak ada koneksi atau server mati: $e');
    }
  }

  void _filterPencarian(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredBarangList = _barangList;
      });
    } else {
      setState(() {
        _filteredBarangList = _barangList
            .where((barang) => barang.namaBarang.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _tampilkanKeranjang() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Detail Keranjang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: cartProvider.keranjang.isEmpty
                        ? const Center(child: Text('Keranjang kosong'))
                        : ListView.builder(
                            itemCount: cartProvider.keranjang.length,
                            itemBuilder: (context, index) {
                              final item = cartProvider.keranjang[index];
                              return ListTile(
                                title: Text(item.barang.namaBarang),
                                subtitle: Text('${CurrencyFormat.convertToIdr(item.barang.harga)} x ${item.kuantitas} = ${CurrencyFormat.convertToIdr(item.subtotal)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => cartProvider.kurangiDariKeranjang(item.barang),
                                    ),
                                    Text('${item.kuantitas}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: () => cartProvider.tambahKeKeranjang(item.barang),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _tampilkanStruk(BuildContext context, int totalDibayar, List keranjangDibayar) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Struk Pembayaran', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text('Kasir: ${authProvider.userName}'),
              const Divider(),
              ...keranjangDibayar.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${item.barang.namaBarang} (x${item.kuantitas})', overflow: TextOverflow.ellipsis)),
                    Text(CurrencyFormat.convertToIdr(item.subtotal)),
                  ],
                ),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(CurrencyFormat.convertToIdr(totalDibayar), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
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

  void _prosesPembayaran() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (cartProvider.keranjang.isEmpty) return;

    final totalDibayar = cartProvider.totalHarga;
    final keranjangDibayar = List.from(cartProvider.keranjang);

    bool success = await cartProvider.prosesPembayaran(authProvider.token);

    if (success) {
      cartProvider.clearKeranjang();
      fetchBarang();
      if (mounted) {
        _tampilkanStruk(context, totalDibayar, keranjangDibayar);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses pembayaran'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog POS'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login'); 
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPencarian,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBarangList.isEmpty
                    ? const Center(child: Text('Tidak ada barang tersedia.'))
                    : ListView.builder(
                        itemCount: _filteredBarangList.length,
                        itemBuilder: (context, index) {
                          final item = _filteredBarangList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: item.imageUrl != null 
                                  ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.cable, color: Colors.blueAccent, size: 40))
                                  : const Icon(Icons.cable, color: Colors.blueAccent, size: 40),
                              title: Text(item.namaBarang, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Stok: ${item.stok} \n${CurrencyFormat.convertToIdr(item.harga)}'),
                              trailing: ElevatedButton(
                                onPressed: item.stok > 0 
                                    ? () {
                                        Provider.of<CartProvider>(context, listen: false).tambahKeKeranjang(item);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${item.namaBarang} ditambahkan'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(item.stok > 0 ? 'Tambah' : 'Habis'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _tampilkanKeranjang,
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Item: ${cartProvider.totalItem}\nTotal: ${CurrencyFormat.convertToIdr(cartProvider.totalHarga)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                  ),
                  onPressed: cartProvider.totalItem > 0 ? _prosesPembayaran : null,
                  child: const Text('BAYAR', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

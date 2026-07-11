import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/barang.dart';
import '../utils/currency_format.dart';

class ManajemenBarangScreen extends StatefulWidget {
  const ManajemenBarangScreen({super.key});

  @override
  State<ManajemenBarangScreen> createState() => _ManajemenBarangScreenState();
}

class _ManajemenBarangScreenState extends State<ManajemenBarangScreen> {
  final String apiUrl = "http://10.0.2.2:8000/api/barang";
  List<Barang> _barangList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        setState(() {
          _barangList = data.map((json) => Barang.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        _showError('Gagal memuat barang');
      }
    } catch (e) {
      _showError('Koneksi error: $e');
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  void _hapusBarang(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
          'Accept': 'application/json',
        }
      );
      if (response.statusCode == 200) {
        _fetchBarang();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barang dihapus'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      _showError('Gagal menghapus');
    }
  }

  void _tampilkanFormBarang({Barang? barang}) {
    final namaController = TextEditingController(text: barang?.namaBarang);
    final deskripsiController = TextEditingController(text: barang?.deskripsi);
    final hargaController = TextEditingController(text: barang?.harga.toString());
    final stokController = TextEditingController(text: barang?.stok.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(barang == null ? 'Tambah Barang' : 'Edit Barang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama Barang')),
                TextField(controller: deskripsiController, decoration: const InputDecoration(labelText: 'Deskripsi')),
                TextField(controller: hargaController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
                TextField(controller: stokController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final body = {
                  'nama_barang': namaController.text,
                  'deskripsi': deskripsiController.text,
                  'harga': hargaController.text,
                  'stok': stokController.text,
                };
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                try {
                  http.Response response;
                  if (barang == null) {
                    response = await http.post(
                      Uri.parse(apiUrl),
                      headers: {'Authorization': 'Bearer ${authProvider.token}', 'Accept': 'application/json'},
                      body: body,
                    );
                  } else {
                    response = await http.put(
                      Uri.parse('$apiUrl/${barang.id}'),
                      headers: {'Authorization': 'Bearer ${authProvider.token}', 'Accept': 'application/json'},
                      body: body,
                    );
                  }
                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);
                    _fetchBarang();
                  } else {
                    Navigator.pop(context);
                    _showError('Gagal menyimpan');
                  }
                } catch (e) {
                  Navigator.pop(context);
                  _showError('Error: $e');
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Barang'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _barangList.length,
            itemBuilder: (context, index) {
              final item = _barangList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(item.namaBarang, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Stok: ${item.stok} | ${CurrencyFormat.convertToIdr(item.harga)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _tampilkanFormBarang(barang: item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _hapusBarang(item.id)),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tampilkanFormBarang(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

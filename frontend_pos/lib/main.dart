import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Aksesoris Elektronik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardProgres(),
    );
  }
}

class DashboardProgres extends StatelessWidget {
  const DashboardProgres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasir Elektronik'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.developer_board, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              'Progres Aplikasi 50%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Nama: I Putu Adi Tirta Saputra'),
            Text('NIM: 240040008'),
            Text('Kelas: BC244'),
            SizedBox(height: 30),
            Text(
              'Status: UI Frontend & Backend Database (SQLite) Siap',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

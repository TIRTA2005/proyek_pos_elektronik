import 'barang.dart';

class KeranjangItem {
  final Barang barang;
  int kuantitas;

  KeranjangItem({
    required this.barang,
    this.kuantitas = 1,
  });

  int get subtotal => barang.harga * kuantitas;

  Map<String, dynamic> toJson() {
    return {
      'id': barang.id,
      'nama': barang.namaBarang,
      'harga': barang.harga,
      'kuantitas': kuantitas,
      'subtotal': subtotal,
    };
  }
}

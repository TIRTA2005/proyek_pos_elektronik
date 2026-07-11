class Barang {
  final int id;
  final String namaBarang;
  final String? deskripsi;
  final int harga;
  final int stok;
  final String? imageUrl;

  Barang({
    required this.id,
    required this.namaBarang,
    this.deskripsi,
    required this.harga,
    required this.stok,
    this.imageUrl,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'],
      harga: json['harga'] is String ? int.parse(json['harga']) : json['harga'],
      stok: json['stok'] is String ? int.parse(json['stok']) : json['stok'],
      imageUrl: json['image_url'],
    );
  }
}

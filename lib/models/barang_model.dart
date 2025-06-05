class Barang {
  final int id_brg;
  final int user_id;
  final String nama;
  final String kode_brg;
  final int stok;
  final double harga_jual;
  final double harga_modal;

  Barang({
    required this.id_brg,
    required this.user_id,
    required this.nama,
    required this.kode_brg,
    required this.stok,
    required this.harga_jual,
    required this.harga_modal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_brg': id_brg,
      'user_id': user_id,
      'nama': nama,
      'kode_brg': kode_brg,
      'stok': stok,
      'harga_jual': harga_jual,
      'harga_modal': harga_modal,
    };
  }

  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      id_brg: map['id_brg'],
      user_id: map['user_id'],
      nama: map['nama'],
      kode_brg: map['kode_brg'],
      stok: map['stok'],
      harga_jual: map['harga_jual'],
      harga_modal: map['harga_modal'],
    );
  }
}
class Beban {
  final int? id_beban;
  final int user_id;
  final String nama_beban;
  final double jumlah_beban;
  final DateTime tanggal_beban;

  Beban({
    this.id_beban,
    required this.user_id,
    required this.nama_beban,
    required this.jumlah_beban,
    required this.tanggal_beban,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_beban': id_beban,
      'user_id': user_id,
      'nama_beban': nama_beban,
      'jumlah_beban': jumlah_beban,
      'tanggal_beban': tanggal_beban.toIso8601String(),
    };
  }

  factory Beban.fromMap(Map<String, dynamic> map) {
    return Beban(
      id_beban: map['id_beban'],
      user_id: map['user_id'],
      nama_beban: map['nama_beban'],
      jumlah_beban: map['jumlah_beban'],
      tanggal_beban: DateTime.parse(map['tanggal_beban']),
    );
  }
}

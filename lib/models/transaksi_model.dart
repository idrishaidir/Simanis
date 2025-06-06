import 'dart:convert';

class Transaksi {
  final int id_trs;
  final int user_id;
  final List<Map<String, dynamic>> barangList;
  final double totalJual;
  final double totalModal;
  final double dibayar;
  final double kembalian;
  final DateTime tanggal;

  Transaksi({
    required this.id_trs,
    required this.user_id,
    required this.barangList,
    required this.totalJual,
    required this.totalModal,
    required this.dibayar,
    required this.kembalian,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_trs': id_trs,
      'user_id': user_id,
      'barangList': barangList,
      'totalJual': totalJual,
      'totalModal': totalModal,
      'dibayar': dibayar,
      'kembalian': kembalian,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id_trs: map['id_trs'],

      user_id: int.parse(map['user_id'].toString()),

      barangList:
          map['barangList'] is String
              ? List<Map<String, dynamic>>.from(jsonDecode(map['barangList']))
              : List<Map<String, dynamic>>.from(map['barangList']),
      totalJual: map['totalJual'],
      totalModal: map['totalModal'],
      dibayar: map['dibayar'],
      kembalian: map['kembalian'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }
}

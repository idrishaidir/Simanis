import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../config/database.dart';
import 'dart:convert';

class TransaksiProvider with ChangeNotifier {
  List<Transaksi> _list = [];
  double _totalLaba = 0.0;
  bool _isLoading = false;

  List<Transaksi> get transaksiList => [..._list];
  double get totalLaba => _totalLaba;
  bool get isLoading => _isLoading;

  Future<void> tambahTransaksi(Transaksi t) async {
    final db = await DatabaseHelper.database;
    final Map<String, dynamic> dataToInsert = {
      ...t.toMap(),
      'barangList': jsonEncode(t.barangList),
    };

    await db.insert('transaksi', dataToInsert);
    _list.add(t);
    notifyListeners();
  }

  Future<void> fetchAndCalculateLaba({
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      whereClause = 'tanggal BETWEEN ? AND ?';
      whereArgs = [startDate, endDate];
    }

    final List<Map<String, dynamic>> data = await db.query(
      'transaksi',
      where: whereClause,
      whereArgs: whereArgs,
    );

    _list =
        data.map((item) {
          final rawBarangList = item['barangList'];
          List<Map<String, dynamic>> decodedBarangList = [];
          if (rawBarangList is String) {
            decodedBarangList = List<Map<String, dynamic>>.from(
              jsonDecode(rawBarangList),
            );
          }

          return Transaksi(
            id_trs: item['id_trs'],
            user_id: int.parse(item['user_id'].toString()),
            barangList: decodedBarangList,
            totalJual: item['totalJual'],
            totalModal: item['totalModal'],
            dibayar: item['dibayar'],
            kembalian: item['kembalian'],
            tanggal: DateTime.parse(item['tanggal']),
          );
        }).toList();

    double totalPenjualan = 0.0;
    double totalModal = 0.0;
    for (var trx in _list) {
      totalPenjualan += trx.totalJual;
      totalModal += trx.totalModal;
    }

    _totalLaba = totalPenjualan - totalModal;
    _isLoading = false;
    notifyListeners();
  }
}

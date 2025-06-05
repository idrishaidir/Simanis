import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
import '../models/transaksi_model.dart';
import '../config/database.dart';

class TransaksiProvider with ChangeNotifier {
  List<Transaksi> _list = [];

  List<Transaksi> get transaksiList => [..._list];

  Future<void> tambahTransaksi(Transaksi t) async {
    final db = await DatabaseHelper.database;
    await db.insert('transaksi', t.toMap());
    _list.add(t);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import '../models/barang_model.dart';
import '../config/database.dart';

class BarangProvider with ChangeNotifier {
  List<Barang> _barangList = [];

  List<Barang> get barangList => [..._barangList];

  BarangProvider(int user_id) {
    fetchBarang(user_id);
  }

  Future<void> fetchBarang(int user_id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> data = await db.query(
      'barang',
      where: 'user_id = ?',
      whereArgs: [user_id],
    );
    _barangList = data.map((item) => Barang.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> tambahBarang(Barang barang) async {
    final db = await DatabaseHelper.database;
    await db.insert('barang', barang.toMap());
    _barangList.add(barang);
    notifyListeners();
  }

  Future<void> editBarang(int id_brg, Barang barangBaru) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'barang',
      barangBaru.toMap(),
      where: 'id_brg = ?',
      whereArgs: [id_brg],
    );
    final index = _barangList.indexWhere((barang) => barang.id_brg == id_brg);
    if (index >= 0) {
      _barangList[index] = barangBaru;
      notifyListeners();
    }
  }

  Future<void> hapusBarang(int id_brg) async {
    final db = await DatabaseHelper.database;
    await db.delete('barang', where: 'id_brg = ?', whereArgs: [id_brg]);
    _barangList.removeWhere((barang) => barang.id_brg == id_brg);
    notifyListeners();
  }

  Future<void> kurangiStokBarang(int id_brg, int jumlah) async {
    final db = await DatabaseHelper.database;

    // Ambil data barang yang akan dikurangi
    final barangIndex = _barangList.indexWhere((b) => b.id_brg == id_brg);
    if (barangIndex == -1) return;

    final barang = _barangList[barangIndex];
    final stokBaru = barang.stok - jumlah;

    // Update stok di database
    await db.update(
      'barang',
      {'stok': stokBaru},
      where: 'id_brg = ?',
      whereArgs: [id_brg],
    );

    // Update list di memory
    _barangList[barangIndex] = Barang(
      id_brg: barang.id_brg,
      user_id: barang.user_id,
      nama: barang.nama,
      kode_brg: barang.kode_brg,
      stok: stokBaru,
      harga_jual: barang.harga_jual,
      harga_modal: barang.harga_modal
    );

    notifyListeners();
  }

}
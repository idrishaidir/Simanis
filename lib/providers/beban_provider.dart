import 'package:flutter/material.dart';
import '../models/beban_model.dart';
import '../config/database.dart';

class BebanProvider with ChangeNotifier {
  List<Beban> _bebanList = [];
  List<Beban> get bebanList => [..._bebanList];

  Future<void> addBeban(Beban beban) async {
    final db = await DatabaseHelper.database;
    await db.insert('beban', beban.toMap());
    notifyListeners();
  }

  Future<void> updateBeban(Beban beban) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'beban',
      beban.toMap(),
      where: 'id_beban = ?',
      whereArgs: [beban.id_beban],
    );
    final index = _bebanList.indexWhere((b) => b.id_beban == beban.id_beban);
    if (index != -1) {
      _bebanList[index] = beban;
      notifyListeners();
    }
  }

  Future<List<Beban>> fetchBebanByMonth(int userId, int year, int month) async {
    final db = await DatabaseHelper.database;

    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    final List<Map<String, dynamic>> data = await db.query(
      'beban',
      where: 'user_id = ? AND tanggal_beban BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
    );

    _bebanList = data.map((item) => Beban.fromMap(item)).toList();
    notifyListeners();
    return _bebanList;
  }

  Future<void> deleteBeban(int idBeban) async {
    final db = await DatabaseHelper.database;
    await db.delete('beban', where: 'id_beban = ?', whereArgs: [idBeban]);
    _bebanList.removeWhere((beban) => beban.id_beban == idBeban);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/catatan_model.dart';
import '../config/database.dart';

class CatatanProvider with ChangeNotifier {
  List<Catatan> _items = [];
  late int _userId;

  List<Catatan> get items => [..._items];

  CatatanProvider(int userId) {
    _userId = userId;
    fetchAndSetCatatan();
  }

  Future<void> fetchAndSetCatatan() async {
    final db = await DatabaseHelper.database;
    final dataList = await db.query(
      'catatan',
      where: 'user_id = ?',
      whereArgs: [_userId],
    );
    _items = dataList.map((item) => Catatan.fromMap(item)).toList();
    _items.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
    notifyListeners();
  }

  Future<void> addCatatan(String title, String content) async {
    final newCatatan = Catatan(
      title: title,
      content: content,
      lastEdited: DateTime.now(),
      userId: _userId,
    );
    final db = await DatabaseHelper.database;
    await db.insert('catatan', newCatatan.toMap());
    await fetchAndSetCatatan();
  }

  Future<void> updateCatatan(int id, String title, String content) async {
    final updatedCatatan = Catatan(
      id: id,
      title: title,
      content: content,
      lastEdited: DateTime.now(),
      userId: _userId,
    );
    final db = await DatabaseHelper.database;
    await db.update(
      'catatan',
      updatedCatatan.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetCatatan();
  }

  Future<void> deleteCatatan(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('catatan', where: 'id = ?', whereArgs: [id]);
    await fetchAndSetCatatan();
  }
}

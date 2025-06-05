import 'package:flutter/material.dart';
import '../config/database.dart';

class RegisterProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.database;
    final existing = await db.query(
      'profil',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return false; // Email sudah terdaftar
    }

    await db.insert('profil', {
      'nama_usaha': '',
      'alamat': '',
      'hp': '',
      'email': email,
      'foto_profil': '',
      'qrCode': '',
      'password': password,
    });

    final all = await db.query('profil');
    print("All users: $all");

    _isLoading = false;
    notifyListeners();
    return true;
  }
    
}
import 'package:flutter/material.dart';
import '../config/database.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>?> login(String email, password) async {
    print("LOGIN FUNCTION CALLED");
    final db = await DatabaseHelper.database;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await db.query(
        'profil',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      print("login result: $result");
      _isLoading = false;
      notifyListeners();
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
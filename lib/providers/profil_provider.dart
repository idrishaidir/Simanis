import 'package:flutter/material.dart';
import '../models/profil_model.dart';
import '../config/database.dart';

class ProfileProvider with ChangeNotifier {
  StoreProfile? _profile;

  StoreProfile? get profile => _profile;

  // Ambil profile user yang sedang login
  Future<void> getProfile(int id_user) async {
    final db = await DatabaseHelper.database;
    final data = await db.query(
      'profil',
      where: 'id_user = ?',
      whereArgs: [id_user],
    );
    if (data.isNotEmpty) {
      _profile = StoreProfile.fromMap(data.first);
      notifyListeners();
    }
  }

  // Update seluruh data profile user login
  Future<void> updateProfile(StoreProfile updatedProfile) async {
    final db = await DatabaseHelper.database;
    final count = await db.update(
      'profil',
      updatedProfile.toMap(),
      where: 'id_user = ?',
      whereArgs: [updatedProfile.id_user],
    );
    if (count > 0) {
      await getProfile(updatedProfile.id_user);
    }
  }

  // Update satu field profile user login
  Future<void> updateField(int id_user, String field, String value) async {
    final db = await DatabaseHelper.database;
    final count = await db.update(
      'profil',
      {field: value},
      where: 'id_user = ?',
      whereArgs: [id_user],
    );
    if (count > 0) {
      await getProfile(id_user);
    }
  }

  // Future<void> getProfileEmailById(int id_user) async {
  //   final db = await DatabaseHelper.database;
  //   final data = await db.query(
  //     'profil',
  //     columns: ['email'],
  //     where: 'id_user = ?',
  //     whereArgs: [id_user],
  //   );
  //   if (data.isNotEmpty) {
  //     _profile = StoreProfile.fromMap(data.first);
  //     notifyListeners();
  //   } else {
  //     _profile = null;
  //   }
  // }

  Future<StoreProfile?> getProfileByEmail(String email) async {
    final db = await DatabaseHelper.database;
    final data = await db.query(
      'profil',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (data.isNotEmpty) {
      _profile = StoreProfile.fromMap(data.first);
      notifyListeners();
      return _profile!;
    } else {
      _profile = null;
      return null;
      // throw Exception('Profile tidak ditemukan untuk email: $email');
    }
  }
}
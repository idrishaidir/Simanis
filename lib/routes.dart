import 'package:flutter/material.dart';
import 'screens/barang_list_screen.dart';
import 'screens/beranda_page.dart';
import 'screens/profil_screen.dart';
import 'screens/transaksi_screen.dart';
import 'screens/login_screen.dart';

final Map<String, WidgetBuilder> routes = {
  // '/main': (context) => MainPage(),
  '/beranda': (context) => BerandaPage(),
  '/barang': (context) => BarangListScreen(),
  '/profil': (context) => ProfilScreen(id_user: 0),
  '/transaksi': (context) => TransaksiScreen(),
  '/login': (context) => LoginScreen(),
};
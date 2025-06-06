import 'package:SIMANIS_V1/providers/beban_provider.dart';
import 'package:SIMANIS_V1/providers/riwayat_provider.dart';
import 'package:SIMANIS_V1/providers/transaksi_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/barang_provider.dart';
import 'providers/profil_provider.dart';
import 'providers/login_provider.dart';
import 'providers/register_provider.dart';
import 'routes.dart';
import 'screens/beranda_page.dart';
import 'screens/profil_screen.dart';
import 'screens/barang_list_screen.dart';
import 'screens/transaksi_screen.dart';
import 'screens/login_screen.dart';
import 'screens/section_profil/qrcode_screen.dart';
import 'package:SIMANIS_V1/providers/news.provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => BebanProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
      ],
      child: SimanisApp(),
    ),
  );
}

class SimanisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMANIS',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: routes,
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final int id_user;
  MainPage({required this.id_user});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).getProfile(widget.id_user);
    });

    _pages = [
      BerandaPage(),
      ChangeNotifierProvider(
        create: (_) => BarangProvider(widget.id_user),
        child: TransaksiScreen(),
      ),
      Builder(
        builder: (context) {
          final profile =
              Provider.of<ProfileProvider>(context, listen: false).profile;

          if (profile == null)
            return Center(child: CircularProgressIndicator());
          return QRCodeScreen(profile: profile);
        },
      ),
      ChangeNotifierProvider(
        create: (_) => BarangProvider(widget.id_user),
        child: BarangListScreen(),
      ),
      ProfilScreen(id_user: widget.id_user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.qr_code, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stok'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

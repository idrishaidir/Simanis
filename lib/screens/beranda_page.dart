import 'dart:convert';

import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:SIMANIS_V1/providers/riwayat_provider.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/berita/berita_section.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/catatan/catatan_list_screen.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/fiturLaba/cetak_laba_page.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/fitur_menu_section.dart.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/header_section.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/keuntungan_card.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/pembelajaran/simanis_academy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'package:SIMANIS_V1/providers/catatan_provider.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/riwayat_aktivitas.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<dynamic> _allFeatures = [];

  @override
  void initState() {
    super.initState();
    _loadFiturFromJson();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<ProfileProvider>(
            context,
            listen: false,
          ).profile?.id_user ??
          0;
      if (userId != 0) {
        Provider.of<RiwayatProvider>(
          context,
          listen: false,
        ).fetchAktivitas(userId);
      }
    });
  }

  Future<void> _loadFiturFromJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/fitur.json',
      );
      final data = json.decode(response);
      List<dynamic> combinedFeatures = [
        ...data['fiturUtama'],
        ...data['fiturTambahan'],
      ];
      combinedFeatures.removeWhere(
        (fitur) => fitur['title'] == 'Analisis Data',
      );
      setState(() {
        _allFeatures = combinedFeatures;
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  void _handleFiturClick(String title) {
    if (title == "Cetak Laba") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CetakLabaPage()),
      );
    } else if (title == "Catatan") {
      final userId =
          Provider.of<ProfileProvider>(context, listen: false).profile?.id_user;
      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChangeNotifierProvider(
                  create: (_) => CatatanProvider(userId),
                  child: CatatanListScreen(),
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil pengguna.')),
        );
      }
    } else if (title == "Riwayat Aktivitas") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RiwayatAktivitasPage()),
      );
    } else if (title == "Pembelajaran") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SimanisAcademyScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fitur "$title" belum tersedia')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderSection(),
                const SizedBox(height: 20),
                KeuntunganCardSection(),
                const SizedBox(height: 20),
                FiturMenuSection(
                  allFeatures: _allFeatures,
                  handleFiturClick: _handleFiturClick,
                ),
                const SizedBox(height: 20),
                BeritaSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

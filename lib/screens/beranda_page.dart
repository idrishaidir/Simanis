import 'dart:convert';

import 'package:SIMANIS_V1/providers/riwayat_provider.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/fiturLaba/cetak_laba_page.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/berita/berita_section.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/fitur_menu_section.dart.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/keuntungan_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/riwayat_aktivitas.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/catatan_hutang.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/header_section.dart';

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
    } else if (title == "Catatan Hutang") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CatatanHutangPage()),
      );
    } else if (title == "Riwayat Aktivitas") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RiwayatAktivitasPage()),
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

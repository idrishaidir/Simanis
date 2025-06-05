import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';
import 'package:SIMANIS_V1/screens/section_beranda/berita_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'profil_screen.dart';
import '../providers/profil_provider.dart';
import 'beranda_pages/analisis_data_page.dart';
import 'beranda_pages/cetak_laba_page.dart';
import 'beranda_pages/pembelajaran_page.dart';
import 'beranda_pages/riwayat_aktivitas.dart';
import 'beranda_pages/catatan_hutang.dart';
// import '../models/profil_model.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  bool _showMoreFeatures = false;
  List<dynamic> _fiturUtama = [];
  List<dynamic> _fiturTambahan = [];

  @override
  void initState() {
    super.initState();
    _loadFiturFromJson();
  }

  Future<void> _loadFiturFromJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/fitur.json',
        // '../assets/json/fitur.json',
      );
      final data = json.decode(response);
      setState(() {
        _fiturUtama = data['fiturUtama'];
        _fiturTambahan = data['fiturTambahan'];
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  // Kode Fitur
  void _handleFiturClick(String title) {
    if (title == "Analisis Data") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnalisisDataPage()),
      );
    } else if (title == "Cetak Laba") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CetakLabaPage()),
      );
    } else if (title == "Pembelajaran") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PembelajaranPage()),
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

  Widget _iconMenu(String title, {String? iconPath, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child:
                  iconPath != null
                      ? Image.asset(
                        iconPath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        color: const Color.fromARGB(255, 255, 0, 0),
                        width: 60,
                        height: 60,
                      ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildFiturRow(List<dynamic> fiturList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          fiturList
              .map<Widget>(
                (item) => _iconMenu(
                  item['title'],
                  iconPath: item['icon'],
                  onTap: () => _handleFiturClick(item['title']),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profil = Provider.of<ProfileProvider>(context).profile;
    // final String baseUrl = 'http://192.168.218.171:8000/storage/img-user/';
    final String? photoFile = profil?.foto_profil;

    ImageProvider imageProvider;
    if (photoFile != null && photoFile.isNotEmpty) {
      imageProvider = FileImage(File(photoFile));
    } else {
      imageProvider = const AssetImage('assets/icons/default-user-image.png');
    }
    final String? namaUsaha = profil?.nama_usaha;

    // if (photoUrl != null && photoUrl.isNotEmpty) {
    //   if (photoUrl.startsWith('/')) {
    //     // Path file lokal
    //     imageProvider = FileImage(File(photoUrl));
    //   } else {
    //     // Asumsi base64
    //     imageProvider = MemoryImage(base64Decode(photoUrl));
    //   }
    // }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilScreen(id_user: profil?.id_user ?? 0)),
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        backgroundImage: imageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      namaUsaha ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_none),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 101, 50, 50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Text(
                            "Keuntungan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text("Riwayat"),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Rp100.000,00",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      Text(
                        "Keuntungan Hari Ini",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Rp100.000,00",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Fitur",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                buildFiturRow(_fiturUtama),
                const SizedBox(height: 10),
                if (_showMoreFeatures) ...[
                  const SizedBox(height: 10),
                  buildFiturRow(_fiturTambahan),
                  const SizedBox(height: 10),
                ],
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showMoreFeatures = !_showMoreFeatures;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_showMoreFeatures ? "Sembunyikan" : "Lainnya"),
                        Icon(
                          _showMoreFeatures
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                BeritaSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

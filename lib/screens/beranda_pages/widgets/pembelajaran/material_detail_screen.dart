import 'package:SIMANIS_V1/models/pembelajaran_model.dart';
import 'package:flutter/material.dart';

class MaterialDetailScreen extends StatefulWidget {
  final TopikPembelajaran topic;
  const MaterialDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _MaterialDetailScreenState createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  // Ubah _currentMaterial menjadi nullable (bisa bernilai null)
  Materi? _currentMaterial;

  @override
  void initState() {
    super.initState();
    // Tambahkan pengecekan sebelum mengakses materi
    if (widget.topic.materials.isNotEmpty) {
      _currentMaterial = widget.topic.materials.first;
    }
  }

  void _changeMaterial(Materi newMaterial) {
    setState(() {
      _currentMaterial = newMaterial;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada materi, tampilkan pesan di halaman utama
    if (widget.topic.materials.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFD9E4E1),
        appBar: AppBar(
          title: Text(
            widget.topic.title,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Materi untuk topik "${widget.topic.title}" belum tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    // Jika ada materi, tampilkan seperti biasa
    return Scaffold(
      backgroundColor: Color(0xFFD9E4E1),
      appBar: AppBar(
        title: Text(widget.topic.title, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF294855)),
              child: Text(
                widget.topic.title,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ...widget.topic.materials.map((materi) {
              return ListTile(
                title: Text(materi.materialTitle),
                onTap: () => _changeMaterial(materi),
                // Gunakan operator null-safe (?)
                selected: _currentMaterial?.materialId == materi.materialId,
                selectedTileColor: Colors.blue.withOpacity(0.2),
              );
            }).toList(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          // Gunakan null-safe operator dan berikan nilai default string kosong
          _currentMaterial?.content ?? 'Silakan pilih materi dari menu.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}

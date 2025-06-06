import 'package:SIMANIS_V1/models/pembelajaran_model.dart';
import 'package:flutter/material.dart';

class MaterialDetailScreen extends StatefulWidget {
  final TopikPembelajaran topic;
  const MaterialDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _MaterialDetailScreenState createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late Materi _currentMaterial;

  @override
  void initState() {
    super.initState();

    _currentMaterial = widget.topic.materials.first;
  }

  void _changeMaterial(Materi newMaterial) {
    setState(() {
      _currentMaterial = newMaterial;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            child: CircleAvatar(
              child: Text(widget.topic.title.substring(0, 1)),
            ),
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
                selected: _currentMaterial.materialId == materi.materialId,
                selectedTileColor: Colors.blue.withOpacity(0.2),
              );
            }).toList(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          _currentMaterial.content,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}

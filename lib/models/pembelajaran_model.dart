import 'dart:convert';

class TopikPembelajaran {
  final String id;
  final String title;
  final List<Materi> materials;

  TopikPembelajaran({
    required this.id,
    required this.title,
    required this.materials,
  });

  factory TopikPembelajaran.fromMap(Map<String, dynamic> map) {
    var materialsFromJson = map['materials'] as List;
    List<Materi> materialList =
        materialsFromJson.map((i) => Materi.fromMap(i)).toList();

    return TopikPembelajaran(
      id: map['id'],
      title: map['title'],
      materials: materialList,
    );
  }
}

class Materi {
  final String materialId;
  final String materialTitle;
  final String content;

  Materi({
    required this.materialId,
    required this.materialTitle,
    required this.content,
  });

  factory Materi.fromMap(Map<String, dynamic> map) {
    return Materi(
      materialId: map['material_id'],
      materialTitle: map['material_title'],
      content: map['content'],
    );
  }
}

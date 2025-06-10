class Catatan {
  final int? id;
  final String title;
  final String content;
  final DateTime lastEdited;
  final int userId;

  Catatan({
    this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'last_edited': lastEdited.toIso8601String(),
    };
  }

  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      lastEdited: DateTime.parse(map['last_edited']),
    );
  }
}

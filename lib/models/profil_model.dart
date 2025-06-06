class StoreProfile {
  final int id_user;
  final String nama_usaha;
  final String email;
  final String password;
  final String hp;
  final String alamat;
  final String foto_profil;
  final String qrCode;

  StoreProfile({
    required this.id_user,
    required this.nama_usaha,
    required this.email,
    required this.password,
    required this.hp,
    required this.alamat,
    required this.foto_profil,
    required this.qrCode,
  });

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      id_user:
          map['id_user'] is int
              ? map['id_user']
              : int.parse(map['id_user'].toString()),
      nama_usaha: map['nama_usaha'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      hp: map['hp'] ?? '',
      alamat: map['alamat'] ?? '',
      foto_profil: map['foto_profil'] ?? '',
      qrCode: map['qrCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_user': id_user,
      'nama_usaha': nama_usaha,
      'email': email,
      'hp': hp,
      'alamat': alamat,
      'foto_profil': foto_profil,
      'qrCode': qrCode,
    };
  }

  StoreProfile copyWith({
    int? id_user,
    String? nama_usaha,
    String? email,
    String? password,
    String? hp,
    String? alamat,
    String? foto_profil,
    String? qrCode,
  }) {
    return StoreProfile(
      id_user: id_user ?? this.id_user,
      nama_usaha: nama_usaha ?? this.nama_usaha,
      email: email ?? this.email,
      password: password ?? this.password,
      hp: hp ?? this.hp,
      alamat: alamat ?? this.alamat,
      foto_profil: foto_profil ?? this.foto_profil,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}

class StoreProfile {
  final int id_user;
  final String nama_usaha;
  final String email;
  final String password;
  final String hp;
  final String alamat;
  final String foto_profil;
  final String qrCode;
  // final int role;
  // final int status;

  StoreProfile({
    required this.id_user,
    required this.nama_usaha,
    required this.email,
    required this.password,
    required this.hp,
    required this.alamat,
    required this.foto_profil,
    required this.qrCode,
    // required this.role,
    // required this.status,
  });

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      id_user: map['id_user'] is int ? map['id_user'] : int.parse(map['id_user'].toString()),
      nama_usaha: map['nama_usaha'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      hp: map['hp'] ?? '',
      alamat: map['alamat'] ?? '',
      foto_profil: map['foto_profil'] ?? '',
      qrCode: map['qrCode'] ?? '',
      // role: map['role'] is int ? map['role'] : int.tryParse(map['role'].toString()) ?? 0,
      // status: map['status'] is int ? map['status'] : int.tryParse(map['status'].toString()) ?? 0,
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
      // 'role': role,
      // 'status': status,
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
    // int? role,
    // int? status,
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
      // role: role ?? this.role,
      // status: status ?? this.status,
    );
  }
}
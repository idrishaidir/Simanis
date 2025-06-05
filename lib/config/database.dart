import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = "simanis.db";
  static final _dbVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);

    // Hapus dulu database lama (sementara, untuk pengembangan saja!)
    // await deleteDatabase(path); // ← HATI-HATI: jangan simpan ini di produksi

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  //   final db = await database;
  //   final result = await db.query(
  //     'profil',
  //     where: 'email = ? AND password = ?',
  //     whereArgs: [email, password],
  //   );
  //   if (result.isNotEmpty) {
  //     return result.first;
  //   }
  //   return null;
  // }

  // static Future<Map<String, dynamic>?> getProfileById(int id_user) async {
  //   final db = await database;
  //   final result = await db.query(
  //     'profil',
  //     where: 'id_user = ?',
  //     whereArgs: [id_user],
  //   );
  //   if (result.isNotEmpty) {
  //     return result.first;
  //   }
  //   return null;
  // }

  // static Future<bool> registerUser(String email, String password) async {
  //   final db = await database;
  //   // Cek apakah email sudah ada
  //   final existing = await db.query(
  //     'profil',
  //     where: 'email = ?',
  //     whereArgs: [email],
  //   );
  //   if (existing.isNotEmpty) return false;

  //   await db.insert('profil', {
  //     // 'id': DateTime.now().millisecondsSinceEpoch.toString(),
  //     'nama_usaha': '',
  //     'alamat': '',
  //     'hp': '',
  //     'email': email,
  //     'foto_profil': '',
  //     'qrCode': '',
  //     'password': password,
  //   });
  //   return true;
  // }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profil (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_usaha TEXT(50),
        alamat TEXT(150),
        hp TEXT(20),
        email TEXT(50) UNIQUE,
        foto_profil TEXT(150),
        qrCode TEXT(100),
        password TEXT(35) NOT NULL
      )
    ''');

    // await db.insert('profil', {
    //  'id': '1',
    //  'nama_usaha': '',
    //  'alamat': '',
    //  'hp': '',
    //  'email': '',
    //  'foto_profil': '',
    //  'qrCode': '',
    //  'password': ''
    //  });

    await db.execute('''
      CREATE TABLE barang (
        id_brg INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INT,
        nama TEXT(50),
        kode_brg TEXT(20) UNIQUE,
        stok INTEGER(10) DEFAULT 0,
        harga_jual REAL,
        harga_modal REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id_trs INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        barangList TEXT,
        totalJual REAL,
        totalModal REAL,
        dibayar REAL,
        kembalian REAL,
        tanggal TEXT
      )
    ''');

  }
}
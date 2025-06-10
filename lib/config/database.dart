import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = "simanis.db";
  static final _dbVersion = 2;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);

    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE beban (
          id_beban INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nama_beban TEXT NOT NULL,
          jumlah_beban REAL NOT NULL,
          tanggal_beban TEXT NOT NULL
        )
      ''');
    }
  }

  static Future _createTables(Database db) async {
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

    await db.execute('''
      CREATE TABLE barang (
        id_brg INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INT,
        nama TEXT(50),
        kode_brg TEXT(20) UNIQUE,
        stok INTEGER(15) DEFAULT 0,
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

    await db.execute('''
      CREATE TABLE beban (
        id_beban INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama_beban TEXT NOT NULL,
        jumlah_beban REAL NOT NULL,
        tanggal_beban TEXT NOT NULL
      )
    ''');
  }
}

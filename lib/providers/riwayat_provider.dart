import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/database.dart';
import '../models/beban_model.dart';
import '../models/riwayat_model.dart';
import '../models/transaksi_model.dart';

class RiwayatProvider with ChangeNotifier {
  List<AktivitasItem> _semuaAktivitas = [];
  List<AktivitasItem> _aktivitasYangTampil = [];
  bool _isLoading = false;
  double _totalLabaBersih = 0.0; // Variabel baru untuk menyimpan laba bersih

  String _queryPencarian = '';

  List<AktivitasItem> get aktivitas => _aktivitasYangTampil;
  bool get isLoading => _isLoading;

  // Mengubah getter untuk mengembalikan nilai laba bersih yang sudah dihitung
  double get totalKeuntungan {
    return _totalLabaBersih;
  }

  double get keuntunganHariIni {
    if (_semuaAktivitas.isEmpty) return 0.0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aktivitasHariIni =
        _semuaAktivitas.where((item) {
          return item.tanggal.year == today.year &&
              item.tanggal.month == today.month &&
              item.tanggal.day == today.day;
        }).toList();
    double pendapatan = aktivitasHariIni
        .where((item) => item.tipe == 'Uang Masuk')
        .fold(0.0, (sum, item) => sum + item.jumlah);
    return pendapatan;
  }

  Future<void> fetchAktivitas(int userId) async {
    _isLoading = true;
    notifyListeners();
    final db = await DatabaseHelper.database;

    // --- AWAL PERHITUNGAN LABA BERSIH KESELURUHAN ---

    // 1. Ambil semua data transaksi & beban
    final List<Map<String, dynamic>> transaksiData = await db.query(
      'transaksi',
      where: 'user_id = ?',
      whereArgs: [userId.toString()],
    );
    final List<Transaksi> semuaTransaksi =
        transaksiData.map((item) => Transaksi.fromMap(item)).toList();

    final List<Map<String, dynamic>> bebanData = await db.query(
      'beban',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final List<Beban> semuaBeban =
        bebanData.map((item) => Beban.fromMap(item)).toList();

    // 2. Kalkulasi setiap komponen
    double totalPendapatan = semuaTransaksi.fold(
      0.0,
      (sum, trx) => sum + trx.totalJual,
    );
    double totalHpp = semuaTransaksi.fold(
      0.0,
      (sum, trx) => sum + trx.totalModal,
    );
    double totalBebanOperasional = semuaBeban
        .where((beban) => !beban.nama_beban.startsWith("Pembelian Stok:"))
        .fold(0.0, (sum, beban) => sum + beban.jumlah_beban);

    // 3. Hitung laba bersih total dan simpan
    _totalLabaBersih = totalPendapatan - totalHpp - totalBebanOperasional;

    // --- AKHIR PERHITUNGAN LABA BERSIH ---

    // Kode di bawah ini untuk membangun daftar riwayat aktivitas tetap sama
    final List<AktivitasItem> aktivitasMasuk =
        semuaTransaksi.map((trx) {
          return AktivitasItem(
            id: '#TRX${trx.id_trs}',
            tipe: 'Uang Masuk',
            jumlah: trx.totalJual,
            tanggal: trx.tanggal,
          );
        }).toList();
    final List<AktivitasItem> aktivitasKeluar =
        semuaBeban.map((beban) {
          return AktivitasItem(
            id: '#BBN${beban.id_beban}',
            tipe: 'Uang Keluar',
            jumlah: beban.jumlah_beban,
            tanggal: beban.tanggal_beban,
          );
        }).toList();
    _semuaAktivitas = [...aktivitasMasuk, ...aktivitasKeluar];
    _semuaAktivitas.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    _aktivitasYangTampil = _semuaAktivitas;
    _isLoading = false;
    notifyListeners();
  }

  void filterAktivitas({
    String? query,
    DateTime? tanggalMulai,
    DateTime? tanggalAkhir,
  }) {
    _queryPencarian = query?.toLowerCase() ?? _queryPencarian;
    List<AktivitasItem> hasilFilter = _semuaAktivitas;

    if (_queryPencarian.isNotEmpty) {
      hasilFilter =
          hasilFilter.where((item) {
            final cekId = item.id.toLowerCase().contains(_queryPencarian);
            final cekJumlah = item.jumlah
                .toStringAsFixed(0)
                .contains(_queryPencarian);
            final cekBulan = DateFormat(
              'MMMM',
              'id_ID',
            ).format(item.tanggal).toLowerCase().contains(_queryPencarian);
            return cekId || cekJumlah || cekBulan;
          }).toList();
    }

    if (tanggalMulai != null) {
      final startDate = DateTime(
        tanggalMulai.year,
        tanggalMulai.month,
        tanggalMulai.day,
      );
      hasilFilter =
          hasilFilter
              .where((item) => !item.tanggal.isBefore(startDate))
              .toList();
    }

    if (tanggalAkhir != null) {
      final endDate = DateTime(
        tanggalAkhir.year,
        tanggalAkhir.month,
        tanggalAkhir.day,
      ).add(Duration(days: 1));
      hasilFilter =
          hasilFilter.where((item) => item.tanggal.isBefore(endDate)).toList();
    }

    _aktivitasYangTampil = hasilFilter;
    notifyListeners();
  }

  void resetFilter() {
    _queryPencarian = '';
    _aktivitasYangTampil = _semuaAktivitas;
    notifyListeners();
  }
}

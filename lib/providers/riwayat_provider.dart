import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/database.dart';
import '../models/beban_model.dart';
import '../models/riwayat_model.dart'; // Pastikan import ini ada
import '../models/transaksi_model.dart';

class RiwayatProvider with ChangeNotifier {
  List<AktivitasItem> _semuaAktivitas = [];
  List<AktivitasItem> _aktivitasYangTampil = [];
  bool _isLoading = false;

  String _queryPencarian = '';
  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;

  List<AktivitasItem> get aktivitas => _aktivitasYangTampil;
  bool get isLoading => _isLoading;

  double get totalKeuntungan {
    if (_semuaAktivitas.isEmpty) return 0.0;

    double pendapatan = _semuaAktivitas
        .where((item) => item.tipe == 'Uang Masuk')
        .fold(0.0, (sum, item) => sum + item.jumlah);

    double pengeluaran = _semuaAktivitas
        .where((item) => item.tipe == 'Uang Keluar')
        .fold(0.0, (sum, item) => sum + item.jumlah);

    return pendapatan - pengeluaran;
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

    double pengeluaran = aktivitasHariIni
        .where((item) => item.tipe == 'Uang Keluar')
        .fold(0.0, (sum, item) => sum + item.jumlah);

    return pendapatan - pengeluaran;
  }

  Future<void> fetchAktivitas(int userId) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> transaksiData = await db.query(
      'transaksi',
      where: 'user_id = ?',
      whereArgs: [userId.toString()],
    );

    final List<AktivitasItem> aktivitasMasuk =
        transaksiData.map((item) {
          final trx = Transaksi.fromMap(item);
          return AktivitasItem(
            id: '#TRX${trx.id_trs}',
            tipe: 'Uang Masuk',
            jumlah: trx.totalJual,
            tanggal: trx.tanggal,
          );
        }).toList();

    final List<Map<String, dynamic>> bebanData = await db.query(
      'beban',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final List<AktivitasItem> aktivitasKeluar =
        bebanData.map((item) {
          final beban = Beban.fromMap(item);
          return AktivitasItem(
            id: '#BBN${beban.id_beban}',
            tipe: 'Uang Keluar',
            jumlah: beban.jumlah_beban,
            tanggal: beban.tanggal_beban,
          );
        }).toList();

    _semuaAktivitas = [...aktivitasMasuk, ...aktivitasKeluar];
    _semuaAktivitas.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    resetFilter();
    _isLoading = false;
    notifyListeners();
  }

  void filterAktivitas({
    String? query,
    DateTime? tanggalMulai,
    DateTime? tanggalAkhir,
  }) {
    _queryPencarian = query?.toLowerCase() ?? _queryPencarian;
    _tanggalMulai = tanggalMulai ?? _tanggalMulai;
    _tanggalAkhir = tanggalAkhir ?? _tanggalAkhir;

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

    if (_tanggalMulai != null) {
      hasilFilter =
          hasilFilter
              .where((item) => !item.tanggal.isBefore(_tanggalMulai!))
              .toList();
    }
    if (_tanggalAkhir != null) {
      final tanggalAkhirInklusif = _tanggalAkhir!.add(Duration(days: 1));
      hasilFilter =
          hasilFilter
              .where((item) => item.tanggal.isBefore(tanggalAkhirInklusif))
              .toList();
    }

    _aktivitasYangTampil = hasilFilter;
    notifyListeners();
  }

  void resetFilter() {
    _queryPencarian = '';
    _tanggalMulai = null;
    _tanggalAkhir = null;
    _aktivitasYangTampil = _semuaAktivitas;
  }
}

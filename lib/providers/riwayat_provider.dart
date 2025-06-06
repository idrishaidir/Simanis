import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    await Future.delayed(Duration(seconds: 1));
    _semuaAktivitas = [
      AktivitasItem(
        id: '#TRX001',
        tipe: 'Uang Masuk',
        jumlah: 75000,
        tanggal: DateTime(2025, 1, 15),
      ),
      AktivitasItem(
        id: '#TRX002',
        tipe: 'Uang Masuk',
        jumlah: 120000,
        tanggal: DateTime(2025, 1, 20),
      ),
      AktivitasItem(
        id: '#TRX003',
        tipe: 'Uang Masuk',
        jumlah: 50000,
        tanggal: DateTime.now(),
      ),
      AktivitasItem(
        id: '#TRX004',
        tipe: 'Uang Keluar',
        jumlah: 35000,
        tanggal: DateTime.now(),
      ),
      AktivitasItem(
        id: '#TRX005',
        tipe: 'Uang Masuk',
        jumlah: 75000,
        tanggal: DateTime(2025, 3, 1),
      ),
    ];

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

class AktivitasItem {
  final String id;
  final String tipe;
  final double jumlah;
  final DateTime tanggal;

  AktivitasItem({
    required this.id,
    required this.tipe,
    required this.jumlah,
    required this.tanggal,
  });
}

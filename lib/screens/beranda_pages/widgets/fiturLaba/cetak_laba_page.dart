import 'package:SIMANIS_V1/helpers/pdf_export_service.dart';
import 'package:SIMANIS_V1/providers/beban_provider.dart';
import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:SIMANIS_V1/providers/transaksi_provider.dart';
import 'package:SIMANIS_V1/screens/beranda_pages/widgets/fiturLaba/report_bulanan_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'beban_form_screen.dart';
import 'laporan_detail_screen.dart';

class CetakLabaPage extends StatefulWidget {
  @override
  _CetakLabaPageState createState() => _CetakLabaPageState();
}

class _CetakLabaPageState extends State<CetakLabaPage> {
  late int userId;
  String? _namaUsaha;
  Map<String, Map<String, double>> monthlyData = {};
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _downloadingMonth;

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    userId = profileProvider.profile?.id_user ?? 0;
    _namaUsaha = profileProvider.profile?.nama_usaha ?? "Nama Usaha";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);

    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    await transaksiProvider.fetchAndCalculateLaba();

    Map<String, Map<String, double>> data = {};
    for (var trx in transaksiProvider.transaksiList) {
      String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(trx.tanggal);
      data.putIfAbsent(
        monthYear,
        () => {
          'labaKotor': 0,
          'year': trx.tanggal.year.toDouble(),
          'month': trx.tanggal.month.toDouble(),
        },
      );
      data[monthYear]!['labaKotor'] =
          (data[monthYear]!['labaKotor'] ?? 0) + trx.totalJual;
    }

    if (mounted)
      setState(() {
        monthlyData = data;
        _isLoading = false;
      });
  }

  Future<void> _handleShare(String monthYear) async {
    if (mounted)
      setState(() {
        _isDownloading = true;
        _downloadingMonth = monthYear;
      });

    final date = DateTime(
      monthlyData[monthYear]!['year']!.toInt(),
      monthlyData[monthYear]!['month']!.toInt(),
    );

    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    final bebanProvider = Provider.of<BebanProvider>(context, listen: false);

    await transaksiProvider.fetchAndCalculateLaba(
      startDate: DateTime(date.year, date.month, 1).toIso8601String(),
      endDate:
          DateTime(date.year, date.month + 1, 0, 23, 59, 59).toIso8601String(),
    );
    await bebanProvider.fetchBebanByMonth(userId, date.year, date.month);

    await PdfExportService().generateAndSharePdf(
      namaUsaha: _namaUsaha!,
      periode: date,
      listTransaksi: transaksiProvider.transaksiList,
      listBeban: bebanProvider.bebanList,
    );

    if (mounted)
      setState(() {
        _isDownloading = false;
        _downloadingMonth = null;
      });
  }

  void _handleIsiBeban(String monthYear) {
    final date = DateTime(
      monthlyData[monthYear]!['year']!.toInt(),
      monthlyData[monthYear]!['month']!.toInt(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BebanFormScreen(selectedDate: date)),
    ).then((_) => _loadData());
  }

  Future<void> _handleLihatLaporan(String monthYear) async {
    final date = DateTime(
      monthlyData[monthYear]!['year']!.toInt(),
      monthlyData[monthYear]!['month']!.toInt(),
    );
    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    final bebanProvider = Provider.of<BebanProvider>(context, listen: false);

    await transaksiProvider.fetchAndCalculateLaba(
      startDate: DateTime(date.year, date.month, 1).toIso8601String(),
      endDate:
          DateTime(date.year, date.month + 1, 0, 23, 59, 59).toIso8601String(),
    );
    await bebanProvider.fetchBebanByMonth(userId, date.year, date.month);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LaporanDetailScreen(date: date)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    var sortedKeys =
        monthlyData.keys.toList()..sort(
          (a, b) => DateFormat(
            'MMMM yyyy',
            'id_ID',
          ).parse(b).compareTo(DateFormat('MMMM yyyy', 'id_ID').parse(a)),
        );

    return Scaffold(
      backgroundColor: Color(0xFFC4DCD6),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Kembali', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: Column(
                  children: [
                    Text(
                      "Laba",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          String monthYear = sortedKeys[index];
                          double labaKotor =
                              monthlyData[monthYear]!['labaKotor']!;

                          return LaporanBulananCard(
                            monthYear: monthYear,
                            labaKotor: labaKotor,
                            formatter: formatter,
                            isDownloading: _isDownloading,
                            downloadingMonth: _downloadingMonth,
                            onIsiBeban: () => _handleIsiBeban(monthYear),
                            onLihatLaporan:
                                () => _handleLihatLaporan(monthYear),
                            onShare: () => _handleShare(monthYear),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

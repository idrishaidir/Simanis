import 'package:SIMANIS_V1/providers/beban_provider.dart';
import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:SIMANIS_V1/providers/transaksi_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LaporanDetailScreen extends StatelessWidget {
  final DateTime date;
  const LaporanDetailScreen({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    final bebanProvider = Provider.of<BebanProvider>(context, listen: false);

    final Map<String, double> aggregatedBeban = {};
    for (var beban in bebanProvider.bebanList) {
      aggregatedBeban.update(
        beban.nama_beban,
        (value) => value + beban.jumlah_beban,
        ifAbsent: () => beban.jumlah_beban,
      );
    }

    double totalPenjualan = transaksiProvider.transaksiList.fold(
      0,
      (sum, trx) => sum + trx.totalJual,
    );
    double hpp = transaksiProvider.transaksiList.fold(
      0,
      (sum, trx) => sum + trx.totalModal,
    );
    double totalBebanOperasional = bebanProvider.bebanList.fold(
      0,
      (sum, beban) => sum + beban.jumlah_beban,
    );
    double totalBeban = hpp + totalBebanOperasional;
    double labaKotor = totalPenjualan;
    double labaBersih = totalPenjualan - totalBeban;

    Widget _buildRow(String label, String value, {bool isBold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            Text(": ", style: TextStyle(fontSize: 16)),
            Expanded(
              flex: 3,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: EdgeInsets.all(16),
          color: Color(0xFFD9E4E1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                profile?.nama_usaha ?? "Nama Usaha",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Laporan Laba",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Periode ${DateFormat('MMMM Einrichtung').format(date)}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Pendapatan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _buildRow("Penjualan", formatter.format(totalPenjualan)),
              Divider(),
              _buildRow(
                "Total Pendapatan",
                formatter.format(totalPenjualan),
                isBold: true,
              ),
              SizedBox(height: 16),
              Text(
                "Beban",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _buildRow("Harga Pokok Penjualan", formatter.format(hpp)),

              ...aggregatedBeban.entries.map((entry) {
                return _buildRow(entry.key, formatter.format(entry.value));
              }).toList(),

              Divider(),
              _buildRow(
                "Total Beban",
                formatter.format(totalBeban),
                isBold: true,
              ),
              SizedBox(height: 16),
              _buildRow(
                "Laba Kotor",
                formatter.format(labaKotor),
                isBold: true,
              ),
              _buildRow(
                "Laba Bersih",
                formatter.format(labaBersih),
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

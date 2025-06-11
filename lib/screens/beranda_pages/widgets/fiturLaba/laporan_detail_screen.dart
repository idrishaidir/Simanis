import 'package:SIMANIS_V1/models/beban_model.dart';
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

    // 1. Pendapatan (Total Penjualan)
    double totalPendapatan = transaksiProvider.transaksiList.fold(
      0,
      (sum, trx) => sum + trx.totalJual,
    );

    // 2. Harga Pokok Penjualan (HPP)
    double hpp = transaksiProvider.transaksiList.fold(
      0,
      (sum, trx) => sum + trx.totalModal,
    );

    // 3. Beban Operasional (semua beban selain HPP dari pembelian stok)
    final bebanOperasionalSaja =
        bebanProvider.bebanList
            .where((beban) => !beban.nama_beban.startsWith("Pembelian Stok:"))
            .toList();

    // 4. Hitung Total Beban (HPP + Beban Operasional)
    double totalBebanOperasional = bebanOperasionalSaja.fold(
      0,
      (sum, beban) => sum + beban.jumlah_beban,
    );
    double totalBeban = hpp + totalBebanOperasional;

    // 5. Hitung Laba Bersih (Pendapatan - Total Beban)
    double labaBersih = totalPendapatan - totalBeban;

    Widget _buildRow(
      String label,
      String value, {
      bool isBold = false,
      int indent = 0,
      Color? textColor,
    }) {
      return Padding(
        padding: EdgeInsets.fromLTRB(indent * 16.0, 4.0, 8.0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
                color: textColor,
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
        title: Text(
          'Laporan Laba Rugi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFD9E4E1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.nama_usaha ?? "Nama Usaha",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Periode ${DateFormat('MMMM yyyy', 'id_ID').format(date)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 24),

                Text(
                  "Pendapatan:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildRow("Total Penjualan", formatter.format(totalPendapatan)),

                SizedBox(height: 20),

                Text(
                  "Beban-Beban:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildRow(
                  "Harga Pokok Penjualan (HPP)",
                  formatter.format(hpp),
                  indent: 1,
                ),
                ...bebanOperasionalSaja.map((beban) {
                  return _buildRow(
                    beban.nama_beban,
                    formatter.format(beban.jumlah_beban),
                    indent: 1,
                  );
                }).toList(),
                Divider(),
                _buildRow(
                  "Total Beban",
                  formatter.format(totalBeban),
                  isBold: true,
                  indent: 1,
                ),

                SizedBox(height: 16),
                Divider(thickness: 2, color: Colors.black87),

                _buildRow(
                  "LABA BERSIH",
                  formatter.format(labaBersih),
                  isBold: true,
                  textColor:
                      labaBersih >= 0 ? Colors.green[700] : Colors.red[700],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

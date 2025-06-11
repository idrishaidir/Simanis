import 'dart:io';
import 'package:SIMANIS_V1/models/beban_model.dart';
import 'package:SIMANIS_V1/models/transaksi_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> generateAndSharePdf({
    required String namaUsaha,
    required DateTime periode,
    required List<Transaksi> listTransaksi,
    required List<Beban> listBeban,
  }) async {
    final pdf = pw.Document();

    double totalPendapatan = listTransaksi.fold(
      0,
      (sum, trx) => sum + trx.totalJual,
    );
    double hpp = listTransaksi.fold(0, (sum, trx) => sum + trx.totalModal);
    final bebanOperasionalSaja =
        listBeban
            .where((beban) => !beban.nama_beban.startsWith("Pembelian Stok:"))
            .toList();
    double totalBebanOperasional = bebanOperasionalSaja.fold(
      0,
      (sum, beban) => sum + beban.jumlah_beban,
    );
    double totalBeban = hpp + totalBebanOperasional;
    double labaBersih = totalPendapatan - totalBeban;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Column(
                  children: [
                    pw.Text(
                      namaUsaha,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      "Laporan Laba Rugi",
                      style: pw.TextStyle(fontSize: 18),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      "Periode ${DateFormat('MMMM yyyy', 'id_ID').format(periode)}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                "Pendapatan:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              _buildPdfRow(
                "Total Penjualan",
                formatter.format(totalPendapatan),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Beban-Beban:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              _buildPdfRow(
                "Harga Pokok Penjualan (HPP)",
                formatter.format(hpp),
                indent: true,
              ),
              ...bebanOperasionalSaja
                  .map(
                    (beban) => _buildPdfRow(
                      beban.nama_beban,
                      formatter.format(beban.jumlah_beban),
                      indent: true,
                    ),
                  )
                  .toList(),
              pw.Divider(),
              _buildPdfRow(
                "Total Beban",
                "(${formatter.format(totalBeban)})",
                isBold: true,
                indent: true,
              ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 2),

              _buildPdfRow(
                "LABA KOTOR",
                formatter.format(totalPendapatan),
                isBold: true,
              ),
              _buildPdfRow(
                "LABA BERSIH",
                formatter.format(labaBersih),
                isBold: true,
              ),
            ],
          );
        },
      ),
    );

    await _saveAndShare(pdf, periode);
  }

  // ... (fungsi _buildPdfRow dan _saveAndShare tetap sama)
  pw.Widget _buildPdfRow(
    String label,
    String value, {
    bool isBold = false,
    bool indent = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(left: indent ? 16 : 0, top: 4, bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndShare(pw.Document pdf, DateTime periode) async {
    try {
      final Directory dir = await getTemporaryDirectory();
      final String fileName =
          'Laporan-Laba-${DateFormat('MMMM-yyyy').format(periode)}.pdf';
      final String path = '${dir.path}/$fileName';
      final File file = File(path);
      await file.writeAsBytes(await pdf.save());
      final xfile = XFile(path);
      await Share.shareXFiles([
        xfile,
      ], text: 'Berikut adalah laporan laba untuk $fileName');
    } catch (e) {
      print("Error saat membuat atau membagikan PDF: $e");
    }
  }
}

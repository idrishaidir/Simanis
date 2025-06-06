import 'dart:io';
import 'package:SIMANIS_V1/models/beban_model.dart';
import 'package:SIMANIS_V1/models/transaksi_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart'; // Import package baru

class PdfExportService {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Ubah nama fungsi agar lebih sesuai
  Future<void> generateAndSharePdf({
    required String namaUsaha,
    required DateTime periode,
    required List<Transaksi> listTransaksi,
    required List<Beban> listBeban,
  }) async {
    // 1. Bagian pembuatan dokumen PDF (tetap sama)
    final pdf = pw.Document();
    // ... (kode pembuatan halaman PDF tidak perlu diubah, jadi saya singkat di sini)
    // ... Anda bisa biarkan kode pembuatan halaman PDF yang sudah ada ...
    double totalPenjualan = listTransaksi.fold(
      0,
      (sum, trx) => sum + trx.totalJual,
    );
    double hpp = listTransaksi.fold(0, (sum, trx) => sum + trx.totalModal);
    double totalBebanOperasional = listBeban.fold(
      0,
      (sum, beban) => sum + beban.jumlah_beban,
    );
    double totalBeban = hpp + totalBebanOperasional;
    double labaKotor = totalPenjualan;
    double labaBersih = totalPenjualan - totalBeban;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                    ),
                    pw.Text(
                      "Laporan Laba Rugi",
                      style: pw.TextStyle(fontSize: 18),
                    ),
                    pw.Text(
                      "Periode ${DateFormat('MMMM yyyy').format(periode)}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                "Pendapatan",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              _buildPdfRow("Penjualan", formatter.format(totalPenjualan)),
              pw.Divider(),
              _buildPdfRow(
                "Total Pendapatan",
                formatter.format(totalPenjualan),
                isBold: true,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Beban",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              _buildPdfRow("Harga Pokok Penjualan", formatter.format(hpp)),
              ...listBeban
                  .map(
                    (beban) => _buildPdfRow(
                      beban.nama_beban,
                      formatter.format(beban.jumlah_beban),
                    ),
                  )
                  .toList(),
              pw.Divider(),
              _buildPdfRow(
                "Total Beban",
                formatter.format(totalBeban),
                isBold: true,
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              _buildPdfRow(
                "LABA KOTOR",
                formatter.format(labaKotor),
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

    // 2. Simpan ke folder temporary & picu menu Share
    await _saveAndShare(pdf, periode);
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    // ... (fungsi ini tetap sama)
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
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

  // --- FUNGSI INI DIUBAH TOTAL UNTUK MENGGUNAKAN FITUR SHARE ---
  Future<void> _saveAndShare(pw.Document pdf, DateTime periode) async {
    try {
      // Dapatkan direktori cache sementara (tidak butuh izin)
      final Directory dir = await getTemporaryDirectory();
      final String fileName =
          'Laporan-Laba-${DateFormat('MMMM-yyyy').format(periode)}.pdf';
      final String path = '${dir.path}/$fileName';
      final File file = File(path);

      // Simpan file ke cache
      await file.writeAsBytes(await pdf.save());

      // Picu menu Share dari Android menggunakan share_plus
      final xfile = XFile(path); // Konversi path ke XFile
      await Share.shareXFiles([
        xfile,
      ], text: 'Berikut adalah laporan laba untuk $fileName');
    } catch (e) {
      print("Error saat membuat atau membagikan PDF: $e");
    }
  }
}

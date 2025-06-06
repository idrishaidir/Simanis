import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanBulananCard extends StatelessWidget {
  final String monthYear;
  final double labaKotor;
  final NumberFormat formatter;
  final bool isDownloading;
  final String? downloadingMonth;
  final VoidCallback onIsiBeban;
  final VoidCallback onLihatLaporan;
  final VoidCallback onShare;

  const LaporanBulananCard({
    Key? key,
    required this.monthYear,
    required this.labaKotor,
    required this.formatter,
    required this.isDownloading,
    required this.downloadingMonth,
    required this.onIsiBeban,
    required this.onLihatLaporan,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color(0xFFD9E4E1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthYear,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Beban", style: TextStyle(fontSize: 16)),
                Spacer(),
                ElevatedButton(
                  onPressed: onIsiBeban,
                  child: Text("Isi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            _buildInfoRow("Laba", formatter.format(labaKotor)),
            SizedBox(height: 16),
            Row(
              children: [
                (isDownloading && downloadingMonth == monthYear)
                    ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                    : IconButton(onPressed: onShare, icon: Icon(Icons.share)),
                Spacer(),
                ElevatedButton(
                  onPressed: onLihatLaporan,
                  child: Text("Lihat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

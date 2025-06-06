import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/riwayat_model.dart';
import '../../providers/profil_provider.dart';
import '../../providers/riwayat_provider.dart';

class RiwayatAktivitasPage extends StatefulWidget {
  @override
  _RiwayatAktivitasPageState createState() => _RiwayatAktivitasPageState();
}

class _RiwayatAktivitasPageState extends State<RiwayatAktivitasPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _pickedTanggalMulai;
  DateTime? _pickedTanggalAkhir;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<ProfileProvider>(
            context,
            listen: false,
          ).profile?.id_user ??
          0;
      Provider.of<RiwayatProvider>(
        context,
        listen: false,
      ).fetchAktivitas(userId);
    });
  }

  Future<void> _showFilterDialog() async {
    final riwayatProvider = Provider.of<RiwayatProvider>(
      context,
      listen: false,
    );

    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Berdasarkan Tanggal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDatePicker(
                        context,
                        'Dari Tanggal',
                        _pickedTanggalMulai,
                        (date) {
                          setModalState(() => _pickedTanggalMulai = date);
                        },
                      ),
                      _buildDatePicker(
                        context,
                        'Sampai Tanggal',
                        _pickedTanggalAkhir,
                        (date) {
                          setModalState(() => _pickedTanggalAkhir = date);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Reset'),
                        onPressed: () {
                          setModalState(() {
                            _pickedTanggalMulai = null;
                            _pickedTanggalAkhir = null;
                          });
                          riwayatProvider.resetFilter();
                          riwayatProvider.filterAktivitas(
                            query: _searchController.text,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Terapkan'),
                        onPressed: () {
                          riwayatProvider.filterAktivitas(
                            query: _searchController.text,
                            tanggalMulai: _pickedTanggalMulai,
                            tanggalAkhir: _pickedTanggalAkhir,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String title,
    DateTime? initialDate,
    Function(DateTime) onDateChanged,
  ) {
    return Column(
      children: [
        Text(title),
        TextButton(
          child: Text(
            initialDate == null
                ? 'Pilih...'
                : DateFormat('dd/MM/yy').format(initialDate),
          ),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final riwayatProvider = Provider.of<RiwayatProvider>(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final groupedAktivitas = <String, List<AktivitasItem>>{};
    for (var item in riwayatProvider.aktivitas) {
      final now = DateTime.now();
      String monthYearKey;
      if (item.tanggal.year == now.year && item.tanggal.month == now.month) {
        monthYearKey = 'Bulan Ini';
      } else {
        monthYearKey = DateFormat('MMMM yyyy', 'id_ID').format(item.tanggal);
      }

      if (groupedAktivitas[monthYearKey] == null) {
        groupedAktivitas[monthYearKey] = [];
      }
      groupedAktivitas[monthYearKey]!.add(item);
    }

    // --- LOGIKA BARU UNTUK MEMBUAT DAFTAR TAMPILAN ---
    final displayList = [];
    groupedAktivitas.forEach((key, value) {
      displayList.add(key); // Tambah Header (String)
      displayList.addAll(value); // Tambah item transaksi (AktivitasItem)
    });

    return Scaffold(
      backgroundColor: Color(0xFFD9E4E1),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      riwayatProvider.filterAktivitas(
                        query: value,
                        tanggalMulai: _pickedTanggalMulai,
                        tanggalAkhir: _pickedTanggalAkhir,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Transaksi',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.black54),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                riwayatProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : displayList.isEmpty
                    ? Center(
                      child: Text('Tidak ada riwayat transaksi yang cocok.'),
                    )
                    // --- LISTVIEW BARU YANG MENGGUNAKAN GROUPING ---
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];

                        if (item is String) {
                          // Tampilkan Header Bulan
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        } else if (item is AktivitasItem) {
                          // Tampilkan Card Transaksi dengan layout baru
                          final aktivitas = item;
                          bool isUangMasuk = aktivitas.tipe == 'Uang Masuk';
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            color: Color(0xFF355A63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          aktivitas.tipe,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tanggal ${DateFormat('dd-MM-yyyy').format(aktivitas.tanggal)}',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isUangMasuk ? '+' : '-'} ${formatter.format(aktivitas.jumlah)}',
                                        style: TextStyle(
                                          color:
                                              isUangMasuk
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        aktivitas.id,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

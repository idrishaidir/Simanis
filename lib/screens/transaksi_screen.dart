import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:convert';

import '../models/barang_model.dart';
import '../models/transaksi_model.dart';
import '../providers/barang_provider.dart';
import '../providers/transaksi_provider.dart';
import '../providers/profil_provider.dart';

class TransaksiScreen extends StatefulWidget {
  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _bayarController = TextEditingController();

  List<Map<String, dynamic>> _keranjang = [];
  double _totalJual = 0.0;
  double _totalModal = 0.0;
  double _kembalian = 0.0;

  void _addToCart(Barang barang) {
    if (_jumlahController.text.isEmpty ||
        int.tryParse(_jumlahController.text) == null)
      return;
    int jumlah = int.parse(_jumlahController.text);

    // CEK STOK TERSEDIA
    if (jumlah > barang.stok) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Stok Tidak Cukup'),
              content: Text('Stok tersedia hanya ${barang.stok} barang.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    double subtotalJual = jumlah * barang.harga_jual;
    double subtotalModal = jumlah * barang.harga_modal;

    setState(() {
      _keranjang.add({
        'id_brg': barang.id_brg,
        'kode_brg': barang.kode_brg,
        'nama': barang.nama,
        'harga_jual': barang.harga_jual,
        'harga_modal': barang.harga_modal,
        'jumlah': jumlah,
        'subtotalJual': subtotalJual,
      });
      _totalJual += subtotalJual;
      _totalModal += subtotalModal;
    });

    _searchController.clear();
    _jumlahController.clear();
  }

  void _prosesKembalian() {
    double bayar = double.tryParse(_bayarController.text) ?? 0;
    setState(() {
      _kembalian = bayar - _totalJual;
    });
  }

  void _simpanTransaksi() async {
    
    double bayar = double.tryParse(_bayarController.text) ?? 0;

    if (bayar < _totalJual) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Pembayaran Kurang'),
              content: Text('Uang yang dibayarkan kurang dari total belanja.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final user_id = profileProvider.profile?.id_user ?? 0;
    final trx = Transaksi(
      id_trs: DateTime.now().millisecondsSinceEpoch,
      user_id: user_id,
      barangList: _keranjang,
      totalJual: _totalJual,
      totalModal: _totalModal,
      dibayar: bayar,
      kembalian: bayar - _totalJual,
      tanggal: DateTime.now(),
    );

    await transaksiProvider.tambahTransaksi(trx);

    // Kurangi stok barang
    for (var item in _keranjang) {
      await barangProvider.kurangiStokBarang(item['id'], item['jumlah']);
    }

    setState(() {
      _keranjang.clear();
      _totalJual = 0;
      _kembalian = 0;
      _bayarController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Transaksi berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final barangList = Provider.of<BarangProvider>(context).barangList;

    return Scaffold(
      backgroundColor: Color(0xffC0D9D1),
      appBar: AppBar(
        backgroundColor: Color(0xffC0D9D1),
        title: Text(
          'Transaksi Penjualan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Autocomplete<Barang>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return barangList.where(
                    (barang) =>
                        barang.nama.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ) ||
                        barang.kode_brg.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                  );
                },
                displayStringForOption:
                    (Barang barang) => '${barang.nama} (${barang.kode_brg})',
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  _searchController.text = controller.text;
                  return Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Cari Barang',
                        filled: true,
                        fillColor: Color(0xFF305163),
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        // floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onFieldSubmitted: (_) {
                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                        final user_id = profileProvider.profile?.id_user ?? 0;
                        final barang = barangList.firstWhere(
                          (b) =>
                              b.nama.toLowerCase() ==
                                  controller.text.toLowerCase() ||
                              b.kode_brg.toLowerCase() ==
                                  controller.text.toLowerCase(),
                          orElse:
                              () => Barang(
                                id_brg: 0,
                                user_id: user_id,
                                nama: '',
                                kode_brg: '',
                                stok: 0,
                                harga_jual: 0,
                                harga_modal: 0,
                              ),
                        );
                        if (barang.id_brg != '') {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text('Jumlah Beli'),
                                  content: TextFormField(
                                    controller: _jumlahController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Jumlah',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        _addToCart(barang);
                                      },
                                      child: Text('Tambah'),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                    ),
                  );
                },

                onSelected: (Barang barang) {
                  _searchController.text = barang.nama;
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text('Jumlah Beli'),
                          content: TextFormField(
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Jumlah'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _addToCart(barang);
                              },
                              child: Text('Tambah'),
                            ),
                          ],
                        ),
                  );
                },
              ),

              SizedBox(height: 20),
              Text('Keranjang:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._keranjang.map(
                (item) => Card(
                  color: Color(0xFF305163),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      '${item['nama']} x${item['jumlah']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Subtotal: Rp ${item['subtotalJual'].toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _totalJual -= item['subtotalJual'];
                          _keranjang.remove(item);
                        });
                      },
                    ),
                  ),
                ),
              ),
              Divider(),
              Text(
                'Total Modal: Rp ${_totalModal.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Text(
                'Total Jual: Rp ${_totalJual.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),
              TextFormField(
                controller: _bayarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Uang Dibayarkan'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _prosesKembalian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF305163),
                ),
                child: Text(
                  'Konfirmasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kembalian: Rp ${_kembalian.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _keranjang.isEmpty || _bayarController.text.isEmpty
                        ? null
                        : _simpanTransaksi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF305163),
                ),
                child: Text(
                  'Simpan Transaksi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

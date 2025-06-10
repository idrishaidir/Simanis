import 'package:SIMANIS_V1/providers/beban_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang_model.dart';
import '../models/beban_model.dart';
import '../providers/barang_provider.dart';
import '../providers/profil_provider.dart';

class BarangFormScreen extends StatefulWidget {
  final Barang? barang;
  BarangFormScreen({this.barang});

  @override
  _BarangFormScreenState createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends State<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nama;
  late String _kode_brg;
  late int _stok;
  late double _harga_jual;
  late double _harga_modal;

  void _catatBebanPembelianStok(
    int perubahanStok,
    double hargaModal,
    String namaBarang,
    int userId,
  ) {
    if (perubahanStok <= 0) return;

    final bebanProvider = Provider.of<BebanProvider>(context, listen: false);
    final totalBiayaStok = perubahanStok * hargaModal;

    final bebanBaru = Beban(
      user_id: userId,
      nama_beban: "Pembelian Stok: $namaBarang",
      jumlah_beban: totalBiayaStok,
      tanggal_beban: DateTime.now(),
    );

    bebanProvider.addBeban(bebanBaru);
    print("Mencatat beban pembelian stok sebesar: $totalBiayaStok");
  }

  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final barangProvider = Provider.of<BarangProvider>(
        context,
        listen: false,
      );
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final userId = profileProvider.profile?.id_user ?? 0;
      final isEdit = widget.barang != null;

      if (isEdit) {
        final stokLama = widget.barang!.stok;
        final perubahanStok = _stok - stokLama;

        _catatBebanPembelianStok(perubahanStok, _harga_modal, _nama, userId);

        await barangProvider.editBarang(
          widget.barang!.id_brg,
          Barang(
            id_brg: widget.barang!.id_brg,
            user_id: widget.barang!.user_id,
            nama: _nama,
            kode_brg: _kode_brg,
            stok: _stok,
            harga_jual: _harga_jual,
            harga_modal: _harga_modal,
          ),
        );
      } else {
        final barangBaru = Barang(
          id_brg: DateTime.now().millisecondsSinceEpoch,
          user_id: userId,
          nama: _nama,
          kode_brg: _kode_brg,
          stok: _stok,
          harga_jual: _harga_jual,
          harga_modal: _harga_modal,
        );

        await barangProvider.tambahBarang(barangBaru);

        _catatBebanPembelianStok(_stok, _harga_modal, _nama, userId);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      backgroundColor: Color(0xffC0D9D1),
      appBar: AppBar(
        backgroundColor: Color(0xffC0D9D1),
        title: Text(
          isEdit ? 'Edit Barang' : 'Tambah Barang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.nama,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    maxLength: 50,
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Nama Barang Harus diisi';
                      }
                      if (value.length == 1) {
                        return 'Nama Barang terlalu pendek';
                      }
                      if (value.length > 50) {
                        return 'Nama Barang terlalu panjang';
                      }
                      return null;
                    },
                            // value == null || value.isEmpty
                            //     ? 'Harus diisi'
                            //     : null,
                    onSaved: (value) => _nama = value!,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.kode_brg,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Kode Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    maxLength: 20,
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Kode Barang Harus diisi';
                      }
                      if (value.length == 1) {
                        return 'Kode Barang terlalu pendek';
                      }
                      if (value.length > 20) {
                        return 'Kode Barang terlalu panjang';
                      }
                      return null;
                    },
                    onSaved: (value) => _kode_brg = value!,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.stok.toString() ?? '0',
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Stok Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 15,
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Stok Barang Harus diisi';
                      }
                      if (value.length > 15) {
                        return 'Stok Barang terlalu Banyak';
                      }
                      return null;
                    },
                    onSaved: (value) => _stok = int.parse(value!),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.harga_jual.toString() ?? '0',
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Harga Jual Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    maxLength: 20,
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Harga Jual Barang Harus diisi';
                      }
                      if (value.length > 20) {
                        return 'Harga Jual Barang terlalu Mahal';
                      }
                      return null;
                    },
                    onSaved: (value) => _harga_jual = double.parse(value!),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.harga_modal.toString() ?? '0',
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Harga Modal Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    maxLength: 20,
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Harga Modal Barang Harus diisi';
                      }
                      if (value.length > 20) {
                        return 'Harga Modal Barang terlalu Mahal';
                      }
                      return null;
                    },
                    onSaved: (value) => _harga_modal = double.parse(value!),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF305163),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _simpanForm,
                child: Text(
                  isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

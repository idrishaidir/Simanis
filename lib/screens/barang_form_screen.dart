import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang_model.dart';
import '../providers/barang_provider.dart';
import '../providers/profil_provider.dart';
import 'package:uuid/uuid.dart';

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
      
      // body: Padding(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.nama,
                    style: TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna label
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                    onSaved: (value) => _nama = value!,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.kode_brg,
                    style: TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Kode Barang',
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna label
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                    onSaved: (value) => _kode_brg = value!,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.stok.toString(),
                    style: TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Stok Barang',
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna label
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || int.tryParse(value) == null ? 'Masukkan angka' : null,
                    onSaved: (value) => _stok = int.parse(value!),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.harga_jual.toString(),
                    style: TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Harga Jual Barang',
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna label
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || double.tryParse(value) == null ? 'Masukkan harga valid' : null,
                    onSaved: (value) => _harga_jual = double.parse(value!),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                color: Color(0xFF305163),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: widget.barang?.harga_modal.toString(),
                    style: TextStyle(
                      color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Harga Modal Barang',
                      labelStyle: TextStyle(color: Colors.white), // Ubah warna label
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value == null || double.tryParse(value) == null ? 'Masukkan harga valid' : null,
                    onSaved: (value) => _harga_modal = double.parse(value!),
                  ),
                ),
              ),
            
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF305163)
                ),
                child: Text(
                  isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                  style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                  ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
                    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                    final user_id = profileProvider.profile?.id_user ?? 0;

                    if (isEdit) {
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
                      await barangProvider.tambahBarang(
                        Barang(
                          id_brg: DateTime.now().millisecondsSinceEpoch,
                          user_id: user_id,
                          nama: _nama,
                          kode_brg: _kode_brg,
                          stok: _stok,
                          harga_jual: _harga_jual,
                          harga_modal: _harga_modal,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:SIMANIS_V1/providers/beban_provider.dart';
import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:SIMANIS_V1/models/beban_model.dart';

class BebanFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  const BebanFormScreen({Key? key, required this.selectedDate})
    : super(key: key);

  @override
  _BebanFormScreenState createState() => _BebanFormScreenState();
}

class _BebanFormScreenState extends State<BebanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaBebanController = TextEditingController();
  final _jumlahBebanController = TextEditingController();
  late int userId;
  late BebanProvider bebanProvider;

  Beban? _editingBeban;

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    userId = profileProvider.profile?.id_user ?? 0;
    bebanProvider = Provider.of<BebanProvider>(context, listen: false);
    bebanProvider.fetchBebanByMonth(
      userId,
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void _startEditing(Beban beban) {
    setState(() {
      _editingBeban = beban;
      _namaBebanController.text = beban.nama_beban;
      _jumlahBebanController.text = beban.jumlah_beban.toStringAsFixed(0);
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingBeban = null;
      _namaBebanController.clear();
      _jumlahBebanController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_editingBeban == null) {
        final beban = Beban(
          user_id: userId,
          nama_beban: _namaBebanController.text,
          jumlah_beban: double.parse(_jumlahBebanController.text),
          tanggal_beban: widget.selectedDate,
        );
        bebanProvider.addBeban(beban).then((_) {
          bebanProvider.fetchBebanByMonth(
            userId,
            widget.selectedDate.year,
            widget.selectedDate.month,
          );
          _namaBebanController.clear();
          _jumlahBebanController.clear();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Beban berhasil ditambahkan')));
        });
      } else {
        final updatedBeban = Beban(
          id_beban: _editingBeban!.id_beban,
          user_id: _editingBeban!.user_id,
          nama_beban: _namaBebanController.text,
          jumlah_beban: double.parse(_jumlahBebanController.text),
          tanggal_beban: _editingBeban!.tanggal_beban,
        );
        bebanProvider.updateBeban(updatedBeban).then((_) {
          _cancelEditing();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Beban berhasil diperbarui')));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Color(0xFFC4DCD6),
      appBar: AppBar(
        title: Text(_editingBeban == null ? 'Isi Beban Usaha' : 'Edit Beban'),
        backgroundColor: Color(0xFFC4DCD6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Beban (1 Bulan)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _namaBebanController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Jumlah Beban (1 Bulan)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _jumlahBebanController,
                    decoration: InputDecoration(
                      prefixText: "Rp",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Jumlah tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          _editingBeban == null ? "Simpan Beban" : "Update",
                        ),
                      ),
                      if (_editingBeban != null) ...[
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: _cancelEditing,
                          child: Text("Batal"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Text("List Beban", style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: Consumer<BebanProvider>(
                builder:
                    (context, provider, child) => ListView.builder(
                      itemCount: provider.bebanList.length,
                      itemBuilder: (context, index) {
                        final beban = provider.bebanList[index];
                        return ListTile(
                          title: Text(beban.nama_beban),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formatter.format(beban.jumlah_beban)),
                              IconButton(
                                icon: Icon(Icons.edit, size: 20),
                                onPressed: () => _startEditing(beban),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color:
                                      Colors.red, // <-- TAMBAHKAN WARNA DI SINI
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: Text('Konfirmasi'),
                                          content: Text(
                                            'Hapus beban "${beban.nama_beban}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                              child: Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirmed == true) {
                                    await provider.deleteBeban(beban.id_beban!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Beban berhasil dihapus'),
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

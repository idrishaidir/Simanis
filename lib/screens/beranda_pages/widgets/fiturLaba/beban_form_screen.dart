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

  void _submitBeban() {
    if (_formKey.currentState!.validate()) {
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
        title: Text('Isi Beban Usaha'),
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
                  ElevatedButton(
                    onPressed: _submitBeban,
                    child: Text("Simpan Beban"),
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
                          trailing: Text(formatter.format(beban.jumlah_beban)),
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

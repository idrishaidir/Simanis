import 'package:SIMANIS_V1/providers/catatan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'catatan_form_screen.dart';

class CatatanListScreen extends StatefulWidget {
  @override
  _CatatanListScreenState createState() => _CatatanListScreenState();
}

class _CatatanListScreenState extends State<CatatanListScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<CatatanProvider>(
        context,
        listen: false,
      ).fetchAndSetCatatan().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshCatatan(BuildContext context) async {
    await Provider.of<CatatanProvider>(
      context,
      listen: false,
    ).fetchAndSetCatatan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC4DCD6),
      appBar: AppBar(
        title: Text('Catatan Saya'),
        backgroundColor: Color(0xFFC4DCD6),
      ),

      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => _refreshCatatan(context),
                child: Consumer<CatatanProvider>(
                  child: Center(
                    child: Text(
                      'Belum ada catatan. Tekan tombol + untuk menambah.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  builder:
                      (ctx, catatanData, child) =>
                          catatanData.items.isEmpty
                              ? child!
                              : ListView.builder(
                                padding: EdgeInsets.all(8),
                                itemCount: catatanData.items.length,
                                itemBuilder: (ctx, i) {
                                  final catatan = catatanData.items[i];
                                  return Card(
                                    elevation: 3,
                                    margin: EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 5,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        catatan.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Diubah: ${DateFormat('dd MMM yyyy, HH:mm').format(catatan.lastEdited)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    ChangeNotifierProvider.value(
                                                      value: Provider.of<
                                                        CatatanProvider
                                                      >(context, listen: false),
                                                      child: CatatanFormScreen(
                                                        catatan: catatan,
                                                      ),
                                                    ),
                                          ),
                                        );
                                      },
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[400],
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (ctx) => AlertDialog(
                                                  title: Text(
                                                    'Konfirmasi Hapus',
                                                  ),
                                                  content: Text(
                                                    'Anda yakin ingin menghapus catatan ini?',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Tidak'),
                                                      onPressed:
                                                          () =>
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop(),
                                                    ),
                                                    TextButton(
                                                      child: Text('Ya'),
                                                      onPressed: () {
                                                        Provider.of<
                                                          CatatanProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        ).deleteCatatan(
                                                          catatan.id!,
                                                        );
                                                        Navigator.of(ctx).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white),
        backgroundColor: Color(0xFF294855),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => ChangeNotifierProvider.value(
                    value: Provider.of<CatatanProvider>(context, listen: false),
                    child: CatatanFormScreen(),
                  ),
            ),
          );
        },
      ),
    );
  }
}

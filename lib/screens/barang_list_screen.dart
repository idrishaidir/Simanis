import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/barang_provider.dart';
import 'barang_form_screen.dart';

class BarangListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC0D9D1),
      appBar: AppBar(
        backgroundColor: Color(0xffC0D9D1),
        title: Text(
          'Daftar Barang',
          style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
          ),
        actions: [
          CircleAvatar(
            backgroundColor: Color(0xFF305163),
            radius:25,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white,),
              onPressed: () {
                final barangProvider = Provider.of<BarangProvider>(context, listen: false);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: barangProvider,
                      child: BarangFormScreen(),
                    ),
                  ),
                );
              },
            ),
          )
          
        ],
      ),
      body: Consumer<BarangProvider>(
        builder: (context, barangProvider, _) {
          final barangList = barangProvider.barangList;
          final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return ListView.builder(
            itemCount: barangList.length,
            itemBuilder: (ctx, index) {
              final barang = barangList[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                color: Color(0xFF305163),
                child: ListTile(
                  title: Text(
                    barang.nama,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  // subtitle: Text('Stok: ${barang.stok} | Harga: Rp${barang.harga.toStringAsFixed(0)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Text('Stok: ${barang.stok}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Text('Kode Barang: ${barang.kode_brg}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Text('Harga Jual: ${formatter.format(barang.harga_jual)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Text('Harga Modal: ${formatter.format(barang.harga_modal)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          final barangProvider = Provider.of<BarangProvider>(context, listen: false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: barangProvider,
                                child: BarangFormScreen(barang: barang),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Hapus barang ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await Provider.of<BarangProvider>(context, listen: false).hapusBarang(barang.id_brg);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
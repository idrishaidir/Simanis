import 'package:SIMANIS_V1/models/catatan_model.dart';
import 'package:SIMANIS_V1/providers/catatan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatatanFormScreen extends StatefulWidget {
  final Catatan? catatan;

  CatatanFormScreen({this.catatan});

  @override
  _CatatanFormScreenState createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.catatan != null) {
        _title = widget.catatan!.title;
        _content = widget.catatan!.content;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    final catatanProvider = Provider.of<CatatanProvider>(
      context,
      listen: false,
    );

    if (widget.catatan != null) {
      // Update catatan yang ada
      await catatanProvider.updateCatatan(
        widget.catatan!.id!,
        _title,
        _content,
      );
    } else {
      // Tambah catatan baru
      await catatanProvider.addCatatan(_title, _content);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC4DCD6),
      appBar: AppBar(
        title: Text(widget.catatan == null ? 'Tambah Catatan' : 'Edit Catatan'),
        backgroundColor: Color(0xFF294855),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 15,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi catatan tidak boleh kosong.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _content = value!;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/profil_model.dart';
import '../../providers/profil_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatefulWidget {
  final StoreProfile profile;
  const QRCodeScreen({super.key, required this.profile});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  late TextEditingController _qrCodeController;

  @override
  void initState() {
    super.initState();
    _qrCodeController = TextEditingController(
      text: widget.profile.qrCode.isNotEmpty
          ? widget.profile.qrCode
          : widget.profile.nama_usaha,
    );
  }

  @override
  void dispose() {
    _qrCodeController.dispose();
    super.dispose();
  }

  void _updateQrCode() async {
    // final newQr = _qrCodeController.text.trim();
    final newQr = widget.profile.copyWith(
      qrCode: _qrCodeController.text.trim(),
    );
    if (newQr.qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code tidak boleh kosong')),
      );
      return;
    }

    // Gunakan Provider untuk menyimpan QR Code ke database
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.updateProfile(newQr);

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit QR Code'), backgroundColor: const Color(0xFF294855)),
      backgroundColor: const Color(0xFFC4DCD6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            QrImageView(
              data: _qrCodeController.text,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _qrCodeController,
              decoration: const InputDecoration(
                labelText: 'Data QR Code',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'QR Code tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _updateQrCode, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
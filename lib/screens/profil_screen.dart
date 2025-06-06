import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profil_model.dart';
import '../providers/profil_provider.dart';
import 'profil_edit_screen.dart';
import 'section_profil/qrcode_screen.dart';
import 'dart:io';

class ProfilScreen extends StatefulWidget {
  final int id_user;
  const ProfilScreen({required this.id_user, super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).getProfile(widget.id_user);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    if (profile == null) {
      return Center(child: CircularProgressIndicator());
    }

    final String? photoFile = profile.foto_profil;

    return Scaffold(
      backgroundColor: const Color(0xFFC4DCD6),
      appBar: AppBar(
        title: const Text(
          'Profil User',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: const Color(0xFF294855),
      ),

      body:
          profile == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          (photoFile != null && photoFile.isNotEmpty)
                              ? FileImage(File(photoFile))
                              : const AssetImage(
                                    'assets/icons/default-user-image.png',
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      profile.nama_usaha,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoTile("Alamat", profile.alamat),
                    _infoTile("No. HP", profile.hp),
                    _infoTile("Email", profile.email),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push<StoreProfile>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilEditScreen(profile: profile),
                          ),
                        );

                        if (updated != null) {
                          await profileProvider.getProfile(profile.id_user);
                          setState(() {});
                        }
                      },
                      child: const Text("Edit Profil"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294855),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QRCodeScreen(profile: profile),
                          ),
                        );
                      },
                      child: const Text("QR Code"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294855),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        value.isNotEmpty ? value : "-",
        style: TextStyle(
          fontSize: 17,
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

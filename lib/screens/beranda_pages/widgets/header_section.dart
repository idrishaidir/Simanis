import 'dart:io';
import 'package:SIMANIS_V1/models/profil_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:SIMANIS_V1/providers/profil_provider.dart';
import 'package:SIMANIS_V1/screens/profil_screen.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Gunakan nama class yang benar: StoreProfile
        final StoreProfile? profil = profileProvider.profile;

        ImageProvider imageProvider = const AssetImage(
          'assets/images/logo-login.png',
        );
        String namaUsaha = 'Nama Usaha';
        Widget avatarChild = Icon(Icons.person, size: 30, color: Colors.grey);

        if (profil != null) {
          namaUsaha =
              profil
                  .nama_usaha; // Tidak perlu '??' jika di model sudah di-handle
          final fotoPath = profil.foto_profil;

          if (fotoPath.isNotEmpty) {
            avatarChild = SizedBox.shrink();
            if (kIsWeb) {
              if (fotoPath.startsWith('http')) {
                imageProvider = NetworkImage(fotoPath);
              }
            } else {
              final file = File(fotoPath);
              if (file.existsSync()) {
                imageProvider = FileImage(file);
              }
            }
          }
        }

        return Row(
          children: [
            InkWell(
              onTap:
                  (profil != null)
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProfilScreen(id_user: profil.id_user),
                          ),
                        );
                      }
                      : null,
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: imageProvider,
                child: avatarChild,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              namaUsaha,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.notifications_none),
          ],
        );
      },
    );
  }
}

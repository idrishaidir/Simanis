import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profil_model.dart';
import '../providers/profil_provider.dart';
import 'package:image_picker/image_picker.dart';
// import '../helpers/api_laravel.dart';
import 'dart:io';

class ProfilEditScreen extends StatefulWidget {
  final StoreProfile profile;

  const ProfilEditScreen({super.key, required this.profile});

  @override
  State<ProfilEditScreen> createState() => _ProfilEditScreenState();
}

class _ProfilEditScreenState extends State<ProfilEditScreen> {
  late TextEditingController nama_usahaController;
  late TextEditingController alamatController;
  late TextEditingController hpController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nama_usahaController = TextEditingController(text: widget.profile.nama_usaha);
    alamatController = TextEditingController(text: widget.profile.alamat);
    hpController = TextEditingController(text: widget.profile.hp);
    emailController = TextEditingController(text: widget.profile.email);
  }

  Future<void> _save() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    // konfirmasi jika email sama dengan email yang sudah ada
    if (emailController.text != widget.profile.email) {
      // final existingProfile = await profileProvider.getProfileEmailById(emailController.text);
      final existingProfile = await profileProvider.getProfileByEmail(emailController.text);
      if (existingProfile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sudah digunakan oleh profil lain')),
        );
        return;
      } else if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email tidak boleh kosong')),
        );
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Konfirmasi Email'),
          content: Text('Email terbaru akan digunakan untuk login'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Lanjutkan'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    //konfirmasi jika email yang diubah akan digunakan untuk login
    // if (emailController.text != widget.profile.email) {
    //   final exitingProfile = await profileProvider.getProfileByEmail(emailController.text);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Email tidak boleh kosong')),
    //   );
    //   return;
    // }

    final updatedProfile = widget.profile.copyWith(
      nama_usaha: nama_usahaController.text,
      alamat: alamatController.text,
      hp: hpController.text,
      email: emailController.text,
      foto_profil: widget.profile.foto_profil, // update path foto_profil
    );

    // print("+++++++++++++++++++++++++++++updatedProfile: $updatedProfile");
    await profileProvider.updateProfile(updatedProfile);
    Navigator.pop(context, updatedProfile); // <-- Kembalikan profile terbaru
  }

  Future<void> pickAndUpdatePhoto(int id_user) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentProfile = profileProvider.profile ?? widget.profile;
      final updatedProfile = currentProfile.copyWith(
        foto_profil: pickedFile.path,
      );
      await profileProvider.updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto berhasil diupdate')),
      );
      await profileProvider.getProfile(id_user);
      setState(() {});
      Navigator.pop(context, updatedProfile); // <-- Kembalikan profile terbaru
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile ?? widget.profile; // fallback ke widget.profile jika null
    return Scaffold(
    backgroundColor: const Color(0xFFC4DCD6),
    appBar: AppBar(
            title: const Text('Edit Profil', 
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25
                                )
                              ),
            backgroundColor: const Color(0xFF294855),
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //foto profil
            CircleAvatar(
              radius: 60,
              backgroundImage: (profile.foto_profil != null && profile.foto_profil.isNotEmpty)
                  ? FileImage(File(profile.foto_profil))
                  : const AssetImage('assets/icons/default-user-image.png') as ImageProvider,
            ),
            SizedBox(height: 30),
            _textField(
              "Nama", 
              nama_usahaController,
              maxLength: 50,
              onChanged: (value) {
                  if (value.length > 50) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nama usaha tidak boleh lebih dari 50 karakter')),
                    );
                  }
                }
            ),
            _textField(
              "Alamat", 
              alamatController,
              maxLength: 150,
              onChanged: (value) {
                  if (value.length > 150) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Alamat tidak boleh lebih dari 150 karakter')),
                    );
                  }
                }
              ),
            _textField(
              "No HP", 
              hpController,
              maxLength: 20,
              onChanged: (value) {
                  if (value.length > 20) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No HP tidak boleh lebih dari 20 karakter')),
                    );
                  }
                }
              ),
            _textField(
              "Email", 
              emailController,
              maxLength: 50,
              onChanged: (value) {
                  if (value.length > 50) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email tidak boleh lebih dari 50 karakter')),
                    );
                  }else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Format email tidak valid')),
                    );
                  }
                }
              ),
            // Untuk tombol "Simpan"
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150, // atur lebar sesuai keinginan
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF294855),
                      foregroundColor: Colors.white,
                      minimumSize: Size(0, 40), // lebar diatur SizedBox, tinggi 48
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Simpan"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150, // atur lebar sesuai keinginan
                  child: ElevatedButton(
                    onPressed: () => pickAndUpdatePhoto(widget.profile.id_user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF294855),
                      foregroundColor: Colors.white,
                      minimumSize: Size(0, 40), // lebar diatur SizedBox, tinggi 48
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Ubah Foto"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int? maxLength,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        onChanged: onChanged,
        style: TextStyle(fontSize: 16, color: Colors.black87), // style isi
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF294855)), // style label
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF294855), width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/profil_provider.dart';

// class PasswordEditScreen extends StatefulWidget {
//   const PasswordEditScreen({super.key});

//   @override
//   State<PasswordEditScreen> createState() => _PasswordEditScreenState();
// }

// class _PasswordEditScreenState extends State<PasswordEditScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _oldPassword = TextEditingController();
//   final _newPassword = TextEditingController();
//   final _confirmPassword = TextEditingController();

//   bool _isSaving = false;

//   @override
//   void dispose() {
//     _oldPassword.dispose();
//     _newPassword.dispose();
//     _confirmPassword.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSaving = true);
//     final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

//     bool success = await profileProvider.verifyAndUpdatePassword(
//       _oldPassword.text, 
//       _newPassword.text,
//     );

//     setState(() => _isSaving = false);

//     if (success) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password berhasil diubah")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password lama salah")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Ubah Password"), backgroundColor: const Color(0xFF294855)),
//       backgroundColor: const Color(0xFFC4DCD6),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _passwordField("Password Lama", _oldPassword),
//               _passwordField("Password Baru", _newPassword, validateLength: true),
//               _passwordField("Konfirmasi Password", _confirmPassword, validateMatch: true),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isSaving ? null : _save,
//                 child: _isSaving
//                     ? const CircularProgressIndicator()
//                     : const Text("Simpan"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _passwordField(String label, TextEditingController controller,
//       {bool validateLength = false, bool validateMatch = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         obscureText: true,
//         decoration: InputDecoration(
//           labelText: label,
//           filled: true,
//           fillColor: Colors.white,
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) return 'Wajib diisi';
//           if (validateLength && value.length < 6) return 'Minimal 6 karakter';
//           if (validateMatch && value != _newPassword.text) return 'Password tidak sama';
//           return null;
//         },
//       ),
//     );
//   }
// }
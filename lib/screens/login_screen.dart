import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../helpers/api_laravel.dart';
import 'register_screen.dart';
import '../main.dart';
// import '../config/database.dart';
import '../providers/login_provider.dart';
// import '../routes.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final user = await loginProvider.login(email.text.trim(), password.text);
    // final loginProvider = LoginProvider();
    // final user = await loginProvider.login(
    //   _emailController.text.trim(),
    //   _passwordController.text,
    // );

    setState(() => _isLoading = false);
    print("hasil login : $user");

    if (user != null) {
      final id_user = user['id_user'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage(id_user: id_user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email atau password salah')),
      );
    }
  }

  // void _showRegisterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => RegisterDialog(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8C9793), // abu-abu kehijauan
      body: SingleChildScrollView(
        // child: Align(
          // alignment: Alignment.topCenter,
          child: Container(
            // width: 350,
            width: 400,
            padding: EdgeInsets.symmetric(vertical: 65, horizontal: 24), 
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.10),
            //   borderRadius: BorderRadius.circular(32),
            // ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Welcome to\nSIMANIS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 50),
                  // Logo
                  Center(
                    child: Column(
                      children: [
                          // FlutterLogo(size: 100,),
                        Image.asset(
                          'assets/images/logo-login.png',
                          height: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "simanis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF6B6B6B),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 70),
                  
                  // Spacer(flex: 50), // beri jarak dari atas

                  Text(
                    "Masukkan Email Anda",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    // controller: _emailController,
                    controller: email,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || !value.contains('@') ? 'Email tidak valid' : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Masukkan Password Anda",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: password,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) =>
                        value == null || value.length < 6 ? 'Minimal 6 karakter' : null,
                  ),
                  SizedBox(height: 8),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {}, // Tambahkan aksi jika ada
                  //     child: Text(
                  //       "Forgot Password",
                  //       style: TextStyle(color: Color(0xFFD9B24C)),
                  //     ),
                  //     style: TextButton.styleFrom(
                  //       padding: EdgeInsets.zero,
                  //       minimumSize: Size(0, 0),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  print("LOGIN BUTTON PRESSED"); // Tambahkan ini
                                  _login();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF355A63),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                // onPressed: _showRegisterDialog,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFF355A63), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Register",
                                  style: TextStyle(fontSize: 18, color: Color(0xFF355A63)),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              )
            
          ),
        // ),
      ),
    );
  }
}

// class RegisterDialog extends StatefulWidget {
//   @override
//   State<RegisterDialog> createState() => _RegisterDialogState();
// }

// class _RegisterDialogState extends State<RegisterDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;

//   void _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     final success = await ApiHelper.register({
//       'email': _emailController.text.trim(),
//       'password': _passwordController.text,
//       'password_confirmation': _passwordController.text,
//       'role': '0',
//       'status': 1,
//     });

//     setState(() => _isLoading = false);

//     if (success) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registrasi berhasil, silakan login')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registrasi gagal')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Daftar Akun"),
//       content: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: "Email"),
//                 validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
//               ),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: "Password"),
//                 obscureText: true,
//                 validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _register,
//           child: _isLoading ? CircularProgressIndicator() : Text("Daftar"),
//         ),
//       ],
//     );
//   }
// }
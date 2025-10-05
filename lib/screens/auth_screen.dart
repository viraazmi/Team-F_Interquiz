import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _fullName = '';

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(email: _email, password: _password);
        } else {
          // VVV BARIS INI TELAH DIPERBAIKI VVV
          final userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);

          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'fullName': _fullName,
            'email': _email,
            'score': 0,
            'coins': 0,
          });
        }
      } on FirebaseAuthException catch (err) {
        var message = 'An error occurred, please check your credentials!';
        if (err.message != null) {
          message = err.message!;
        }
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LaLaMu',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Arial'),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _isLogin ? 'LOGIN' : 'BUAT AKUN BARU',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        if (!_isLogin)
                          TextFormField(
                            key: const ValueKey('fullName'),
                            validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                            onSaved: (value) => _fullName = value!,
                            decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('email'),
                          validator: (value) => !(value!.contains('@')) ? 'Email tidak valid' : null,
                          onSaved: (value) => _email = value!,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: 'Alamat Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('password'),
                          validator: (value) => value!.length < 6 ? 'Password minimal 6 karakter' : null,
                          onSaved: (value) => _password = value!,
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitAuthForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(_isLogin ? 'SUBMIT' : 'BUAT AKUN'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin ? 'Belum punya akun? Daftar' : 'Sudah memiliki akun? Masuk'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
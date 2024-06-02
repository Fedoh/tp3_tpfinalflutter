import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/usuario.dart';
import 'package:flutter_application_1/presentation/productos_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class InicioSesion extends StatelessWidget {
  static const String name = 'InicioSesion';
  const InicioSesion({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[700],
        centerTitle: true,
        title: const Text('Wine&Go'),
      ),
      body: const _InicioSesion(),
    );
  }
}

class _InicioSesion extends StatefulWidget {
  const _InicioSesion({Key? key});

  @override
  __InicioSesionState createState() => __InicioSesionState();
}

class __InicioSesionState extends State<_InicioSesion> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String generatePasswordHash(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final address = _addressController.text.trim();
    final passwordHash = generatePasswordHash(password);

    try {
      if (_isLogin) {
        QuerySnapshot result = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (result.docs.isNotEmpty) {
          var userDoc = result.docs.first;
          var storedHash = userDoc['password'];
          if (storedHash == passwordHash) {
            await _auth.signInWithEmailAndPassword(email: email, password: password);

            await storage.write(key: 'userId', value: userDoc.id);
            await storage.write(key: 'userName', value: userDoc['nombre']);
            await storage.write(key: 'userEmail', value: email);
            await storage.write(key: 'userAddress', value: userDoc['direccion']);
            
            if (_rememberMe) {
              await storage.write(key: 'password', value: password);
            } else {
              await storage.delete(key: 'password');
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductosScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contraseña incorrecta')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró el usuario')),
          );
        }
      } else {
        DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc();
        String docId = docRef.id;

        Usuario nuevoUsuario = Usuario(
          id: docId,
          nombre: name,
          apellido: surname,
          direccion: address,
          email: email,
          contrasenia: passwordHash,
        );

        await docRef.set(nuevoUsuario.toMap());

        await _auth.createUserWithEmailAndPassword(email: email, password: password);

        await storage.write(key: 'userId', value: docId);
        await storage.write(key: 'userName', value: name);
        await storage.write(key: 'userEmail', value: email);
        await storage.write(key: 'userAddress', value: address);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductosScreen()),
        );
      }
    } catch (e) {
      print('Error: $e');
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Este correo electrónico ya está en uso.';
            break;
          case 'invalid-email':
            errorMessage = 'El correo electrónico no es válido.';
            break;
          case 'weak-password':
            errorMessage = 'La contraseña es demasiado débil.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'La operación no está permitida.';
            break;
          default:
            errorMessage = 'Ocurrió un error desconocido.';
            break;
        }
      } else {
        errorMessage = 'Ocurrió un error. Por favor, inténtelo de nuevo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForSavedCredentials();
  }

  Future<void> _checkForSavedCredentials() async {
    String? email = await storage.read(key: 'userEmail');
    String? password = await storage.read(key: 'password');
    if (email != null && password != null) {
      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[700],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Wine&Go',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              if (!_isLogin)
                Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text(
                    'Mantener sesión iniciada',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
              ),
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(_isLogin ? '¿No tienes una cuenta? Regístrate' : '¿Ya tienes una cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
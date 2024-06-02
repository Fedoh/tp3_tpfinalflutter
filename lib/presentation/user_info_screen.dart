import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/lista_pedidos_screen.dart';

class UserInfoScreen extends StatefulWidget {
  static const String name = 'UserInfoScreen';

  final String userId;

  const UserInfoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<DocumentSnapshot> _fetchUserData() {
    return FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
  }

  void _updateUserData() {
    setState(() {
      _userDataFuture = _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Usuario'),
        backgroundColor: Colors.pink[700],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoTile('Nombre', userData['nombre']),
              _buildInfoTile('Apellido', userData['apellido']),
              _buildAddressTile(userData['direccion'], context, widget.userId),
              _buildInfoTile('Correo electrónico', userData['email']),
              _buildHistoryTile(context, widget.userId), 
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
      ),
    );
  }

  Widget _buildAddressTile(String address, BuildContext context, String userId) {
    return ListTile(
      title: const Text(
        'Dirección',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        address,
      ),
      trailing: ElevatedButton(
        onPressed: () {
          _showChangeAddressDialog(context, userId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[700],
        ),
        child: const Text(
          'Cambiar',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, String userId) {
    return ListTile(
      trailing : const Icon(Icons.arrow_forward), 
      title: const Text(
        'Historial de Compras',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListaPedidosScreen(userId: userId)),
        );
      },
    );
  }

  void _showChangeAddressDialog(BuildContext context, String userId) {
    String newAddress = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Dirección'),
          content: TextField(
            onChanged: (value) {
              newAddress = value;
            },
            decoration: const InputDecoration(
              labelText: 'Nueva Dirección',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateAddress(context, userId, newAddress);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[700],
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateAddress(BuildContext context, String userId, String newAddress) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'direccion': newAddress,
    }).then((value) {
      Navigator.pop(context);
      _updateUserData(); 
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la dirección: $error')),
      );
    });
  }
}
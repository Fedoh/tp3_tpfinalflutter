import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/producto.dart';
import 'package:flutter_application_1/presentation/producto_detalles_screen.dart';


class ListaPedidosScreen extends StatelessWidget {
  static const String name = 'ListaPedidosScreen';
  final String userId;

  ListaPedidosScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: Colors.pink[700],
      ),
      body: _buildPedidosList(context),
    );
  }
  
  Widget _buildPedidosList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('userId', isEqualTo: userId)
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<QueryDocumentSnapshot> pedidos = snapshot.data!.docs;

        if (pedidos.isEmpty) {
          return const Center(child: Text('No hay historial de compras disponible'));
        }

        return ListView.builder(
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index].data() as Map<String, dynamic>;
            final fechaPedido = pedido['fecha'].toDate();
            final formattedFecha = '${fechaPedido.day}/${fechaPedido.month}/${fechaPedido.year}';
            final formattedHora = '${fechaPedido.hour}:${fechaPedido.minute}:${fechaPedido.second}';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ExpansionTile(
                title: Text(
                  'Pedido del dia $formattedFecha $formattedHora',
                  style: const TextStyle(color: Colors.black),
                ),
                childrenPadding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Precio Total: \$${pedido['precioTotal'].toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Dirección de entrega: ${pedido['direccion']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Productos:',
                    style: TextStyle(color: Colors.pink[700], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildProductosList(context, pedido['productos']),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildProductosList(BuildContext context, List<dynamic> productos) {
    return productos.map((producto) {
      return ListTile(
        title: Text(
          producto['nombre'],
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          'Precio: \$${producto['precio'].toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.black),
        ),
        onTap: () {
          _navigateToProductoDetalles(context, producto);
        },
      );
    }).toList();
  }

  void _navigateToProductoDetalles(BuildContext context, dynamic productoData) {
    Producto producto = Producto.fromMap(productoData, productoData['id']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetallesScreen(producto: producto),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/producto.dart';

class ProductoDetallesScreen extends StatelessWidget {
  static const String name = 'ProductoDetallesScreen';
  final Producto producto;

  const ProductoDetallesScreen({Key? key, required this.producto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[700],
        title: Text(producto.nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  producto.imagen,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              producto.nombre,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Productor: ${producto.productor}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Variedad: ${producto.variedad}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${producto.precio.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                color: Colors.pink[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              producto.descripcion,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

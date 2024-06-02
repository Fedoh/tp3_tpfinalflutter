import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/producto.dart';

class Carrito extends ChangeNotifier {
  final List<Producto> productos = [];

  void addProduct(Producto producto) {
    productos.add(producto);
  }

  void removeProduct(Producto producto) {
    productos.remove(producto);
  }

  double getTotalPrice() {
    return productos.fold(0.0, (total, producto) => total + producto.precio);
  }

  void clear() {
    productos.clear();
  }

  int totalItems() {
    return productos.length;
  }

}
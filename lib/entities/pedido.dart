import 'package:flutter_application_1/entities/producto.dart';

class Pedido {
  final List<Producto> productos;
  final String direccion;
  final double precioTotal;
  final DateTime fecha;

  Pedido({
    required this.productos,
    required this.direccion,
    required this.precioTotal,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'productos': productos.map((producto) => producto.toMap()).toList(),
      'direccion': direccion,
      'precioTotal': precioTotal,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      productos: List<Producto>.from(map['productos'].map((productoMap) => Producto.fromMap(productoMap, productoMap['id']))),
      direccion: map['direccion'],
      precioTotal: map['precioTotal'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
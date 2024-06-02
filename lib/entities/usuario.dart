import 'package:flutter_application_1/entities/pedido.dart';

class Usuario {
  String id;
  String nombre;
  String apellido;
  String direccion;
  String email;
  String contrasenia;
  List<Pedido> historialDeCompras;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.email,
    required this.contrasenia,
    List<Pedido>? historialDeCompras,
  }) : historialDeCompras = historialDeCompras ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'direccion': direccion,
      'email': email,
      'password': contrasenia,
      'historialDeCompras': historialDeCompras.map((pedido) => pedido.toMap()).toList(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      direccion: map['direccion'],
      email: map['email'],
      contrasenia: map['password'],
      historialDeCompras: List<Pedido>.from(map['historialDeCompras'].map((pedidoMap) => Pedido.fromMap(pedidoMap))),
    );
  }
}
class Producto {
  String id;
  String tipo;
  String nombre;
  String productor;
  String variedad;
  String descripcion;
  int precio;
  String imagen;

  Producto({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.productor,
    required this.variedad,
    required this.descripcion,
    required this.precio,
    required this.imagen,
  });

  factory Producto.fromMap(Map<String, dynamic> data, String documentId) {
    return Producto(
      id: documentId,
      tipo: data['tipo'],
      nombre: data['nombre'],
      productor: data['productor'],
      variedad: data['variedad'],
      descripcion: data['descripcion'],
      precio: data['precio'],
      imagen: data['imagen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre': nombre,
      'productor': productor,
      'variedad': variedad,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
    };
  }
}

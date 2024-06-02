import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/entities/carrito.dart';
import 'package:flutter_application_1/entities/pedido.dart';
import 'package:flutter_application_1/entities/producto.dart';
import 'package:flutter_application_1/presentation/inicio_sesion_screen.dart';
import 'package:flutter_application_1/presentation/lista_pedidos_screen.dart';
import 'package:flutter_application_1/presentation/producto_detalles_screen.dart';
import 'package:flutter_application_1/presentation/user_info_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductosScreen extends StatelessWidget {
  static const String name = 'ProductosScreen';

  const ProductosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Carrito carritoDeCompras = Carrito();

    return Scaffold(
      body: _ProductosScreen(carrito: carritoDeCompras,),
    );
  }
}

class _ProductosScreen extends StatelessWidget {
  final Carrito carrito;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

   _ProductosScreen({Key? key, required this.carrito}) : super(key: key);

  void _mostrarCarrito(BuildContext context) {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.pink[700],
          title: const Text('Productos'),
          shadowColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () => _mostrarCarrito(context),
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Vinos'),
              Tab(text: 'Comidas'),
            ],
          ),
        ),
        drawer: const _MenuDrawer(),
        endDrawer: _CarritoDrawer(carrito: carrito),
        body: TabBarView(
          children: [
            _buildVinosTab(carrito),
            _buildComidasTab(carrito),
          ],
        ),
      ),
    );
  }
}

class _CarritoDrawer extends StatefulWidget {
  final Carrito carrito;

  const _CarritoDrawer({Key? key, required this.carrito}) : super(key: key);

  @override
  _CarritoDrawerState createState() => _CarritoDrawerState();
}


class _CarritoDrawerState extends State<_CarritoDrawer> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink[700],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Carrito de Compras',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  'Precio Total: \$${widget.carrito.getTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final direccion = await obtenerDireccion();
                    final userId = await storage.read(key: 'userId');
                    final pedido = Pedido(
                      productos: widget.carrito.productos,
                      precioTotal: widget.carrito.getTotalPrice(),
                      fecha: DateTime.now(),
                      direccion: direccion,
                    );

                    try {
                      final pedidoRef = await FirebaseFirestore.instance.collection('pedidos').add({
                        'userId': userId,
                        'productos': pedido.productos.map((producto) => producto.toMap()).toList(),
                        'precioTotal': pedido.precioTotal,
                        'fecha': pedido.fecha,
                        'direccion': pedido.direccion,
                      });

                      final pedidoId = pedidoRef.id;
                      await FirebaseFirestore.instance.collection('users').doc(userId).collection('pedidos').doc(pedidoId).set({
                        'productos': pedido.productos.map((producto) => producto.toMap()).toList(),
                        'precioTotal': pedido.precioTotal,
                        'fecha': pedido.fecha,
                        'direccion': pedido.direccion,
                      });

                      widget.carrito.clear();
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pedido realizado con éxito')),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListaPedidosScreen(userId: userId!)),
                      );

                    } catch (error) {
                      print('Error al guardar el pedido: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al realizar el pedido')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.pink[700],
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const Text('Comprar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.carrito.productos.length,
              itemBuilder: (context, index) {
                final product = widget.carrito.productos[index];
                return ListTile(
                  title: Text(product.nombre),
                  subtitle: Text('\$${product.precio.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      setState(() {
                        widget.carrito.removeProduct(product);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<String> obtenerDireccion() async {
    final String? direccion = await storage.read(key: 'direccion');
    return direccion ?? ''; 
  }
}


Future<List<Producto>> fetchProductos() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('productos').get();
  return snapshot.docs.map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
}

Widget _buildVinosTab(Carrito carrito) {
  return FutureBuilder<List<Producto>>(
    future: fetchProductos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No hay productos disponibles.'));
      }

      final listaVinos = snapshot.data!.where((producto) => producto.tipo == 'Vino').toList();

      if (listaVinos.isEmpty) {
        return const Center(child: Text('No hay vinos disponibles.'));
      }

      return GridView.builder(
        itemCount: listaVinos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          final vino = listaVinos[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductoDetallesScreen(producto: vino),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        vino.imagen,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vino.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${vino.precio.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final productToAdd = Producto(
                        id: vino.id,
                        tipo: vino.tipo,
                        nombre: vino.nombre,
                        productor: vino.productor,
                        variedad: vino.variedad,
                        precio: vino.precio,
                        imagen: vino.imagen,
                        descripcion: vino.descripcion,
                      );
                      carrito.addProduct(productToAdd);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[700],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    child: const Text('Agregar al carrito',
                        style: TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  
Widget _buildComidasTab(Carrito carrito) {
  return FutureBuilder<List<Producto>>(
    future: fetchProductos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No hay productos disponibles.'));
      }

      final listaComidas = snapshot.data!.where((producto) => producto.tipo == 'Comida').toList();

      if (listaComidas.isEmpty) {
        return const Center(child: Text('No hay comidas disponibles.'));
      }

      return GridView.builder(
        itemCount: listaComidas.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          final comida = listaComidas[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductoDetallesScreen(producto: comida),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        comida.imagen,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comida.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${comida.precio.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final productToAdd = Producto(
                        id: comida.id,
                        tipo: comida.tipo,
                        nombre: comida.nombre,
                        productor: comida.productor,
                        variedad: comida.variedad,
                        precio: comida.precio,
                        imagen: comida.imagen,
                        descripcion: comida.descripcion,
                      );
                      carrito.addProduct(productToAdd);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[700],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Agregar al carrito',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}




class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink[700],
            ),
            child: const Text('Menu'),
          ),
          InkWell(
            child: ListTile(
              title: const Text("Informacion usuario"),
              leading: Icon(Icons.person, color: Colors.pink[700]),
              onTap: () async {
                const storage = FlutterSecureStorage();
                String? userId = await storage.read(key: 'userId');

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserInfoScreen(userId: userId!)),
                );
              },
            ),
          ),
          InkWell(
             child: ListTile(
                title: const Text("Historial de Compras"),
                leading: Icon(Icons.shopping_basket, color: Colors.pink[700]),
             ),
             onTap: () async {
             const storage = FlutterSecureStorage();
               String? userId = await storage.read(key: 'userId');

               Navigator.of(context).push(
               MaterialPageRoute(builder: (context) => ListaPedidosScreen(userId: userId!)),
              );
            },
          ),
          InkWell(
            child: ListTile(
              title: const Text("Cerrar sesión"),
              leading: Icon(Icons.logout, color: Colors.pink[700]),
              onTap: ()  {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const InicioSesion()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

  



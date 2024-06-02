import 'package:flutter_application_1/entities/producto.dart';
import 'package:flutter_application_1/presentation/inicio_sesion_screen.dart';
import 'package:flutter_application_1/presentation/lista_pedidos_screen.dart';
import 'package:flutter_application_1/presentation/producto_detalles_screen.dart';
import 'package:flutter_application_1/presentation/productos_screen.dart';
import 'package:flutter_application_1/presentation/user_info_screen.dart';
import 'package:go_router/go_router.dart';


final appRouter = GoRouter(routes: [
  GoRoute(
    name: InicioSesion.name,
    path: '/',
    builder: (context, state) => const InicioSesion(),
  ),

  GoRoute(
    name: ProductosScreen.name,
    path: '/productos',
    builder: (context, state) => const ProductosScreen(),
  ),

  GoRoute(
      name: ProductoDetallesScreen.name,
      path: '/productosDetalles',
      builder: (context, state) {
        final producto = state.extra as Producto;
        return ProductoDetallesScreen(producto: producto);
      },
    ),

  GoRoute(
    name: UserInfoScreen.name,
    path: '/userInfo',
    builder: (context, state) => const UserInfoScreen(userId: '',),
  ),

  GoRoute(
    name: ListaPedidosScreen.name,
    path: '/listaPedidosScreen',
    builder: (context, state) =>  ListaPedidosScreen(userId: '',),
  ),
  
]);
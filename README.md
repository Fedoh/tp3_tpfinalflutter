# flutter_application_1

Firestore = la base de datos del Firebase.
toMap = pedido, producto y usuario tienen estas funciones para que Firestore pueda tomar los datos.
fromMap = lo mismo de arriba pero es para cuando obtengas los datos desde el Firestore y te transforme el map
          a un objeto. (EJ: User tiene id y nombre, te toma los dos datos y los hace un objeto tipo User para que puedas usarlo).
async y await = Usamos la palabra “async” antes de una función para decir que es asíncrona y la palabra “await”,
         que pausa la ejecución de la función a la espera de que se obtengan todos los datos y siempre debe estar dentro de la función async. (Sacado de google).



main.dart:
    - El main es donde te corre toda la app.
    - Tiene async para que puedas inicializar el Firebase.
    - Corre el app_router.

app_router.dart: 
    - Tiene todas las rutas necesarias para que la app sepa pasar de una screen a otra.

Entities: 
 1. carrito: 
    - Contiene el codigo necesario para que el carrito dentro de productos_screen funcione.
 2. pedido: 
    - Contiene el codigo necesario para que el Firestore reconozca los datos de entrada y de salida.
    - Tiene una lista de Productos.
 3. producto:
    - Lo mismo que los otros, tiene los datos necesarios para correr el programa.
 4. usuario:
    - Lo mismo de nuevo, tiene los datos necesarios para correr el programa.
    - Tiene una lista de Pedidos.

Presentation:
    Las presentaciones son las 'screens' o 'pantallas' que ves cada vez que tocas algo dentro de la app.

 1. inicio_sesion_screen.dart:
    - Es la primer pantalla que se abre al iniciar la aplicación.
    - Es donde esta toda la logica para iniciar sesion y registrar el usuario.
    - Una vez que te registraste o iniciaste sesion todos los datos se guardan en el FlutterSecureStorage,
      en otras palabras se inicia y se mantiene la sesion iniciada.
    - Información destacada:
      - FirebaseAuth: 
            Es una clase del Firebase que es la que permite la autenticación automatica de los datos
            al iniciar sesion o crear un usuario.
      - DocumentReference:
            Es, en este caso, lo que se usa para que se guarde la Id automatica que genera el Firestore
            al atributo id que tenemos de nuestra clase Usuario. 
      - FlutterSecureStorage:
            Es una clase misma del Flutter, que te permite guardar datos dentro de la app de forma segura.

 2. productos_screen.dart:
    - Es la segunda pantalla que ves una vez que inicias sesión o te registras exitosamente.
    - En esta pantalla se puede acceder a todo lo demás y tiene todo el codigo y la logica necesarios para que
      corra el carrito, se pueda ver la informacion de los productos y se pueda acceder a las distintas funciones del menu lateral.

    - Menu lateral:
      - Información de Usuario:
        - Te manda a la pantalla que te muestra toda la info del usuario con el que iniciaste sesion.

      - Historial de Compras: 
        - Te manda a la pantalla que te muestra la lista de todos los pedidos que ha hecho el usuario.

      - Cerrar Sesion:
        - Elimina todos los datos del FlutterSecureStorage (en otras palabras cierra la sesion) y 
          te devuelve a la pantalla de inicio de sesion.

    - Carrito de compras (arriba a la derecha):
      - Permite agregar todos los items que quieras y te deja quitarlos siempre que quieras.
      - Suma el precio total de todos los items .
      - Boton Comprar:
        - Al presionarlo te guarda el pedido en la base de datos, en la lista de pedidos
          del usuario y te manda a la misma pantalla que el boton Historial de Compras.

    - Productos en la pantalla:
      - Tiene un TabBar que te da las opciones de Vino y Comida.
      - Cada opcion te corre un widget distinto, pero los dos tienen el mismo codigo, excepto por las 
        validaciones de si el producto es de tipo vino o tipo comida (hago la distinción porque en la base de datos los productos se guardan todos en la misma coleccion y solamente se pueden diferenciar por el atributo tipo que tiene cada producto).
      - Al apretar cualquier producto en pantalla (menos en el boton agregar al carrito, obvio) te abre la 
        pantalla de detalles del producto.


 3. producto_detalles_screen.dart:
    - A esta pantalla se puede acceder al apretar un item de los que se muestran en la pantalla productos_screen
      o apretando alguno de los productos dento del historial de pedidos.
    - Es una pantalla cortita, lo unico que hace es mostrar los items del producto al que apretes.

 4. user_info_screen.dart:
    - A esta pantalla se accede solamente desde el menu lateral dentro de productos_screen.dart.
    - Tiene la logica necesaria para cambiar la dirección.
    - Te muestra toda la informacion del usuario como el nombre, apellido, direccion, etc.
    - La ultima opción, Historial de Compras, te envia a la pantalla lista_pedidos_screen.dart.

 5. lista_pedidos_screen.dart:
    - Otra pantalla corta, contiene el codigo para mostrar la lista de los pedidos del usuario que esta conectado.



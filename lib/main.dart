import 'package:flutter/material.dart';
import 'insertar.dart';
import 'actualizar.dart';
import 'eliminar.dart';
import 'seleccionar.dart';




void main() {
 runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: const HomePage(),
     theme: ThemeData.light(),
     darkTheme: ThemeData.dark(),
     routes: {
       '/insertar': (context) => const InsertarPage(),
       '/actualizar': (context) => const ActualizarPage(),
       '/eliminar': (context) => const EliminarPage(),
       '/seleccionar': (context) => const SeleccionarPage(),
     },
   );
 }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

 @override
 _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('AG13 - Base de datos'),
     ),
     drawer: Drawer(
       child: ListView(
         padding: EdgeInsets.zero,
         children: [
           const DrawerHeader(
             decoration: BoxDecoration(
               color: Colors.purple,
             ),
             child: Text(
               'Menú',
               style: TextStyle(
                 color: Colors.white,
                 fontSize: 23,
               ),
             ),
           ),
           ListTile(
             leading: const Icon(Icons.add),
             title: const Text('Insertar'),
             onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/insertar');
             },
           ),
           ListTile(
             leading: const Icon(Icons.update),
             title: const Text('Actualizar'),
             onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/actualizar');
             },
           ),
           ListTile(
             leading: const Icon(Icons.delete),
             title: const Text('Eliminar'),
             onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/eliminar');
             },
           ),
           ListTile(
             leading: const Icon(Icons.search),
             title: const Text('Seleccionar'),
             onTap: () {
               Navigator.pop(context);
               Navigator.pushNamed(context, '/seleccionar');
             },
           ),
         ],
       ),
     ),
     body: const Center(
       child: Text(
         'Bienvenido a la Gestión de Datos',
         style: TextStyle(fontSize: 20),
       ),
     ),
   );
 }
}

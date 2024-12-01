import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class EliminarPage extends StatefulWidget {
  const EliminarPage({super.key});

 @override
 _EliminarPageState createState() => _EliminarPageState();
}


class _EliminarPageState extends State<EliminarPage> {
 List<Map<String, dynamic>> _searchResults = [];
 String _searchTerm = '';


 void _buscarDatos() async {
   final response = await http.post(
     Uri.parse('http://192.168.0.78:8080/Students/sqloperations.php'),
     body: json.encode({
       "action": "SEARCH_DATA",
       "searchTerm": _searchTerm,
     }),
     headers: {'Content-Type': 'application/json'},
   );


   if (response.statusCode == 200) {
     final List<dynamic> results = json.decode(response.body);
     setState(() {
       _searchResults = results.map((data) => Map<String, dynamic>.from(data)).toList();
     });
   } else {
     print('Error en la búsqueda');
   }
 }


 void _eliminarRegistro(int id) async {
   final response = await http.post(
     Uri.parse('http://localhost/Students/sqloperations.php'),
     body: json.encode({
       "action": "DELETE_DATA",
       "id": id,
     }),
     headers: {'Content-Type': 'application/json'},
   );


   if (response.statusCode == 200) {
     final result = json.decode(response.body);
     if (result['status'] == 'success') {
       setState(() {
         _searchResults.removeWhere((item) => item['ID'] == id);
       });
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('El registro ha sido eliminado exitosamente.')),
       );
     } else {
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Text('Error'),
           content: const Text('No se pudo eliminar el registro.'),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Aceptar'),
             ),
           ],
         ),
       );
     }
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Eliminar Registro'),
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         children: [
           TextField(
             textCapitalization: TextCapitalization.characters,
             decoration: const InputDecoration(
               labelText: 'Buscar por nombre o apellido',
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.search),
             ),
             onChanged: (value) {
               setState(() {
                 _searchTerm = value;
               });
               if (_searchTerm.isNotEmpty) {
                 _buscarDatos();
               } else {
                 setState(() {
                   _searchResults = [];
                 });
               }
             },
           ),
           const SizedBox(height: 16),
           Expanded(
             child: ListView.builder(
               itemCount: _searchResults.length,
               itemBuilder: (context, index) {
                 final result = _searchResults[index];
                 final int id = result['ID'] is int
                     ? result['ID']
                     : int.tryParse(result['ID'].toString()) ?? 0;


                 return ListTile(
                   title: Text(result['NOMBRE']),
                   subtitle: Text('${result['APELLIDO_PAT']} ${result['APELLIDO_MAT']}'),
                   trailing: IconButton(
                     icon: const Icon(Icons.delete, color: Colors.red),
                     onPressed: () {
                       showDialog(
                         context: context,
                         builder: (context) => AlertDialog(
                           title: const Text('Confirmar Eliminación'),
                           content: Text(
                               '¿Estás seguro de que deseas eliminar el registro de ${result['NOMBRE']} ${result['APELLIDO_PAT']}?'),
                           actions: [
                             TextButton(
                               onPressed: () => Navigator.pop(context),
                               child: const Text('Cancelar'),
                             ),
                             TextButton(
                               onPressed: () {
                                 _eliminarRegistro(id);
                                 Navigator.pop(context);
                               },
                               child: const Text('Eliminar'),
                             ),
                           ],
                         ),
                       );
                     },
                   ),
                 );
               },
             ),
           ),
         ],
       ),
     ),
   );
 }
}

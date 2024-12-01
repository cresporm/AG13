import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ActualizarPage extends StatefulWidget {
  const ActualizarPage({super.key});

 @override
 _ActualizarPageState createState() => _ActualizarPageState();
}


class _ActualizarPageState extends State<ActualizarPage> {
 final _formKey = GlobalKey<FormState>();
 final TextEditingController _nombreController = TextEditingController();
 final TextEditingController _apellidoPaternoController = TextEditingController();
 final TextEditingController _apellidoMaternoController = TextEditingController();
 final TextEditingController _telefonoController = TextEditingController();
 final TextEditingController _correoController = TextEditingController();


 List<Map<String, dynamic>> _searchResults = [];
 String _searchTerm = '';


 @override
 void initState() {
   super.initState();
   _nombreController.addListener(() {
     _nombreController.value = TextEditingValue(
       text: _nombreController.text.toUpperCase(),
       selection: _nombreController.selection,
     );
   });
   _apellidoPaternoController.addListener(() {
     _apellidoPaternoController.value = TextEditingValue(
       text: _apellidoPaternoController.text.toUpperCase(),
       selection: _apellidoPaternoController.selection,
     );
   });
   _apellidoMaternoController.addListener(() {
     _apellidoMaternoController.value = TextEditingValue(
       text: _apellidoMaternoController.text.toUpperCase(),
       selection: _apellidoMaternoController.selection,
     );
   });
 }


 void _buscarDatos() async {
   final response = await http.post(
     Uri.parse('http://localhost/Students/sqloperations.php'),
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


 void _actualizarDatos(int id) async {
   final nombre = _nombreController.text;
   final apellidoPaterno = _apellidoPaternoController.text;
   final apellidoMaterno = _apellidoMaternoController.text;
   final telefono = _telefonoController.text;
   final correo = _correoController.text;


   if (_formKey.currentState!.validate()) {
     final response = await http.post(
       Uri.parse('http://192.168.0.78:8080/Students/sqloperations.php'),
       body: json.encode({
         "action": "UPDATE_DATA",
         "id": id,
         "nombre": nombre,
         "apellido_paterno": apellidoPaterno,
         "apellido_materno": apellidoMaterno,
         "telefono": telefono,
         "correo": correo,
       }),
       headers: {'Content-Type': 'application/json'},
     );


     if (response.statusCode == 200) {
       final result = json.decode(response.body);
       if (result['status'] == 'success') {
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: const Text('Actualización Exitosa'),
             content: const Text('El registro ha sido actualizado correctamente.'),
             actions: [
               TextButton(
                 onPressed: () => Navigator.pop(context),
                 child: const Text('Aceptar'),
               ),
             ],
           ),
         );
       } else {
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: const Text('Error'),
             content: const Text('Hubo un problema al actualizar el registro.'),
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
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Actualizar Datos'),
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
                   onTap: () {
                     _nombreController.text = result['NOMBRE'];
                     _apellidoPaternoController.text = result['APELLIDO_PAT'];
                     _apellidoMaternoController.text = result['APELLIDO_MAT'];
                     _telefonoController.text = result['TEL'];
                     _correoController.text = result['MAIL'];


                     showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Actualizar Registro'),
                         content: Form(
                           key: _formKey,
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               TextFormField(
                                 controller: _nombreController,
                                 decoration: const InputDecoration(labelText: 'Nombre'),
                                 textCapitalization: TextCapitalization.characters,
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Por favor ingresa un nombre';
                                   }
                                   return null;
                                 },
                               ),
                               TextFormField(
                                 controller: _apellidoPaternoController,
                                 decoration: const InputDecoration(labelText: 'Apellido Paterno'),
                                 textCapitalization: TextCapitalization.characters,
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Por favor ingresa el apellido paterno';
                                   }
                                   return null;
                                 },
                               ),
                               TextFormField(
                                 controller: _apellidoMaternoController,
                                 decoration: const InputDecoration(labelText: 'Apellido Materno'),
                                 textCapitalization: TextCapitalization.characters,
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Por favor ingresa el apellido materno';
                                   }
                                   return null;
                                 },
                               ),
                               TextFormField(
                                 controller: _telefonoController,
                                 decoration: const InputDecoration(labelText: 'Teléfono'),
                                 keyboardType: TextInputType.phone,
                                 maxLength: 10,
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Por favor ingresa un teléfono';
                                   }
                                   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                     return 'El teléfono debe contener solo números';
                                   }
                                   return null;
                                 },
                               ),
                               TextFormField(
                                 controller: _correoController,
                                 decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                                 keyboardType: TextInputType.emailAddress,
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Por favor ingresa un correo electrónico';
                                   }
                                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                     return 'Por favor ingresa un correo válido';
                                   }
                                   return null;
                                 },
                               ),
                             ],
                           ),
                         ),
                         actions: [
                           TextButton(
                             onPressed: () {
                               if (_formKey.currentState!.validate()) {
                                 _actualizarDatos(id);
                                 Navigator.pop(context);
                               } else {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(
                                     content: Text('Corrige los errores antes de actualizar.'),
                                   ),
                                 );
                               }
                             },
                             child: const Text('Actualizar'),
                           ),
                           TextButton(
                             onPressed: () => Navigator.pop(context),
                             child: const Text('Cancelar'),
                           ),
                         ],
                       ),
                     );
                   },
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


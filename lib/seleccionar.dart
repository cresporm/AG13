import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SeleccionarPage extends StatefulWidget {
  const SeleccionarPage({super.key});

 @override
 _SeleccionarPageState createState() => _SeleccionarPageState();
}


class _SeleccionarPageState extends State<SeleccionarPage> {
 final _formKey = GlobalKey<FormState>();
 final TextEditingController _nombreController = TextEditingController();
 final TextEditingController _apellidoPaternoController = TextEditingController();
 final TextEditingController _apellidoMaternoController = TextEditingController();
 final TextEditingController _telefonoController = TextEditingController();
 final TextEditingController _correoController = TextEditingController();


 List<Map<String, dynamic>> _registros = [];


 // Método para obtener todos los registros
 void _obtenerDatos() async {
   final response = await http.post(
     Uri.parse('http://localhost/Students/sqloperations.php'),
     body: json.encode({
       "action": "GET_ALL_DATA", // Nueva acción para obtener todos los registros
     }),
     headers: {'Content-Type': 'application/json'},
   );


   if (response.statusCode == 200) {
     final List<dynamic> results = json.decode(response.body);
     setState(() {
       _registros = results.map((data) => Map<String, dynamic>.from(data)).toList();
     });
   } else {
     print('Error al obtener los datos');
   }


   // Convertir a mayúsculas automáticamente mientras el usuario escribe
   _nombreController.addListener(() {
     _nombreController.text = _nombreController.text.toUpperCase();
     _nombreController.selection = TextSelection.collapsed(offset: _nombreController.text.length);
   });


   _apellidoPaternoController.addListener(() {
     _apellidoPaternoController.text = _apellidoPaternoController.text.toUpperCase();
     _apellidoPaternoController.selection = TextSelection.collapsed(offset: _apellidoPaternoController.text.length);
   });


   _apellidoMaternoController.addListener(() {
     _apellidoMaternoController.text = _apellidoMaternoController.text.toUpperCase();
     _apellidoMaternoController.selection = TextSelection.collapsed(offset: _apellidoMaternoController.text.length);
   });
 }


 // Método para actualizar un registro
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


 // Método para eliminar un registro
 void _eliminarRegistro(int id) async {
   final response = await http.post(
     Uri.parse('http://192.168.0.78:8080/Students/sqloperations.php'),
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
         _registros.removeWhere((item) => item['ID'] == id);
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
 void initState() {
   super.initState();
   _obtenerDatos(); // Obtener todos los registros cuando se inicie la página
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Seleccionar, Actualizar o Eliminar Registro'),
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         children: [
           Expanded(
             child: ListView.builder(
               itemCount: _registros.length,
               itemBuilder: (context, index) {
                 final result = _registros[index];
                 final int id = result['ID'] is int
                     ? result['ID']
                     : int.tryParse(result['ID'].toString()) ?? 0;


                 return ListTile(
                   title: Text(result['NOMBRE']),
                   subtitle: Text('${result['APELLIDO_PAT']} ${result['APELLIDO_MAT']}'),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       IconButton(
                         icon: const Icon(Icons.edit, color: Colors.blue),
                         onPressed: () {
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
                                       textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
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
                                       textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
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
                                       textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
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
                       ),
                       IconButton(
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
                     ],
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


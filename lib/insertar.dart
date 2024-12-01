import 'dart:convert';  // Necesario para convertir a JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class InsertarPage extends StatefulWidget {
  const InsertarPage({super.key});

 @override
 _InsertarPageState createState() => _InsertarPageState();
}


class _InsertarPageState extends State<InsertarPage> {
 final _formKey = GlobalKey<FormState>();


 // Controladores para capturar los datos
 final TextEditingController _nombreController = TextEditingController();
 final TextEditingController _apellidoPaternoController = TextEditingController();
 final TextEditingController _apellidoMaternoController = TextEditingController();
 final TextEditingController _telefonoController = TextEditingController();
 final TextEditingController _correoController = TextEditingController();


 @override
 void initState() {
   super.initState();


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


 // Función para guardar los datos y hacer la solicitud HTTP
 void _guardarDatos() async {
   if (_formKey.currentState!.validate()) {
     final nombre = _nombreController.text;
     final apellidoPaterno = _apellidoPaternoController.text;
     final apellidoMaterno = _apellidoMaternoController.text;
     final telefono = _telefonoController.text;
     final correo = _correoController.text;


     // Verificar los datos antes de enviarlos
     print('Datos enviados:');
     print('Nombre: $nombre');
     print('Apellido Paterno: $apellidoPaterno');
     print('Apellido Materno: $apellidoMaterno');
     print('Teléfono: $telefono');
     print('Correo: $correo');


     // Realizar la solicitud HTTP
     final response = await http.post(
       Uri.parse('http://localhost/Students/sqloperations.php'),
       body: json.encode({
         "action": "INSERT_DATA",
         "nombre": nombre,
         "apellido_paterno": apellidoPaterno,
         "apellido_materno": apellidoMaterno,
         "telefono": telefono,
         "correo": correo,
       }),
       headers: {'Content-Type': 'application/json'},
     );


     if (response.statusCode == 200) {
       // Mostrar un mensaje de éxito
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Text('Datos guardados'),
           content: const Text('Los datos han sido insertados correctamente en la base de datos.'),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Aceptar'),
             ),
           ],
         ),
       );
       // Limpiar los campos después de guardar
       _nombreController.clear();
       _apellidoPaternoController.clear();
       _apellidoMaternoController.clear();
       _telefonoController.clear();
       _correoController.clear();
     } else {
       // Mostrar un mensaje de error
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Text('Error'),
           content: const Text('Hubo un problema al insertar los datos en la base de datos.'),
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
       title: const Text('Insertar Datos'),
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Form(
         key: _formKey,
         child: ListView(
           children: [
             // Campo Nombre
             TextFormField(
               controller: _nombreController,
               textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
               decoration: const InputDecoration(
                 labelText: 'Nombre',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.person), // Icono de persona
               ),
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'El nombre es obligatorio';
                 }
                 return null;
               },
             ),
             const SizedBox(height: 16),
             // Campo Apellido Paterno
             TextFormField(
               controller: _apellidoPaternoController,
               textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
               decoration: const InputDecoration(
                 labelText: 'Apellido Paterno',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.account_circle), // Icono de usuario
               ),
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'El apellido paterno es obligatorio';
                 }
                 return null;
               },
             ),
             const SizedBox(height: 16),
             // Campo Apellido Materno
             TextFormField(
               controller: _apellidoMaternoController,
               textCapitalization: TextCapitalization.characters, // Convierte a mayúsculas
               decoration: const InputDecoration(
                 labelText: 'Apellido Materno',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.account_circle_outlined), // Icono de usuario alternativo
               ),
             ),
             const SizedBox(height: 16),
             // Campo Teléfono
             TextFormField(
               controller: _telefonoController,
               keyboardType: TextInputType.phone,
               decoration: const InputDecoration(
                 labelText: 'Teléfono',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.phone), // Icono de teléfono
               ),
               textCapitalization: TextCapitalization.none, // No se cambia la capitalización del teléfono
               maxLength: 10,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'El teléfono es obligatorio';
                 }
                 if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                   return 'El teléfono solo debe contener números';
                 }
                 return null;
               },
             ),
             const SizedBox(height: 16),
             // Campo Correo Electrónico
             TextFormField(
               controller: _correoController,
               keyboardType: TextInputType.emailAddress,
               decoration: const InputDecoration(
                 labelText: 'Correo Electrónico',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.email), // Icono de correo
               ),
               textCapitalization: TextCapitalization.none, // No se cambia la capitalización del correo
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'El correo es obligatorio';
                 }
                 if (!RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                   return 'Ingresa un correo válido';
                 }
                 return null;
               },
             ),
             const SizedBox(height: 32),
             // Botón Guardar
             ElevatedButton.icon(
               onPressed: _guardarDatos,
               icon: const Icon(Icons.save), // Icono para guardar
               label: const Text('Guardar'),
             ),
           ],
         ),
       ),
     ),
   );
 }
}


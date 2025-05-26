import 'package:app_uct/models/tema_model.dart';
import 'package:flutter/material.dart';

class PracticaScreen extends StatelessWidget {
  final Tema tema;
  const PracticaScreen({super.key, required this.tema});

  void descargarPractica() {
    print('DESCARGANDO ARCHIVO');
  }

  void subirPractica() {
    print('SUBIENDO PRACTICA');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Archivo de la práctica:"),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Ver practica"),
                trailing: ElevatedButton.icon(
                  onPressed: () => descargarPractica(),
                  icon: Icon(Icons.download),
                  label: Text('Descargar'),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('Tu entrega'),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.file_present),
                title: Text('Archivo subido'),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.visibility),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: subirPractica,
              icon: const Icon(Icons.upload_file),
              label: const Text("Subir práctica"),
            ),
            const SizedBox(height: 24),
            Text(
              "Calificación:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                "8 / 10",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green[100],
            ),
            const SizedBox(height: 24),
            Text(
              "Comentarios del docente:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            //COMENTARIOS
          ],
        ),
      ),
    );
  }
}

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EvaluacionIntroScreen extends StatefulWidget {
  final int idTema;

  const EvaluacionIntroScreen({super.key, required this.idTema});

  @override
  State<EvaluacionIntroScreen> createState() => _EvaluacionIntroScreenState();
}

class _EvaluacionIntroScreenState extends State<EvaluacionIntroScreen> {
  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(162, 157, 205, 1),
                Color.fromRGBO(165, 210, 241, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          tema.titulo,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Montserrat',
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 50,
          shadowColor: Colors.black,
          color: Colors.white,
          child: SizedBox(
            width: 300,
            height: 700,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(235, 221, 255, 1),
                    ),
                    child: Image.asset(
                      'assets/images/yowi_evaluacion.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Estimado estudiante.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '¡Estás por iniciar una evaluación! La calificación mínima es de 80. Esto contará como ${tema.intentosConsumidos + 1} oportunidad(es) de las ${tema.intentosDisponibles} disponibles. , Al aceptar, estás indicando que has revisado y entendido los contenidos previos y que estás listo para contestar tu evaluación. (Abrir la evaluación para sólo ver las preguntas ES HACER TRAMPA , aún cuando no contestes nada cuenta como una oportunidad)',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.evaluacion,
                        arguments: tema.idTema,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Contestar Evaluacion',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

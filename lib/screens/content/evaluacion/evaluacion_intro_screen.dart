// import 'dart:developer';

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
          tema.titulo ?? 'Titulo',
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
        child: FractionallySizedBox(
          heightFactor: 0.9, // 👈 Ocupa el 80% de la altura disponible
          child: Card(
            elevation: 50,
            shadowColor: Colors.black,
            color: Colors.white,
            child: SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          width: 300,
                          color: const Color.fromRGBO(235, 221, 255, 1),
                          child: Image.asset(
                            'assets/images/yowi_evaluacion.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Estimado estudiante.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tema.recursoBasicoTipo == 'EVALUACION'
                            ? '¡Estás por iniciar una evaluación! La calificación mínima es de 80. Esto contará como ${tema.intentosConsumidos + 1} oportunidad(es) de las ${tema.intentosDisponibles} disponibles. Al aceptar, estás indicando que has revisado y entendido los contenidos previos y que estás listo para contestar tu evaluación. (Abrir la evaluación solo para ver las preguntas **cuenta como una oportunidad**, incluso si no contestas nada).'
                            : tema.recursoBasicoTipo == 'ENCUESTA'
                            ? '¡Estás por iniciar una encuesta! Aquí no hay calificación mínima. Estos no tienen cantidad límite de intentos. ¡Buena suerte!'
                            : '',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              if (tema.recursoBasicoTipo == 'EVALUACION') {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.evaluacion,
                                  arguments: tema.idTema,
                                );
                              } else if (tema.recursoBasicoTipo == 'ENCUESTA') {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.encuesta,
                                  arguments: tema.idTema,
                                );
                              }
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
                            child: Center(
                              child: Text(
                                tema.recursoBasicoTipo == 'EVALUACION'
                                    ? 'Contestar Evaluación'
                                    : tema.recursoBasicoTipo == 'ENCUESTA'
                                    ? 'Contestar Encuesta'
                                    : '',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

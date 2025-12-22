// import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/dialogs/dialog_error_connection.dart';
import 'package:app_uct/widgets/dialogs/dialog_navegacion_temas.dart';
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

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;
    final isLandscape = size.width > size.height;

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
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            heightFactor: isSmall ? 0.85 : 0.9,
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
                              onPressed: () async {
                                if (tema.recursoBasicoTipo == 'EVALUACION') {
                                  try {
                                    final response = await competenciaProvider
                                        .validarTemasUnidad(
                                          tema.idUnidad,
                                          tema.idTema,
                                          tema.idCurso,
                                          tema.recursoBasicoTipo,
                                        );

                                    final comentario =
                                        response['comentario'] ?? '';

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.teal,
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            response['comentario'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (comentario.contains(
                                      'No tienes mas intentos',
                                    )) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (
                                            BuildContext dialogContext,
                                          ) {
                                            return DialogNavegacionTemas(
                                              title: "Estimado usuario",
                                              message:
                                                  'Lo siento no puedes contestar esta evaluación, ya consumiste todos los intentos',
                                              imagePath:
                                                  'assets/images/yowi_perfil.png',
                                              heightFactor:
                                                  isLandscape ? 0.2 : 0.4,
                                              actions: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          dialogContext,
                                                        ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(
                                                            dialogContext,
                                                          ).primaryColor,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 24,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Cerrar",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      return;
                                    } else if (comentario.contains(
                                      'No puede contestar esta encuesta',
                                    )) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (
                                            BuildContext dialogContext,
                                          ) {
                                            return DialogNavegacionTemas(
                                              title: "Estimado usuario",
                                              message:
                                                  'Lo siento no puedes contestar esta evaluación, no has visto todos los temas.',
                                              imagePath:
                                                  'assets/images/yowi_perfil.png',
                                              heightFactor:
                                                  isLandscape ? 0.2 : 0.4,
                                              actions: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          dialogContext,
                                                        ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(
                                                            dialogContext,
                                                          ).primaryColor,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 24,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Cerrar",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      return;
                                    }
                                  } catch (e) {
                                    if (e.toString().contains(
                                      'Sesión expirada.',
                                    )) {
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                        return;
                                      }
                                    }
                                    debugPrint('Error: $e');
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return DialogErrorConnection(
                                            title: "Problemas de conexión",
                                            message:
                                                "Error al validar los temas. Intenta de nuevo.",
                                            imagePath:
                                                'assets/images/YowiError.png',
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      dialogContext,
                                                    ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.grey.shade600,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: Text(
                                                  'Cerrar',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Color(0xFF574293),
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            'Error: $e',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.evaluacion,
                                      arguments: tema.idTema,
                                    );
                                  }
                                } else if (tema.recursoBasicoTipo ==
                                    'ENCUESTA') {
                                  try {
                                    final response = await competenciaProvider
                                        .validarEncuesta(
                                          tema.idTema,
                                          int.parse(tema.rutaRecurso),
                                        );
                                    if (response['count'] > 0) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            BuildContext dialogContext,
                                          ) {
                                            return DialogNavegacionTemas(
                                              title: "Estimado usuario",
                                              message:
                                                  "Ya respondió la encuesta, ¡gracias por su participación!",
                                              imagePath:
                                                  'assets/images/yowi_perfil.png',
                                              heightFactor:
                                                  isLandscape ? 0.2 : 0.4,
                                              actions: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          dialogContext,
                                                        ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(
                                                            dialogContext,
                                                          ).primaryColor,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 24,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Cerrar",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.teal,
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              response['comentario'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                  } catch (e) {
                                    if (e.toString().contains(
                                      'Sesión expirada.',
                                    )) {
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                        );
                                        return;
                                      }
                                    }
                                    // debugPrint('Error: $e');
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return DialogErrorConnection(
                                            title: "Problemas de conexión",
                                            message:
                                                "Error al validar la encuesta, intenta de nuevo.",
                                            imagePath:
                                                'assets/images/YowiError.png',
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      dialogContext,
                                                    ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.grey.shade600,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: Text(
                                                  'Aceptar',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    color: Color(0xFF574293),
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.encuesta,
                                      arguments: tema.idTema,
                                    );
                                  }
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
      ),
    );
  }
}

import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/dialogs/dialog_error_connection.dart';
import 'package:app_uct/widgets/dialogs/dialog_navegacion_temas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavegacionTemas {
  static Future<void> atrasarAdelantarTema(
    BuildContext parentContext,
    int accion,
    int idTema,
  ) async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      parentContext,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(idTema)!;
    final unidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );

    final screenSize = MediaQuery.of(parentContext).size;
    final isLandscape = screenSize.width > screenSize.height;

    log(
      'Tema actual: ${tema.idTema}, nombre: ${tema.titulo}, orden: ${tema.orden}',
    );

    try {
      final response = await competenciaProvider.adelantarAtrasarTemas(
        tema.idCurso,
        unidad.idUnidad,
        tema.orden,
        unidad.orden,
        accion,
      );
      if (response['tema_usuario'] == 0) {
        if (response['comentario'].contains('Ya no hay mas temas')) {
          if (parentContext.mounted) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
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
            showDialog(
              context: parentContext,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return DialogNavegacionTemas(
                  title: "Estimado usuario",
                  message: "No hay más temas para seguir explorando",
                  imagePath: 'assets/images/yowi_perfil.png',
                  heightFactor: isLandscape ? 0.2 : 0.4,
                  actions: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(dialogContext).primaryColor,
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
                          "Cerrar",
                          style: TextStyle(fontFamily: 'Montserrat'),
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
      } else {
        if (parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
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
        final nuevoTema =
            competenciaProvider.getTemaById(response['tema_usuario'])!;
        switch (nuevoTema.recursoBasicoTipo) {
          case 'VIDEO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.video,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'IMAGEN':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.imagen,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'DOCUMENTO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.pdf,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PDF':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.pdf,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'ARCHIVO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.archivo,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'ARTICULO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.articulo,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRESENCIAL':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.presencial,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRESENTACION':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.presentacion,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRACTICA':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.practica,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'INTERACTIVO':
          case 'TEMPLATE':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.interactive,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'ENCUESTA':
            try {
              final response = await competenciaProvider.validarEncuesta(
                nuevoTema.idTema,
                int.parse(nuevoTema.rutaRecurso),
              );

              if (response['count'] > 0) {
                if (parentContext.mounted) {
                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return DialogNavegacionTemas(
                        title: "Estimado Usuario",
                        message:
                            "Ya respondió la encuesta, ¡gracias por su aportación!",
                        imagePath: 'assets/images/yowi_perfil.png',
                        heightFactor: isLandscape ? 0.2 : 0.4,
                        actions: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(dialogContext).primaryColor,
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
                                "Cerrar",
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  ScaffoldMessenger.of(parentContext).showSnackBar(
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
              if (e.toString().contains('Sesión expirada.')) {
                if (parentContext.mounted) {
                  Navigator.pushReplacementNamed(
                    parentContext,
                    AppRoutes.login,
                  );
                  return;
                }
              }
              // debugPrint('Error: $e');
              if (parentContext.mounted) {
                showDialog(
                  context: parentContext,
                  builder: (BuildContext dialogContext) {
                    return DialogErrorConnection(
                      title: "Problemas de conexión",
                      message:
                          "Error al validar la encuesta, intenta de nuevo.",
                      imagePath: 'assets/images/YowiError.png',
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Aceptar',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color(0xFF574293),
                              decoration: TextDecoration.none,
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
            if (parentContext.mounted) {
              Navigator.pushNamed(
                parentContext,
                AppRoutes.evaluacionIntro,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'EVALUACION':
            try {
              final response = await competenciaProvider.validarTemasUnidad(
                nuevoTema.idUnidad,
                nuevoTema.idTema,
                nuevoTema.idCurso,
                nuevoTema.recursoBasicoTipo,
              );

              final comentario = response['comentario'] ?? '';

              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
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
              if (comentario.contains('No tienes mas intentos')) {
                if (parentContext.mounted) {
                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return DialogNavegacionTemas(
                        title: "Estimado usuario",
                        message:
                            'Lo siento no puedes contestar esta evaluación, ya consumiste todos los intentos',
                        imagePath: 'assets/images/yowi_perfil.png',
                        heightFactor: isLandscape ? 0.2 : 0.4,
                        actions: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(dialogContext).primaryColor,
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
                                "Cerrar",
                                style: TextStyle(fontFamily: 'Montserrat'),
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
                if (parentContext.mounted) {
                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return DialogNavegacionTemas(
                        title: "Estimado usuario",
                        message:
                            'Lo siento no puedes contestar esta evaluación, no has visto todos los temas.',
                        imagePath: 'assets/images/yowi_perfil.png',
                        heightFactor: isLandscape ? 0.2 : 0.4,
                        actions: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(dialogContext).primaryColor,
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
                                "Cerrar",
                                style: TextStyle(fontFamily: 'Montserrat'),
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
              if (e.toString().contains('Sesión expirada.')) {
                if (parentContext.mounted) {
                  Navigator.pushReplacementNamed(
                    parentContext,
                    AppRoutes.login,
                  );
                  return;
                }
              }
              debugPrint('Error: $e');
              if (parentContext.mounted) {
                showDialog(
                  context: parentContext,
                  builder: (BuildContext dialogContext) {
                    return DialogErrorConnection(
                      title: "Problemas de conexión",
                      message: "Error al validar los temas. Intenta de nuevo.",
                      imagePath: 'assets/images/YowiError.png',
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cerrar',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color(0xFF574293),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                ScaffoldMessenger.of(parentContext).showSnackBar(
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
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.evaluacionIntro,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          default:
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.recurso,
                arguments: nuevoTema.idTema,
              );
            }
            break;
        }
      }
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (parentContext.mounted) {
          Navigator.pushReplacementNamed(parentContext, AppRoutes.login);
        }
        return;
      }
      debugPrint('Error: $e');
      if (parentContext.mounted) {
        showDialog(
          context: parentContext,
          builder: (BuildContext dialogContext) {
            return DialogErrorConnection(
              title: "Problemas de conexión",
              message: "No se pudo navegar entre los temas. Intenta de nuevo.",
              imagePath: 'assets/images/YowiError.png',
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF574293),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al navegar entre temas: $e',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }
  }
}

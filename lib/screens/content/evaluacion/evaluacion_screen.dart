import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/utils/navegacion_temas.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/dialogs/dialog_error_connection.dart';
import 'package:app_uct/widgets/dialogs/dialog_navegacion_temas.dart';
import 'package:app_uct/widgets/evaluacion/question_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EvaluacionScreen extends StatefulWidget {
  final int idTema;

  const EvaluacionScreen({super.key, required this.idTema});

  @override
  State<EvaluacionScreen> createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool calificado = false;
  bool _hasConnectionError = false;

  Future<void> getFormularioEvaluacion() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final idEvaluacion = competenciaProvider.idEvaluacion;

    setState(() {
      evaluacionProvider.setLoading(true);
      evaluacionProvider.clearRespuestas();
      _hasConnectionError = false;
    });

    try {
      final response = await evaluacionProvider.getFormularioEvaluacion(
        idEvaluacion,
        3,
        tema.idUnidad,
        1,
      );

      await actualizarTemaVisto();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      setState(() {
        _hasConnectionError = true;
      });
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la evaluación: $e',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        evaluacionProvider.setLoading(false);
      });
    }
  }

  Future<void> actualizarTemaVisto() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    try {
      final response = await competenciaProvider.actualizarTemaUsuario(
        tema.idCurso,
        tema.idTema,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la evaluación: $e',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
      throw Exception('No se pudo registrar el intento');
    }
  }

  bool verificarRespuestas() {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final reactivos = evaluacionProvider.formulario!.reactivos;
    final respuestas = evaluacionProvider.respuestas;
    bool errores = false;

    for (var reactivo in reactivos) {
      if (reactivo.obligatorio == 'A') {
        final respuesta = respuestas.firstWhere(
          (r) => r['id_reactivo'] == reactivo.idReactivo,
          orElse: () => {},
        );

        if (respuesta.isEmpty) {
          evaluacionProvider.marcarError(reactivo.idReactivo, true);
          errores = true;
        } else {
          if (reactivo.idInput == 13) {
            final totalArray = respuesta['grupo_respuesta'].length;
            final opciones = reactivo.opciones.length;
            final totalGrupos = opciones / 2;

            if (totalArray == totalGrupos) {
              evaluacionProvider.marcarError(reactivo.idReactivo, false);
            } else {
              evaluacionProvider.marcarError(reactivo.idReactivo, true);
              errores = true;
            }
          } else if (reactivo.idInput == 6) {
            if (respuesta['respuesta']['opciones'] == null ||
                respuesta['respuesta']['opciones'].isEmpty) {
              evaluacionProvider.marcarError(reactivo.idReactivo, true);
              errores = true;
            } else {
              evaluacionProvider.marcarError(reactivo.idReactivo, false);
            }
          } else if (reactivo.idInput == 11) {
            if (respuesta['respuesta']['opciones'] == null ||
                respuesta['respuesta']['opciones'].length !=
                    reactivo.opciones.length) {
              evaluacionProvider.marcarError(reactivo.idReactivo, true);
              errores = true;
            } else {
              evaluacionProvider.marcarError(reactivo.idReactivo, false);
            }
          } else {
            evaluacionProvider.marcarError(reactivo.idReactivo, false);
          }
        }
      }
    }

    if (errores) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final screenSize = MediaQuery.of(dialogContext).size;
          final isLandscape = screenSize.width > screenSize.height;

          return DialogNavegacionTemas(
            title: "Estimado usuario",
            message:
                'Hay preguntas sin responder, por favor verifique que todas las preguntas esten respondidas e intente de nuevo',
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
    return errores;
  }

  Future<void> showResultadosEvaluacion(
    BuildContext parentContext,
    Map<String, dynamic> response,
  ) async {
    if (!parentContext.mounted) return;

    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final competenciaProvider = Provider.of<CompetenciaProvider>(
          dialogContext,
        );
        final evaluacionProvider = Provider.of<EvaluacionProvider>(
          dialogContext,
        );
        final tema = competenciaProvider.getTemaById(widget.idTema)!;
        final imageHeight = MediaQuery.of(dialogContext).size.height * 0.15;

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: imageHeight / 2,
                ), // Espacio para la imagen
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        response['resultado'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(dialogContext).primaryColor,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        response['resultado'] == 'APROBADO'
                            ? '¡FELICIDADES! Has aprobado tu evaluación'
                            : response['resultado'] == 'REPROBADO'
                            ? '¡INTENTA DE NUEVO! No has pasado tu evaluación :('
                            : '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Contador de intentos
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grade_rounded,
                                  color: Colors.grey.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Resultado: ${response['calificacion_total']}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey.shade700,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Ver evaluación'),
                          ),
                          if (tema.ordenUnidad < response['unidadMaxima'] &&
                              response['resultado'] == 'APROBADO')
                            ElevatedButton(
                              onPressed: () async {
                                evaluacionProvider.clearRespuestas();
                                Navigator.pop(dialogContext);
                                NavegacionTemas.atrasarAdelantarTema(
                                  context,
                                  1,
                                  widget.idTema,
                                );
                              },
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
                              child: const Text('Siguiente tema'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Imagen que sobresale (posición absoluta)
              Positioned(
                top: -(imageHeight / 2), // Hace que la imagen sobresalga
                child: SizedBox(
                  height: imageHeight,
                  child: Image.asset(
                    'assets/images/YowMitad.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFormularioEvaluacion();
    });
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> confirmExitDialog() async {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenSize = MediaQuery.of(dialogContext).size;
        final isLandscape = screenSize.width > screenSize.height;
        return DialogNavegacionTemas(
          title: '¿Salir de la evaluación?',
          message:
              'Si sales ahora, tus respuestas se perderán. ¿Deseas salir sin guardar?',
          imagePath: 'assets/images/yowi_perfil.png',
          heightFactor: isLandscape ? 0.2 : 0.4,
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      evaluacionProvider.clearRespuestas();
                      Navigator.pop(dialogContext, true);
                    },
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
                      'Salir',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final formulario = evaluacionProvider.formulario;
    final screenSize = MediaQuery.of(context).size;

    if (_hasConnectionError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: ConnectionErrorWidget(
          onRetry: getFormularioEvaluacion,
          message: 'Error al cargar la evaluación, intenta de nuevo.',
        ),
      );
    }

    if (evaluacionProvider.loading ||
        competenciaProvider.loadingDialog ||
        formulario == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            "assets/animations/3g-tracto.json",
            fit: BoxFit.cover,
            width: screenSize.width * 0.6,
            height: screenSize.width * 0.6,
          ),
        ),
      );
    }

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
          formulario.tituloFormulario,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Montserrat',
          ),
        ),
        leading: IconButton(
          onPressed: () async {
            final exit = await confirmExitDialog();
            if (exit && context.mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(201, 195, 218, 1),
                  Color.fromRGBO(233, 233, 233, 1),
                  Color.fromRGBO(212, 221, 235, 1),
                  Color.fromRGBO(218, 230, 240, 1),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: formulario.reactivos.length,
                    onPageChanged:
                        (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final reactivo = formulario.reactivos[index];
                      return QuestionCard(
                        idReactivo: reactivo.idReactivo,
                        index: index,
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                if (formulario.reactivos.length <= 10)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: formulario.reactivos.length,
                      effect: JumpingDotEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        dotColor: Color.fromRGBO(87, 84, 153, 1),
                        activeDotColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                if (formulario.reactivos.length > 10)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / formulario.reactivos.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(87, 84, 153, 1),
                      ),
                    ),
                  ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed:
                            _currentPage > 0
                                ? () => _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                )
                                : null,
                        icon: Icon(Icons.arrow_back),
                      ),
                      Text(
                        'Pregunta ${_currentPage + 1} de ${formulario.reactivos.length}',
                      ),
                      IconButton(
                        onPressed:
                            _currentPage < formulario.reactivos.length - 1
                                ? () => _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                )
                                : null,
                        icon: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
                if (!calificado)
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!verificarRespuestas()) {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final competenciaProvider =
                              Provider.of<CompetenciaProvider>(
                                context,
                                listen: false,
                              );
                          final tema = competenciaProvider.getTemaById(
                            widget.idTema,
                          );

                          final jsonEvaluacion = {
                            'id_user': authProvider.currentUsuario!.idUsuario,
                            'idencuesta': formulario.idFormulario,
                            'evaluacion': evaluacionProvider.respuestas,
                            'NoReactivos': formulario.reactivos.length,
                            'idcurso': tema!.idCurso,
                            'ordenunidad': tema.ordenUnidad,
                            'idMapaFuncional':
                                competenciaProvider
                                    .competencia!
                                    .idMapaFuncionalFk,
                            'saveRespuestas': {
                              'id_formu': formulario.idFormulario,
                              'id_sistema_fk': 0,
                              'id_categoria_fk': formulario.idCategoria,
                              'categoria_detalles': 0,
                              'sistema_detalles': 0,
                              'nombre': formulario.nombre,
                              'titulo_formulario': formulario.tituloFormulario,
                              'descripcion': formulario.descripcion,
                              'auto_update': '',
                              'estado': formulario.estado,
                              'id_tema_fk': formulario.idTema,
                              'registro_usuario': formulario.registroUsuario,
                              'registro_fecha': formulario.registroFecha,
                              'modificacion_usuario':
                                  formulario.modificacionUsuario,
                              'modificacion_fecha':
                                  formulario.modificacionFecha,
                              'id_area_encuesta_fk': formulario.idAreaEncuesta,
                              'reactivos': evaluacionProvider.respuestas,
                            },
                            'datostema': {
                              'id_tema': tema.idTema,
                              'titulo': tema.titulo,
                              'descripcion': tema.descripcion,
                              'duracion': tema.duracion,
                              'orden': tema.orden,
                              'estado': tema.estado,
                              'duracion_minutos': tema.duracionMinutos,
                              'reactivos_mostrar': tema.reactivosMostrar,
                              'id_unidad_fk': tema.idUnidad,
                              'intentos_consumidos': tema.intentosConsumidos,
                              'recurso_url': tema.recursoUrl,
                              'ruta_recurso': tema.rutaRecurso,
                              'slide_images': tema.slideImages,
                              'recurso_basico_tipo': tema.recursoBasicoTipo,
                              'id_tema_tipo_fk': tema.idTemaTipo,
                              'registro_fecha': tema.registroFecha,
                              'registro_usuario': tema.registroUsuario,
                              'modificacion_fecha': tema.modificacionFecha,
                              'modificacion_usuario': tema.modificacionUsuario,
                              'id_curso_fk': tema.idCurso,
                              'orden_unidad': tema.ordenUnidad,
                              'intentos_disponibles': tema.intentosDisponibles,
                              'resultado': tema.resultado,
                              'observaciones': tema.observaciones,
                            },
                          };

                          try {
                            final response = await evaluacionProvider
                                .guardarEvaluacion(jsonEvaluacion);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
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

                            _currentPage = 0;
                            calificado = true;

                            if (context.mounted) {
                              showResultadosEvaluacion(context, response);
                            }
                            competenciaProvider.actualizarEvaluacion(
                              widget.idTema,
                              response['calificacion_total'],
                            );
                          } catch (e) {
                            _currentPage = 0;
                            if (e.toString().contains('Sesión expirada.')) {
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                );
                              }
                              return;
                            }
                            debugPrint('Error: $e');
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return DialogErrorConnection(
                                    title: "Problemas de conexión",
                                    message:
                                        "No se pudo guardar la evaluación. Intenta de nuevo.",
                                    imagePath: 'assets/images/YowiError.png',
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(dialogContext),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Error al guardar la evaluación: $e',
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(87, 84, 153, 1),
                      ),
                      child: Center(
                        child: Text(
                          'Terminar evaluacion',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/dialogs/dialog_error_connection.dart';
import 'package:app_uct/widgets/dialogs/dialog_navegacion_temas.dart';
import 'package:app_uct/widgets/evaluacion/question_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EncuestaScreen extends StatefulWidget {
  final int idTema;

  const EncuestaScreen({super.key, required this.idTema});

  @override
  State<EncuestaScreen> createState() => _EncuestaScreenState();
}

class _EncuestaScreenState extends State<EncuestaScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool calificado = false;
  bool _hasConnectionError = false;

  Future<void> getFormularioEncuesta() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema);
    final idEncuesta = int.parse(tema!.rutaRecurso);

    setState(() {
      evaluacionProvider.setLoading(true);
      evaluacionProvider.clearRespuestas();
      _hasConnectionError = false;
    });

    try {
      final response = await evaluacionProvider.getFormularioEncuesta(
        idEncuesta,
        2,
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
      setState(() {
        _hasConnectionError = true;
      });
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la encuesta: $e',
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
          evaluacionProvider.marcarError(reactivo.idReactivo, false);
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
                        '¡Estimado usuario!',
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
                        'Queremos agradecerte por tomarte el tiempo para responder nuestra encuesta. Tus opiniones son muy valiosas para nosotros y nos ayudarán a mejorar nuestra plataforma y aplicación.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                parentContext,
                                AppRoutes.temario,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Salir'),
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
      getFormularioEncuesta();
    });
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          onRetry: getFormularioEncuesta,
          message: 'Error al cargar la encuesta, intenta de nuevo.',
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
          onPressed: () {
            evaluacionProvider.clearRespuestas();
            Navigator.pop(context);
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
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
                          'id_usuario': authProvider.currentUsuario!.idUsuario,
                          'id_encuesta': formulario.idFormulario,
                          'id_tema': tema!.idTema,
                          'reactivos': {
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
                            'modificacion_fecha': formulario.modificacionFecha,
                            'id_area_encuesta_fk': formulario.idAreaEncuesta,
                            'reactivos': evaluacionProvider.respuestas,
                          },
                        };

                        try {
                          final response = await evaluacionProvider
                              .guardarEncuesta(jsonEvaluacion);

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
                          competenciaProvider.registrarIntento(widget.idTema);
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
                                      "No se pudo guardar la encuesta. Intenta de nuevo.",
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
                                  'Error al guardar la encuesta: $e',
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
                        'Terminar encuesta',
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
        ],
      ),
    );
  }
}

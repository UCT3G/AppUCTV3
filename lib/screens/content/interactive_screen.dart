import 'dart:convert';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/utils/navegacion_temas.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InteractiveScreen extends StatefulWidget {
  final int idTema;

  const InteractiveScreen({super.key, required this.idTema});

  @override
  State<InteractiveScreen> createState() => _InteractiveScreenState();
}

class _InteractiveScreenState extends State<InteractiveScreen> {
  WebViewController? _webViewController;
  bool _hasConnectionError = false;
  bool _temaMarcado = false;
  bool _isMarking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cargarInteractivo();
    });
  }

  Future<void> cargarInteractivo() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    setState(() {
      _hasConnectionError = false;
    });

    String url = '';

    if (tema.recursoBasicoTipo == 'INTERACTIVO') {
      url =
          Uri.parse(
                'https://uct.tresguerras.com.mx:8000/static/interactive.html',
              )
              .replace(
                queryParameters: {
                  'materia': tema.idCurso.toString(),
                  'unidad': tema.idUnidad.toString(),
                  'tema': tema.idTema.toString(),
                  'ruta_recurso': tema.rutaRecurso,
                },
              )
              .toString();
    } else if (tema.recursoBasicoTipo == 'TEMPLATE') {
      final user = {
        'areas': [],
        'departamentos': [],
        'isLoggedIn': true,
        'modulo_activo': {
          'id_modulo': 0,
          'sistema': 'UCT COMPETENCIAS',
          'sistemaClic': 'UCT COMPETENCIAS',
        },
        'notificaciones': [],
        'oficinas': [],
        'perfiles': [],
        'permisos': {},
        'puestos': [],
        'token': authProvider.accessToken,
        'tokenCreationTime': DateTime.now().toIso8601String(),
        'userProfile': authProvider.currentUsuario,
      };

      final userJson = jsonEncode(user);
      final userEncoded = Uri.encodeComponent(userJson);

      url =
          Uri.parse('https://uct.tresguerras.com.mx:8002/templateContainer')
              .replace(
                queryParameters: {
                  'user': userEncoded,
                  'temaId': tema.idTema.toString(),
                  'cursoId': tema.idCurso.toString(),
                  'unidadId': tema.idUnidad.toString(),
                },
              )
              .toString();
    }

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('Loading: $progress%');
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint(
                  '❌ Error WebView: ${error.errorType} - ${error.description}',
                );

                // Solo marcar error si es un problema real de conexión o carga crítica
                if ((error.isForMainFrame ?? false) &&
                    (error.errorType == WebResourceErrorType.hostLookup ||
                        error.errorType ==
                            WebResourceErrorType.failedSslHandshake ||
                        error.errorType == WebResourceErrorType.connect ||
                        error.errorType == WebResourceErrorType.timeout)) {
                  setState(() {
                    _hasConnectionError = true;
                  });
                }
              },
              onPageFinished: (String finishedUrl) async {
                if (_temaMarcado || _isMarking) return;

                _isMarking = true;
                try {
                  final response = await competenciaProvider
                      .actualizarTemaUsuario(tema.idCurso, tema.idTema);
                  _temaMarcado = true; // solo marcar si fue exitoso
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
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                    return;
                  }
                  debugPrint('Error al marcar tema: $e');
                  setState(() {
                    _hasConnectionError = true;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Error al cargar el interactivo: $e',
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
                  _isMarking = false;
                }

                await _webViewController!.runJavaScript(
                  'document.querySelector("audio")?.play();',
                );
              },
              onUrlChange: (UrlChange change) {
                debugPrint('URL changed to ${change.url}');
              },
            ),
          )
          ..setUserAgent("Flutter/1.0")
          ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema);
    final currentUnidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema!.idUnidad,
    );
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;

    if (competenciaProvider.loadingDialog) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            "assets/animations/3g-tracto.json",
            fit: BoxFit.cover,
            width: size.width * 0.6,
            height: size.width * 0.6,
          ),
        ),
      );
    }

    if (_hasConnectionError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: ConnectionErrorWidget(
          onRetry: cargarInteractivo,
          message: 'Error al cargar el recurso, intenta de nuevo.',
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
          tema!.titulo ?? 'Titulo',
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_recursos.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - kToolbarHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      BreadcrumbNav(
                        paths: [
                          competenciaProvider.competencia!.titulo ??
                              'Competencia',
                          currentUnidad.titulo,
                          tema.titulo ?? 'Titulo',
                        ],
                      ),
                      Expanded(
                        child:
                            _webViewController != null
                                ? Builder(
                                  builder: (_) {
                                    final controller = _webViewController!;
                                    return WebViewWidget(
                                      controller: controller,
                                    );
                                  },
                                )
                                : Center(child: CircularProgressIndicator()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: isSmall ? 8 : 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 150),
                              child: ElevatedButton(
                                onPressed: () {
                                  NavegacionTemas.atrasarAdelantarTema(
                                    context,
                                    0,
                                    tema.idTema,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new_rounded),
                                    Text(
                                      'Atras',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 150),
                              child: ElevatedButton(
                                onPressed: () {
                                  NavegacionTemas.atrasarAdelantarTema(
                                    context,
                                    1,
                                    tema.idTema,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Adelante',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

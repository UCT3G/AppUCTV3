import 'dart:convert';
import 'dart:developer';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class InteractiveScreen extends StatefulWidget {
  final int idTema;

  const InteractiveScreen({super.key, required this.idTema});

  @override
  State<InteractiveScreen> createState() => _InteractiveScreenState();
}

class _InteractiveScreenState extends State<InteractiveScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tema = competenciaProvider.getTemaById(widget.idTema);

    String url = '';

    if (tema!.recursoBasicoTipo == 'INTERACTIVO') {
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

      log(Uri.decodeFull(url));

      log(url);
    }

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('Loading: $progress%');
              },
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Error: ${error.description}');
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
          Column(
            children: [
              BreadcrumbNav(
                paths: [
                  competenciaProvider.competencia!.titulo ?? 'Competencia',
                  currentUnidad.titulo,
                  tema.titulo ?? 'Titulo',
                ],
              ),
              Expanded(child: WebViewWidget(controller: _webViewController)),
              Padding(
                padding: EdgeInsets.only(bottom: isSmall ? 8 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          // atrasarAdelantarTema(context, 0);
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
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          // atrasarAdelantarTema(context, 1);
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
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

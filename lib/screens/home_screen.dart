import 'dart:math';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/competencia_card.dart';
import 'package:app_uct/widgets/competencia_card_horizontal.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/painter_home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;
  bool _showObligatorias = false;
  bool _showFiltrado = false;
  bool _hasConnectionError = false;

  Future<void> loadCompetencias() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );

    try {
      final response = await competenciaProvider.fetchCompetencias();
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
        rethrow;
      }
    }
  }

  Future<void> loadCompetenciasRecientes() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );

    try {
      final response = await competenciaProvider.fetchCompetenciasRecientes();
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
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
        rethrow;
      }
    }
  }

  Future<void> showSearchBottom(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final TextEditingController controller = TextEditingController();
    final imageHeight = MediaQuery.of(context).size.height * 0.15;
    final mensajes = [
      "¡Hola de nuevo! ¿Qué te gustaría buscar hoy?",
      "Dime qué necesitas... ¡Estoy listo!",
      "¿Qué competencia quieres encontrar?",
      "¡Es tu momento! ¿Qué quieres buscar?",
      "¡Vamos por más! ¿Qué competencia deseas explorar?",
      "¿Buscas algo en especial? Estoy aquí para ayudarte.",
      "¡Hey! ¿Qué curso necesitas encontrar?",
    ];

    final String mensajeElegido = mensajes[Random().nextInt(mensajes.length)];

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: EdgeInsets.only(top: imageHeight / 2),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 10, // espacio arriba para el contenido
                left: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo del modal
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(162, 157, 205, 1),
                    Color.fromRGBO(165, 210, 241, 1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(162, 157, 205, 1),
                        Color.fromRGBO(165, 210, 241, 1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          mensajeElegido,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: Color.fromRGBO(86, 66, 148, 1),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller,
                          style: TextStyle(fontFamily: 'Montserrat'),
                          decoration: InputDecoration(
                            hintText: 'Escribe aquí tu búsqueda...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final texto = controller.text.trim();
                            if (texto.isEmpty) return;

                            FocusScope.of(context).unfocus();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            try {
                              final response = await competenciaProvider
                                  .buscarCompetencias(texto);

                              if (!context.mounted) return;
                              Navigator.of(context, rootNavigator: true).pop();
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

                              setState(() {
                                _showFiltrado = true;
                              });
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                if (e.toString().contains('Sesión expirada.')) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                  return;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      final imageHeight =
                                          MediaQuery.of(
                                            dialogContext,
                                          ).size.height *
                                          0.30;

                                      return Center(
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: imageHeight / 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: imageHeight / 4,
                                                  bottom: 15,
                                                  right: 15,
                                                  left: 15,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Problemas de conexión",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 22,
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No se pudo realizar la búsqueda. Intenta de nuevo.",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 18,
                                                        color: Colors.grey,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            dialogContext,
                                                          ),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Aceptar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top:
                                                  -(imageHeight /
                                                      4), // Hace que la imagen sobresalga
                                              child: SizedBox(
                                                height: imageHeight,
                                                child: Image.asset(
                                                  'assets/images/YowiError.png',
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
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 5,
                            ),
                            backgroundColor: Color.fromRGBO(86, 66, 148, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Buscar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -(imageHeight / 2),
              right: 0,
              child: SizedBox(
                height: imageHeight,
                child: Image.asset(
                  'assets/images/YowMitad.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    setState(() {
      competenciaProvider.setLoading(true);
      _hasConnectionError = false;
    });

    try {
      await Future.wait([loadCompetenciasRecientes(), loadCompetencias()]);
    } catch (e) {
      setState(() {
        _hasConnectionError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          competenciaProvider.setLoading(false);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadData();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset >= 300 && !_showScrollButton) {
        setState(() {
          _showScrollButton = true;
        });
      } else if (_scrollController.offset < 300 && _showScrollButton) {
        setState(() {
          _showScrollButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);

    final screenSize = MediaQuery.of(context).size;

    if (competenciaProvider.loading) {
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

    if (_hasConnectionError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: ConnectionErrorWidget(
          onRetry: loadData,
          message:
              'Error al cargar las competencias del usuario, intenta de nuevo.',
        ),
      );
    }

    final listCompetencias =
        _showObligatorias
            ? competenciaProvider.competencias
                .where((c) => c.esObligatoria == '1')
                .toList()
            : _showFiltrado
            ? competenciaProvider.competenciasFiltradas
            : competenciaProvider.competencias;

    final listCompetenciasRecientes = competenciaProvider.competenciasRecientes;

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
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinear a la izquierda
          mainAxisSize:
              MainAxisSize.min, // Evita que el Column ocupe todo el espacio
          children: [
            Text(
              authProvider.currentUsuario!.nombreCompleto ?? 'Usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Montserrat',
              ),
            ),
            Text(
              authProvider.currentUsuario!.nombrePuesto ??
                  'Puesto', // Aquí tu puesto
              style: TextStyle(
                color: Colors.white.withValues(
                  alpha: 0.8,
                ), // Leve transparencia si quieres distinguirlo
                fontSize: 12, // Más pequeño que el nombre
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        leading: Icon(Icons.account_circle_rounded, color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
              await authProvider.logout();
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF575398), // #A29ECE
                  Color(0xFF84A9CA), // #A5D0EF
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: PainterHome())),
          Column(
            children: [
              // SECCION 1: FILTRADO COMPETENCIAS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(162, 157, 205, 1),
                              Color.fromRGBO(165, 210, 241, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _showObligatorias = !_showObligatorias;
                            });
                          }, // Acción para un filtro
                          icon: Icon(Icons.error),
                          color: _showObligatorias ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(162, 157, 205, 1),
                              Color.fromRGBO(165, 210, 241, 1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_showFiltrado) {
                              competenciaProvider.clearFiltro();
                              setState(() {
                                _showFiltrado = false;
                              });
                            } else {
                              showSearchBottom(context);
                            }
                          }, // Otro filtro
                          icon:
                              _showFiltrado
                                  ? Icon(Icons.close_rounded)
                                  : Icon(Icons.search),
                          color: _showFiltrado ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    listCompetencias.isEmpty
                        ? Center(
                          child: Text(
                            _showFiltrado
                                ? 'No se encontraron competencias.'
                                : 'No hay competencias disponibles.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                        : SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: listCompetenciasRecientes.length,
                                  itemBuilder: (context, index) {
                                    final competencia =
                                        listCompetenciasRecientes[index];
                                    return CompetenciaCardHorizontal(
                                      idCompetencia: competencia.idCurso ?? 0,
                                    );
                                  },
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: listCompetencias.length,
                                itemBuilder: (context, index) {
                                  final competencia = listCompetencias[index];
                                  return CompetenciaCard(
                                    idCompetencia: competencia.idCurso ?? 0,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          _showScrollButton
              ? FloatingActionButton(
                backgroundColor: Color.fromRGBO(86, 66, 148, 1),
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
              )
              : null,
    );
  }
}

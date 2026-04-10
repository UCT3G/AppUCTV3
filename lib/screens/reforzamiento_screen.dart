import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/competencia_card.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/painter_home.dart';
import 'package:app_uct/widgets/reforzamiento_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ReforzamientoScreen extends StatefulWidget {
  const ReforzamientoScreen({super.key});

  @override
  State<ReforzamientoScreen> createState() => _ReforzamientoScreenState();
}

class _ReforzamientoScreenState extends State<ReforzamientoScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showScrollButton = false;
  bool _hasConnectionError = false;

  Future<void> loadReforzamientos() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );

    setState(() {
      competenciaProvider.setLoading(true);
      _hasConnectionError = false;
    });

    try {
      final response =
          await competenciaProvider.fetchCompetenciasReforzamiento();

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
        setState(() {
          _hasConnectionError = true;
        });
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
    } finally {
      setState(() {
        competenciaProvider.setLoading(false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReforzamientos();
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ConnectionErrorWidget(
            onRetry: loadReforzamientos,
            message: 'Error al cargar los reforzamientos, intenta de nuevo.',
          ),
        ),
      );
    }

    final listCompetencias = competenciaProvider.competenciasReforzamiento;

    return Scaffold(
      key: _scaffoldKey,
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
            onPressed:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              ReforzamientoCard(
                imagePath: "assets/images/Yowi2.png",
                title: "Reforzamiento",
              ),
              Expanded(
                child:
                    listCompetencias.isEmpty
                        ? Center(
                          child: Text(
                            'No hay reforzamientos disponibles.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        )
                        : SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(
                              12,
                              12,
                              12,
                              MediaQuery.of(context).padding.bottom + 16,
                            ),
                            child: Column(
                              children: [
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

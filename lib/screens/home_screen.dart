import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/competencia_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      }
      debugPrint('Error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCompetencias();
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCION 1: FILTRADO COMPETENCIAS
            Text(
              'Filtrar competencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            //     Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {}, // Acción para un filtro
            //         child: Text('Por fecha'),
            //       ),
            //     ),
            //     SizedBox(width: 8),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {}, // Otro filtro
            //         child: Text('Por avance'),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 25),
            // SECCION 2: COMPETENCIAS RECIENTES
            Text(
              'Competencias recientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // SizedBox(
            //   height: 180,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: competenciaProvider.competencias.length.clamp(0, 5),
            //     itemBuilder: (context, index) {
            //       final competencia = competenciaProvider.competencias[index];
            //       return Container(
            //         width: 250,
            //         margin: EdgeInsets.only(right: 8),
            //         child: CompetenciaCard(competencia: competencia),
            //       );
            //     },
            //   ),
            // ),
            SizedBox(height: 25),
            // SECCION 3: TODAS LAS COMPETENCIAS
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: competenciaProvider.competencias.length,
              itemBuilder: (context, index) {
                final competencia = competenciaProvider.competencias[index];
                return CompetenciaCard(idCompetencia: competencia.idCurso ?? 0);
              },)
          ],
        ),
      ),
    );
  }
}

// Navigator.pushReplacementNamed(
//   context,
//   AppRoutes.temario,
//   arguments: {'fromHome': true},
// );

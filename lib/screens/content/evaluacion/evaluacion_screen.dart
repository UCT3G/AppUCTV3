import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
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

    try {
      final response = await evaluacionProvider.getFormularioEvaluacion(
        idEvaluacion,
        3,
        tema.idUnidad,
        1,
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
      debugPrint('Error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar el PDF: $e',
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

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final formulario = evaluacionProvider.formulario;
    final screenSize = MediaQuery.of(context).size;

    if (evaluacionProvider.loading || formulario == null) {
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
                  Color(0xFF575398), // #A29ECE
                  Color(0xFF84A9CA), // #A5D0EF
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                      dotColor: Colors.deepPurpleAccent,
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
                      Theme.of(context).primaryColor,
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
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    print(evaluacionProvider.respuestas);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Guardar evaluacion',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
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

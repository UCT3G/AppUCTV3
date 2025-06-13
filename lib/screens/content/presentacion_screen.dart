// import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/full_screen_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PresentacionScreen extends StatefulWidget {
  final int idTema;

  const PresentacionScreen({super.key, required this.idTema});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  void openFullScreen(int initialIndex) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FullScreenViewer(
              images:
                  tema.slideImages
                      .map(
                        (img) =>
                            '${ApiService.baseURL}/presentacion_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$img',
                      )
                      .toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
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
      debugPrint('Error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la presentación: $e',
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
      actualizarTemaVisto();
    });
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final currentUnidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;
    final padding = size.width * 0.04;

    final imageUrls =
        tema.slideImages
            .map(
              (img) =>
                  '${ApiService.baseURL}/presentacion_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$img',
            )
            .toList();

    return SafeArea(
      child: Scaffold(
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
            tema.titulo,
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
                  image: AssetImage('assets/images/background_videos.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => openFullScreen(index),
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 1,
                          maxScale: 4,
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.contain,
                            placeholder:
                                (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget:
                                (context, error, stackTrace) => const Center(
                                  child: Text(
                                    'Error al cargar la imagen',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isSmall ? 8 : 16),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: imageUrls.length,
                  effect: WormEffect(
                    dotHeight: isSmall ? 8 : 10,
                    dotWidth: isSmall ? 8 : 10,
                    activeDotColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: isSmall ? 6 : 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    'Diapositiva ${_currentPage + 1} de ${imageUrls.length}',
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            BreadcrumbNav(
              paths: [
                competenciaProvider.competencia!.titulo ?? 'Competencia',
                currentUnidad.titulo,
                tema.titulo,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

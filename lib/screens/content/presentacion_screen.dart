// import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/full_screen_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PresentacionScreen extends StatefulWidget {
  final Tema tema;

  const PresentacionScreen({super.key, required this.tema});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  void openFullScreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FullScreenViewer(
              images:
                  widget.tema.slideImages
                      .map(
                        (img) =>
                            '${ApiService.baseURL}/presentacion_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$img',
                      )
                      .toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;
    final padding = size.width * 0.04;

    final imageUrls =
        widget.tema.slideImages
            .map(
              (img) =>
                  '${ApiService.baseURL}/presentacion_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$img',
            )
            .toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tema.titulo),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
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
                                style: TextStyle(color: Colors.red),
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
                style: TextStyle(fontSize: isSmall ? 12 : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

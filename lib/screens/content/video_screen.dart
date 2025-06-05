import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final int idTema;

  const VideoScreen({super.key, required this.idTema});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _controllerInicializado = false;
  bool _videoLoading = true;

  Future<void> inicializarVideo() async {
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

      final videoURL = Uri.parse(
        '${ApiService.baseURL}/video_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}',
      );

      _controller = VideoPlayerController.networkUrl(videoURL);

      await _controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
      );

      _controllerInicializado = true;
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
              'Error al cargar el video: $e',
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
      _videoLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      inicializarVideo();
    });
  }

  @override
  void dispose() {
    if (_controllerInicializado) {
      _controller.dispose();
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final size = MediaQuery.of(context).size;

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
          // Fondo completo con dos imágenes apiladas (como una sola capa visual)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_videos.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/images/yowi_background.png',
                fit: BoxFit.cover,
                height: size.height * 0.3,
              ),
            ),
          ),

          // Contenido del video encima del fondo
          Center(
            child:
                _videoLoading
                    ? const CircularProgressIndicator()
                    : _controllerInicializado
                    ? Chewie(controller: _chewieController)
                    : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No se pudo cargar el video.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

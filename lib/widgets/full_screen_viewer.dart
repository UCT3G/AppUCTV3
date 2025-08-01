import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/sinImagen.png'
                  );
                },
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
              );
            },
          ),
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.03,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: size.width * 0.07,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

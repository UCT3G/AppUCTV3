import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class PageFour extends StatefulWidget {
  const PageFour({super.key});

  @override
  State<PageFour> createState() => _PageFourState();
}

class _PageFourState extends State<PageFour> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _animation1 = Tween<double>(begin: -100, end: 500).animate(_controller1)
      ..addListener(() {
        setState(() {});
      });
    _controller1.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: isLandscape ? screenWidth * 0.8 : screenHeight * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 360,
                          height: 640,
                          child: CustomPaint(painter: PageFourCustomPainter()),
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape ? screenWidth * 0.15 : screenHeight * 0.1,
                      left:
                          isLandscape ? screenWidth * 0.1 : screenWidth * 0.05,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella3.svg',
                        width: screenWidth * 0.08,
                        colorFilter: ColorFilter.mode(
                          const Color.fromRGBO(124, 173, 188, 1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? screenWidth * 0.25
                              : screenHeight * 0.15,
                      left:
                          isLandscape ? screenWidth * 0.05 : screenWidth * 0.05,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella3.svg',
                        width: screenWidth * 0.15,
                        colorFilter: ColorFilter.mode(
                          const Color.fromRGBO(124, 173, 188, 1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? screenWidth * 0.035
                              : screenHeight * 0.03,
                      left: _animation1.value,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/nube.svg',
                        width: screenWidth * 0.3,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 190, 216, 236),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? -screenWidth * 0.5
                              : -screenHeight *
                                  0.2, // súbelo un poco fuera del área
                      child: Lottie.asset(
                        'assets/images/onboarding/trailer_final.json',
                        fit: BoxFit.contain,
                        width:
                            isLandscape ? screenWidth * 0.8 : screenWidth * 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'En cualquier lugar, en todo momento',
                style: TextStyle(
                  color: Color(0xFF574293),
                  fontSize: screenWidth * 0.09,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Avanza en tu camino de aprendizaje.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: screenWidth * 0.06,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class PageFourCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 =
        Paint()
          ..color = const Color.fromARGB(255, 124, 173, 188)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.0666111, size.height * 0.2899687);
    path_0.cubicTo(
      size.width * -0.0055000,
      size.height * 0.1724375,
      size.width * 0.3891667,
      size.height * 0.1667969,
      size.width * 0.5820000,
      size.height * 0.2017188,
    );
    path_0.cubicTo(
      size.width * 1.4444722,
      size.height * 0.3780938,
      size.width * 1.3478889,
      size.height * 0.7012656,
      size.width * 1.0064444,
      size.height * 0.8051562,
    );
    path_0.cubicTo(
      size.width * -0.0263333,
      size.height * 1.0418750,
      size.width * -0.2997778,
      size.height * 0.7605469,
      size.width * -0.0384444,
      size.height * 0.6187187,
    );
    path_0.cubicTo(
      size.width * 0.0990000,
      size.height * 0.5465781,
      size.width * 0.2148333,
      size.height * 0.4877031,
      size.width * 0.0666111,
      size.height * 0.2899687,
    );
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Circle

    Paint paintFill1 =
        Paint()
          ..color = const Color.fromARGB(255, 124, 173, 188)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.8436944, size.height * 0.1754063);
    path_1.cubicTo(
      size.width * 0.8708889,
      size.height * 0.1754063,
      size.width * 0.9116944,
      size.height * 0.1861250,
      size.width * 0.9116944,
      size.height * 0.2136719,
    );
    path_1.cubicTo(
      size.width * 0.9116944,
      size.height * 0.2289844,
      size.width * 0.8913056,
      size.height * 0.2519375,
      size.width * 0.8436944,
      size.height * 0.2519375,
    );
    path_1.cubicTo(
      size.width * 0.8164722,
      size.height * 0.2519375,
      size.width * 0.7756667,
      size.height * 0.2404531,
      size.width * 0.7756667,
      size.height * 0.2136719,
    );
    path_1.cubicTo(
      size.width * 0.7756667,
      size.height * 0.1983750,
      size.width * 0.7960833,
      size.height * 0.1754063,
      size.width * 0.8436944,
      size.height * 0.1754063,
    );
    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class PageFive extends StatefulWidget {
  const PageFive({super.key});

  @override
  State<PageFive> createState() => _PageFiveState();
}

class _PageFiveState extends State<PageFive> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;
  late AnimationController _controller2;
  late Animation<double> _animation2;

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

    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    _animation2 = Tween<double>(begin: -100, end: 500).animate(_controller2)
      ..addListener(() {
        setState(() {});
      });
    _controller2.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
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
                          child: CustomPaint(painter: PageFiveCustomPainter()),
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape ? screenWidth * 0.1 : screenHeight * 0.01,
                      left:
                          isLandscape ? screenWidth * 0.01 : screenWidth * 0.05,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella.svg',
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
                              ? screenWidth * 0.02
                              : screenHeight * 0.01,
                      left: _animation1.value,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/nube.svg',
                        width: screenWidth * 0.25,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 190, 216, 236),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape ? screenWidth * 0.5 : screenHeight * 0.35,
                      right: _animation2.value,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/nube.svg',
                        width: screenWidth * 0.15,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 190, 216, 236),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? -screenWidth * 0.2
                              : -screenHeight *
                                  0.2, // súbelo un poco fuera del área
                      child: Lottie.asset(
                        'assets/images/onboarding/bienvenido_yowi.json',
                        fit: BoxFit.contain,
                        width:
                            isLandscape ? screenWidth * 0.6 : screenWidth * 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Listo, ya puedes comenzar',
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
                'Tu primer reto te está esperando.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: screenWidth * 0.05,
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

class PageFiveCustomPainter extends CustomPainter {
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
    path_0.moveTo(size.width * 0.9968056, size.height * 0.2579844);
    path_0.cubicTo(
      size.width * 1.2343611,
      size.height * 0.2148281,
      size.width * 1.2438056,
      size.height * 0.4542500,
      size.width * 1.1724444,
      size.height * 0.5710469,
    );
    path_0.cubicTo(
      size.width * 0.8123611,
      size.height * 1.0932969,
      size.width * 0.1605833,
      size.height * 1.0330625,
      size.width * -0.0474167,
      size.height * 0.8254531,
    );
    path_0.cubicTo(
      size.width * -0.5201944,
      size.height * 0.1978125,
      size.width * 0.0488611,
      size.height * 0.0333750,
      size.width * 0.3338333,
      size.height * 0.1925938,
    );
    path_0.cubicTo(
      size.width * 0.4787778,
      size.height * 0.2763594,
      size.width * 0.5970278,
      size.height * 0.3468906,
      size.width * 0.9968056,
      size.height * 0.2579844,
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
    path_1.moveTo(size.width * 0.7301667, size.height * 0.1879375);
    path_1.cubicTo(
      size.width * 0.7718056,
      size.height * 0.1812031,
      size.width * 0.8398333,
      size.height * 0.1819375,
      size.width * 0.8540833,
      size.height * 0.2098125,
    );
    path_1.cubicTo(
      size.width * 0.8620278,
      size.height * 0.2253125,
      size.width * 0.8426944,
      size.height * 0.2535938,
      size.width * 0.7697778,
      size.height * 0.2654063,
    );
    path_1.cubicTo(
      size.width * 0.7281111,
      size.height * 0.2721406,
      size.width * 0.6596667,
      size.height * 0.2706406,
      size.width * 0.6458056,
      size.height * 0.2435313,
    );
    path_1.cubicTo(
      size.width * 0.6378889,
      size.height * 0.2280469,
      size.width * 0.6572500,
      size.height * 0.1997344,
      size.width * 0.7301667,
      size.height * 0.1879375,
    );
    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

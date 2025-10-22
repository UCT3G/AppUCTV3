import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class PageOne extends StatefulWidget {
  const PageOne({super.key});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> with TickerProviderStateMixin {
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
                          child: CustomPaint(painter: PageOneCustomPainter()),
                        ),
                      ),
                    ),
                    Positioned(
                      top: isLandscape ? screenWidth * 0.2 : screenHeight * 0.1,
                      left:
                          isLandscape ? screenWidth * 0.1 : screenWidth * 0.15,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella3.svg',
                        width: screenWidth * 0.08,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 124, 173, 188),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape ? screenWidth * 0.15 : screenHeight * 0.1,
                      right: screenWidth * 0.1,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella3.svg',
                        width: screenWidth * 0.05,
                        colorFilter: ColorFilter.mode(
                          const Color.fromRGBO(124, 173, 188, 1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: isLandscape ? screenWidth * 0.5 : screenHeight * 0.3,
                      right:
                          isLandscape ? screenWidth * 0.3 : screenWidth * 0.2,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella3.svg',
                        width: screenWidth * 0.1,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? screenWidth * 0.035
                              : screenHeight * 0.025,
                      left: _animation1.value,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/nube.svg',
                        width: screenWidth * 0.2,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 190, 216, 236),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? screenWidth * 0.45
                              : screenHeight * 0.25,
                      right: _animation2.value,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/nube.svg',
                        width: screenWidth * 0.2,
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
                        'assets/images/onboarding/yowi_hablando.json',
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
                'Bienvenido',
                style: TextStyle(
                  color: Color(0xFF574293),
                  fontSize: screenWidth * 0.12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                '¿Listo para comenzar tu viaje de conocimientos?',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: screenWidth * 0.06,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageOneCustomPainter extends CustomPainter {
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
    path_0.moveTo(size.width * 0.4536111, size.height * 0.1657656);
    path_0.cubicTo(
      size.width * 0.7784722,
      size.height * 0.0550469,
      size.width * 1.0502500,
      size.height * 0.2117188,
      size.width * 0.9361389,
      size.height * 0.2808750,
    );
    path_0.cubicTo(
      size.width * 0.8121667,
      size.height * 0.3586250,
      size.width * 0.7138889,
      size.height * 0.3653750,
      size.width * 0.8032222,
      size.height * 0.4716406,
    );
    path_0.cubicTo(
      size.width * 0.8956944,
      size.height * 0.5454531,
      size.width * 1.2233056,
      size.height * 0.6723281,
      size.width * 0.7437778,
      size.height * 0.8185938,
    );
    path_0.cubicTo(
      size.width * 0.3830556,
      size.height * 0.8886250,
      size.width * 0.1993611,
      size.height * 0.8283750,
      size.width * 0.0315833,
      size.height * 0.6070937,
    );
    path_0.cubicTo(
      size.width * -0.0640278,
      size.height * 0.4435469,
      size.width * 0.1659167,
      size.height * 0.2835781,
      size.width * 0.4536111,
      size.height * 0.1657656,
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
    path_1.moveTo(size.width * 0.0439167, size.height * 0.7767031);
    path_1.cubicTo(
      size.width * 0.0640556,
      size.height * 0.7638750,
      size.width * 0.1199722,
      size.height * 0.7573125,
      size.width * 0.1860556,
      size.height * 0.7900625,
    );
    path_1.cubicTo(
      size.width * 0.2226667,
      size.height * 0.8082344,
      size.width * 0.2625556,
      size.height * 0.8451562,
      size.width * 0.2273056,
      size.height * 0.8676719,
    );
    path_1.cubicTo(
      size.width * 0.2071111,
      size.height * 0.8805625,
      size.width * 0.1493889,
      size.height * 0.8862344,
      size.width * 0.0852500,
      size.height * 0.8543594,
    );
    path_1.cubicTo(
      size.width * 0.0485278,
      size.height * 0.8361719,
      size.width * 0.0085556,
      size.height * 0.7992031,
      size.width * 0.0439167,
      size.height * 0.7767031,
    );
    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

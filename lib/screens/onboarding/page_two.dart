import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;
  late AnimationController _controller2;
  late Animation<double> _animation2;
  late AnimationController _controller3;
  late Animation<double> _animation3;

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

    _controller3 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 40),
    );
    _animation3 = Tween<double>(begin: -100, end: 500).animate(_controller3)
      ..addListener(() {
        setState(() {});
      });
    _controller3.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
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
                          child: CustomPaint(painter: PageTwoCustomPainter()),
                        ),
                      ),
                    ),
                    Positioned(
                      top:
                          isLandscape
                              ? screenWidth * 0.15
                              : screenHeight * 0.06,
                      left: isLandscape ? screenWidth * 0.1 : screenWidth * 0.1,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella2.svg',
                        width: screenWidth * 0.1,
                        colorFilter: ColorFilter.mode(
                          const Color.fromRGBO(124, 173, 188, 1),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: isLandscape ? screenWidth * 0.6 : screenHeight * 0.4,
                      right:
                          isLandscape ? screenWidth * 0.1 : screenWidth * 0.01,
                      child: SvgPicture.asset(
                        'assets/images/onboarding/estrella2.svg',
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
                              ? screenWidth * 0.25
                              : screenHeight * 0.15,
                      right: _animation2.value,
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
                      right: _animation3.value,
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
                              ? screenWidth * 0.035
                              : screenHeight * 0.02,
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
                              ? -screenWidth * 0.2
                              : -screenHeight *
                                  0.2, // súbelo un poco fuera del área
                      child: Lottie.asset(
                        'assets/images/onboarding/yowi_idea.json',
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
                'Impulsando el aprendizaje en Tresguerras',
                style: TextStyle(
                  color: Color(0xFF574293),
                  fontSize: screenWidth * 0.08,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Impulsamos tu aprendizaje y desarrollo profesional, facilitando el acceso al conocimiento de forma sencilla y moderna.',
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

class PageTwoCustomPainter extends CustomPainter {
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
    path_0.moveTo(size.width * -0.0778889, size.height * 0.3316562);
    path_0.cubicTo(
      size.width * 0.1421667,
      size.height * 0.0651094,
      size.width * 0.3604722,
      size.height * 0.2453594,
      size.width * 0.4761389,
      size.height * 0.2517344,
    );
    path_0.cubicTo(
      size.width * 0.7903333,
      size.height * 0.2777188,
      size.width * 0.7959167,
      size.height * 0.2312969,
      size.width * 0.9751111,
      size.height * 0.2592031,
    );
    path_0.cubicTo(
      size.width * 1.0632222,
      size.height * 0.2716719,
      size.width * 1.2626111,
      size.height * 0.4003594,
      size.width * 1.0618333,
      size.height * 0.5714531,
    );
    path_0.cubicTo(
      size.width * 0.9390000,
      size.height * 0.6860625,
      size.width * 1.0929722,
      size.height * 0.9521563,
      size.width * 0.7605000,
      size.height * 0.9882031,
    );
    path_0.cubicTo(
      size.width * 0.1116944,
      size.height * 1.0214375,
      size.width * -0.2999167,
      size.height * 0.6371094,
      size.width * -0.0778889,
      size.height * 0.3316562,
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
    path_1.moveTo(size.width * 0.9345278, size.height * 0.1559062);
    path_1.cubicTo(
      size.width * 0.9781389,
      size.height * 0.1559062,
      size.width * 1.0435556,
      size.height * 0.1669687,
      size.width * 1.0435556,
      size.height * 0.1954063,
    );
    path_1.cubicTo(
      size.width * 1.0435556,
      size.height * 0.2112344,
      size.width * 1.0108333,
      size.height * 0.2349531,
      size.width * 0.9345278,
      size.height * 0.2349531,
    );
    path_1.cubicTo(
      size.width * 0.8909167,
      size.height * 0.2349531,
      size.width * 0.8255000,
      size.height * 0.2230781,
      size.width * 0.8255000,
      size.height * 0.1954063,
    );
    path_1.cubicTo(
      size.width * 0.8255000,
      size.height * 0.1796094,
      size.width * 0.8582222,
      size.height * 0.1559062,
      size.width * 0.9345278,
      size.height * 0.1559062,
    );
    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

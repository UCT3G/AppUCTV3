import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageThree extends StatelessWidget {
  const PageThree({super.key});

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
              const SizedBox(height: 20),
              Text(
                'Nuestras facultades están diseñadas para acompañar tu desarrollo',
                style: TextStyle(
                  color: Color(0xFF574293),
                  fontSize: screenWidth * 0.06,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/Liderazgo.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Liderazgo',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/calidad.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Calidad',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/comercial.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Comercial',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/tractocamion.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Tractocamión',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/talentoh.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Talento humano',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/montacargas.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Montacargas',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth * 0.8,
                height: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: isLandscape ? screenWidth * 0.18 : screenHeight * 0.09,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Color(0xFF86cbc8), Color(0xFF574293)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          'assets/images/onboarding/camioneta.svg',
                          width: screenWidth * 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: Text(
                          'Chofer de camioneta',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:app_uct/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF84A9CA), // #A5D0EF
                  Color(0xFF575398), // #A29ECE
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: WavePainter())),
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: Image.asset(
              "assets/images/lil_claud.png",
              width: screenWidth * 0.2,
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: -screenWidth * 0.15,
            child: Image.asset(
              "assets/images/big_claud.png",
              width: screenWidth * 0.5,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: -screenWidth * 0.1,
            child: Image.asset(
              "assets/images/medium_claud.png",
              width: screenWidth * 0.4,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/logo_uct_white.svg",
                    width: screenWidth * 0.8,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white30,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white30,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color.fromRGBO(128, 185, 204, 1),
                        ),
                        hintText: 'Usuario',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white30,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white30,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(
                          Icons.password,
                          color: Color.fromRGBO(128, 185, 204, 1),
                        ),
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Ingresar',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

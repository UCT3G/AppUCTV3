import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/splash_screen.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:app_uct/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;
  late AnimationController _controller2;
  late Animation<double> _animation2;
  late AnimationController _controller3;
  late Animation<double> _animation3;
  BiometricType? _biometricType;
  Future<BiometricType?>? _biometricTypeFuture;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoadingCredentials = false;
  bool _isLoadingBiometrics = false;
  bool _isBiometricAvailable = false;
  bool _hasStoredCredentials = false;

  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(context, listen: false);

  // METODO PARA INICIAR SESION CON CREDENCIALES
  void login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Por favor, ingrese usuario y contraseña',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingCredentials = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => PopScope(
            canPop: false,
            child: SplashScreen(isInitialLoad: false),
          ),
    );

    try {
      final response = await authProvider.login(username, password);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response['access_token'] != null) {
        final isBiometricAuthEnabled =
            await authProvider.hasBiometricPreference();

        if (!isBiometricAuthEnabled && _isBiometricAvailable) {
          await showSaveCredentialsDialog();
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
              content: Text(
                response['message'],
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Error al iniciar sesión',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error: $e',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
  }

  // METODO PARA VERIFICAR SI EL DISPOSITIVO SOPORTA AUTENTICACION BIOMETRICA
  Future<void> checkBiometricAvailability() async {
    bool isAvailable = await authProvider.isBiometricAuthEnabled();

    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  // METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<void> loginWithBiometrics() async {
    setState(() {
      _isLoadingBiometrics = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: SplashScreen(isInitialLoad: false),
          ),
    );

    try {
      final response = await authProvider.loginWithBiometrics();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (response['access_token'] != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              response['message'],
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Autenticación biométrica fallida',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error: $e',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBiometrics = false;
        });
      }
    }
  }

  // METODO PARA VERIFICAR SI HAY CREDENCIALES GUARDADAS
  Future<void> checkStoredCredentials() async {
    bool hasCredentials = await TokenService.hasCredentials();
    setState(() {
      _hasStoredCredentials = hasCredentials;
    });
  }

  // METODO PARA ABRIR EL ALERT DIALOG PARA GUARDAR CREDENCIALES
  Future<void> showSaveCredentialsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            '¿Guardar credenciales?',
            style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 15)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Deseas guardar tus credenciales para futuros inicios de sesión biométricos?',
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await authProvider.enableBiometricAuth();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Aceptar',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await authProvider.disableBiometricAuth();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // METODO PRA OBTENER EL TIPO DE AUTENTICACION BIOMETRICA
  Future<BiometricType?> getPrimaryBiometricType() async {
    try {
      final availableBiometrics = await authProvider.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return BiometricType.iris;
      }

      if (availableBiometrics.isNotEmpty) {
        return availableBiometrics.first; // Devuelve el primero disponible
      }

      return null;
    } catch (e) {
      debugPrint('Error al obtener el tipo de biómetrico: $e');
      return null;
    }
  }

  Future<void> loadBiometricType() async {
    _biometricTypeFuture = getPrimaryBiometricType();
    _biometricType = await _biometricTypeFuture;
    if (mounted) {
      setState(() {});
    }
  }

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
      duration: Duration(seconds: 30),
    );
    _animation3 = Tween<double>(begin: -100, end: 500).animate(_controller3)
      ..addListener(() {
        setState(() {});
      });
    _controller3.repeat();

    checkStoredCredentials();
    checkBiometricAvailability();
    loadBiometricType();
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
            right: _animation1.value,
            child: Image.asset(
              "assets/images/lil_claud.png",
              width: screenWidth * 0.2,
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: _animation2.value,
            child: Image.asset(
              "assets/images/big_claud.png",
              width: screenWidth * 0.5,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: _animation3.value,
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
                    "assets/images/UCT.svg",
                    width: screenWidth * 0.3,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      controller: _usernameController,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
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
                        hintStyle: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: TextFormField(
                      controller: _passwordController,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
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
                        hintStyle: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    onPressed:
                        _isLoadingCredentials
                            ? null
                            : () => login(
                              _usernameController.text,
                              _passwordController.text,
                            ),
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
                    child:
                        _isLoadingCredentials
                            ? CircularProgressIndicator()
                            : Text(
                              'Ingresar',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  if (_isBiometricAvailable && _hasStoredCredentials)
                    _biometricType != null
                        ? ElevatedButton(
                          onPressed:
                              _isLoadingBiometrics
                                  ? null
                                  : () => loginWithBiometrics(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              _isLoadingBiometrics
                                  ? CircularProgressIndicator()
                                  : Column(
                                    children: [
                                      Icon(
                                        _biometricType == BiometricType.face
                                            ? Icons.face
                                            : _biometricType ==
                                                BiometricType.iris
                                            ? Icons.remove_red_eye
                                            : Icons.fingerprint,
                                        color: Colors.black,
                                        size: screenHeight * 0.08,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        _biometricType == BiometricType.face
                                            ? 'Reconocimiento facial'
                                            : _biometricType ==
                                                BiometricType.iris
                                            ? 'Reconocimiento de iris'
                                            : 'Huella dactilar',
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        )
                        : CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

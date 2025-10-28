// import 'dart:developer';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/splash_screen.dart';
import 'package:app_uct/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoadingCredentials = false;
  bool _isLoadingBiometrics = false;
  bool _lockAvailable = false;
  bool _biometricsAvailable = false;
  bool _passwordIncorrect = false;

  BiometricType? _biometricType;
  Future<BiometricType?>? _biometricTypeFuture;

  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(context, listen: false);

  // METODO PARA INICIAR SESION POR PRIMERA VEZ
  void login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Por favor, ingrese usuario y contraseña.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.redAccent,
              fontSize: 14,
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

      if (response['success'] == true && response['access_token'] != null) {
        await showSaveCredentialsDialog();

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
              content: Text(
                response['message'],
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 14,
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
                response['message'],
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.redAccent,
                  fontSize: 14,
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
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
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

      if (response['success'] == true && response['access_token'] != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              response['message'],
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      } else {
        final tipo = response['tipo'];

        if (tipo == 1) {
          _passwordIncorrect = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  response['message'],
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.redAccent,
                    fontSize: 14,
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
                  response['message'],
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }
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
      if (mounted) {
        setState(() {
          _isLoadingBiometrics = false;
        });
      }
    }
  }

  //METODO PARA INICIAR SESION CON EL BLOQUEO DE PANTALLA (PATRON, PIN, ECT.)
  Future<void> loginWithDeviceLock() async {
    setState(() {
      _isLoadingBiometrics = true;
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
      final response = await authProvider.loginWithLockScreen();

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
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
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
                'Autenticación fallida.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Error: $e',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.redAccent,
              fontSize: 14,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBiometrics = false;
        });
      }
    }
  }

  // METODO PARA INICIAR SESION SIN BLOQUEO DE PANTALLA
  Future<void> loginWithCredentials() async {
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
      final response = await authProvider.loginWithCredentials();

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
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
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
                'Autenticación fallida.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Error: $e',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.redAccent,
              fontSize: 14,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
  }

  // METODO PARA ABRIR EL ALERT DIALOG PARA GUARDAR CREDENCIALES
  Future<void> showSaveCredentialsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final imageHeight = MediaQuery.of(dialogContext).size.height * 0.25;

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: imageHeight / 2,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Guardar credenciales',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(dialogContext).primaryColor,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Estimado usuario, sus credenciales serán guardadas para futuros inicios de sesión.',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(dialogContext).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -(imageHeight / 2),
                child: SizedBox(
                  height: imageHeight,
                  child: Image.asset(
                    'assets/images/ModalYowi.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // METODO PARA VERIFICAR EL TIPO DE BLOQUEO DE PANTALLA HABILITADO
  Future<void> checkAvailability() async {
    final biometricsAvailable = await authProvider.isBiometricAvailable();
    final lockAvailable = await authProvider.isLockScreen();

    setState(() {
      _biometricsAvailable = biometricsAvailable;
      _lockAvailable = !biometricsAvailable && lockAvailable;
    });
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
        return availableBiometrics.first;
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

    checkAvailability();
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
    final isLandscape = screenWidth > screenHeight;

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
          Positioned(
            top: screenHeight * 0.05,
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
              },
              icon: Icon(Icons.home, color: Colors.white, size: 30),
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
                    width: isLandscape ? screenWidth * 0.15 : screenWidth * 0.3,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  if (authProvider.username == null) ...[
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
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
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
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
                            fontFamily: 'Montserrat',
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
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                    ),
                  ] else if (_passwordIncorrect) ...[
                    SizedBox(
                      width: double.infinity, // ocupa todo el ancho
                      child: Text(
                        'BIENVENIDA/O DE NUEVO:',
                        textAlign: TextAlign.center, // ahora sí se centra bien
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Text(
                      authProvider.username ?? 'Usuario',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
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
                            fontFamily: 'Montserrat',
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
                                authProvider.username ?? '',
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
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity, // ocupa todo el ancho
                      child: Text(
                        'BIENVENIDA/O DE NUEVO:',
                        textAlign: TextAlign.center, // ahora sí se centra bien
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Text(
                      authProvider.username ?? 'Usuario',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_biometricsAvailable) ...[
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
                                              ? 'Face ID'
                                              : _biometricType ==
                                                  BiometricType.iris
                                              ? 'Iris'
                                              : 'Huella dactilar',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                          )
                          : CircularProgressIndicator(),
                    ] else if (_lockAvailable) ...[
                      ElevatedButton(
                        onPressed:
                            _isLoadingBiometrics
                                ? null
                                : () => loginWithDeviceLock(),
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
                            _isLoadingBiometrics
                                ? CircularProgressIndicator()
                                : Icon(
                                  Icons.lock,
                                  color: Colors.black45,
                                  size: screenHeight * 0.05,
                                ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed:
                            _isLoadingCredentials
                                ? null
                                : () => loginWithCredentials(),
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
                                  'Ingresar nuevamente',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

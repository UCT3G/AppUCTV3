import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/biometric_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:app_uct/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController controller1;
  late Animation<double> animation1;
  late AnimationController controller2;
  late Animation<double> animation2;
  late AnimationController controller3;
  late Animation<double> animation3;
  final AuthService authService = AuthService();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoadingCredentials = false;
  bool isLoadingBiometrics = false;
  bool isBiometricAvailable = false;
  bool hasStoredCredentials = false;

  // METODO PARA INICIAR SESION CON CREDENCIALES
  void login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese usuario y contraseña')),
      );
      return;
    }

    setState(() {
      isLoadingCredentials = true;
    });

    try {
      final response = await AuthService.login(username, password);

      if (response['access_token'] != null) {
        final isBiometricAuthEnabled =
            await AuthService.isBiometricAuthEnabled();

        if (!isBiometricAuthEnabled && isBiometricAvailable) {
          await showSaveCredentialsDialog();
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCredentials = false;
        });
      }
    }
  }

  // METODO PARA VERIFICAR SI EL DISPOSITIVO SOPORTA AUTENTICACION BIOMETRICA
  Future<void> checkBiometricAvailability() async {
    bool isAvailable =
        await authService.biometricService.isBiometricAvailable();

    setState(() {
      isBiometricAvailable = isAvailable;
    });
  }

  // METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<void> loginWithBiometrics() async {
    setState(() {
      isLoadingBiometrics = true;
    });

    try {
      bool isAuthenticated = await authService.loginWithBiometrics();

      if (isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autenticación biométrica fallida')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoadingBiometrics = false;
        });
      }
    }
  }

  // METODO PARA VERIFICAR SI HAY CREDENCIALES GUARDADAS
  Future<void> checkStoredCredentials() async {
    bool hasCredentials = await TokenService.hasCredentials();
    setState(() {
      hasStoredCredentials = hasCredentials;
    });
  }

  // METODO PARA ABRIR EL ALERT DIALOG PARA GUARDAR CREDENCIALES
  Future<void> showSaveCredentialsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Guardar credenciales?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Deseas guardar tus credenciales para futuros inicios de sesión biométricos?',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AuthService.enableBiometricAuth();
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.disableBiometricAuth();
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // METODO PARA CHECAR SI SE ACTIVARON BIOMETRICOS O NO
  Future<void> checkBiometricAuthEnabled() async {
    final isEnabled = await AuthService.isBiometricAuthEnabled();
    if (!isEnabled && isBiometricAvailable) {
      await showSaveCredentialsDialog();
    }
  }

  // METODO PRA OBTENER EL TIPO DE AUTENTICACION BIOMETRICA
  Future<BiometricType?> getPrimaryBiometricType() async {
    final availableBiometrics =
        await authService.biometricService.getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return BiometricType.iris;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    animation1 = Tween<double>(begin: -100, end: 500).animate(controller1)
      ..addListener(() {
        setState(() {});
      });
    controller1.repeat();

    controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    animation2 = Tween<double>(begin: -100, end: 500).animate(controller2)
      ..addListener(() {
        setState(() {});
      });
    controller2.repeat();

    controller3 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
    animation3 = Tween<double>(begin: -100, end: 500).animate(controller3)
      ..addListener(() {
        setState(() {});
      });
    controller3.repeat();

    checkStoredCredentials();
    checkBiometricAvailability();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
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
            right: animation1.value,
            child: Image.asset(
              "assets/images/lil_claud.png",
              width: screenWidth * 0.2,
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: animation2.value,
            child: Image.asset(
              "assets/images/big_claud.png",
              width: screenWidth * 0.5,
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            right: animation3.value,
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
                      controller: usernameController,
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
                      controller: passwordController,
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
                    onPressed:
                        isLoadingCredentials
                            ? null
                            : () => login(
                              usernameController.text,
                              passwordController.text,
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
                        isLoadingCredentials
                            ? CircularProgressIndicator()
                            : Text(
                              'Ingresar',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                              ),
                            ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  if (isBiometricAvailable && hasStoredCredentials)
                    FutureBuilder<BiometricType?>(
                      future: getPrimaryBiometricType(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final biometricType = snapshot.data;

                        return ElevatedButton(
                          onPressed:
                              isLoadingBiometrics ? null : loginWithBiometrics,
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
                              isLoadingBiometrics
                                  ? CircularProgressIndicator()
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        biometricType == BiometricType.face
                                            ? Icons.face
                                            : biometricType ==
                                                BiometricType.iris
                                            ? Icons.remove_red_eye
                                            : Icons.fingerprint,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                        );
                      },
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

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/splash_screen.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/token_service.dart';
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
  late AnimationController controller1;
  late Animation<double> animation1;
  late AnimationController controller2;
  late Animation<double> animation2;
  late AnimationController controller3;
  late Animation<double> animation3;
  final AuthService authService = AuthService();
  BiometricType? biometricType;
  Future<BiometricType?>? biometricTypeFuture;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoadingCredentials = false;
  bool isLoadingBiometrics = false;
  bool isBiometricAvailable = false;
  bool hasStoredCredentials = false;

  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(context, listen: false);

  // METODO PARA INICIAR SESION CON CREDENCIALES
  void login(
    String username,
    String password,
    AuthProvider authProvider,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese usuario y contraseña')),
      );
      return;
    }

    setState(() {
      isLoadingCredentials = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PopScope(canPop: false, child: SplashScreen()),
    );

    try {
      final response = await AuthService.login(
        username,
        password,
        authProvider,
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response['access_token'] != null) {
        final isBiometricAuthEnabled =
            await AuthService.isBiometricAuthEnabled();

        if (!isBiometricAuthEnabled && isBiometricAvailable) {
          await showSaveCredentialsDialog();
        }

        await authProvider.updateAccessToken(response['access_token']);
        await authProvider.updateRefreshToken(response['refresh_token']);

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión')));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
  Future<void> loginWithBiometrics(AuthProvider authProvider) async {
    setState(() {
      isLoadingBiometrics = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(canPop: false, child: SplashScreen()),
    );

    try {
      bool isAuthenticated = await authService.loginWithBiometrics(
        authProvider,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (isAuthenticated) {
        if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Autenticación biométrica fallida')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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

  // METODO PRA OBTENER EL TIPO DE AUTENTICACION BIOMETRICA
  Future<BiometricType?> getPrimaryBiometricType() async {
    try {
      final availableBiometrics =
          await authService.biometricService.getAvailableBiometrics();

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
      print('Error al obtener el tipo de biómetrico: $e');
      return null;
    }
  }

  Future<void> loadBiometricType() async {
    biometricTypeFuture = getPrimaryBiometricType();
    biometricType = await biometricTypeFuture;
    if (mounted) {
      setState(() {});
    }
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
    loadBiometricType();
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
    final authProvider = Provider.of<AuthProvider>(context);
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
                              authProvider,
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
                    biometricType != null
                        ? ElevatedButton(
                          onPressed:
                              isLoadingBiometrics
                                  ? null
                                  : () => loginWithBiometrics(authProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              isLoadingBiometrics
                                  ? CircularProgressIndicator()
                                  : Column(
                                    children: [
                                      Icon(
                                        biometricType == BiometricType.face
                                            ? Icons.face
                                            : biometricType ==
                                                BiometricType.iris
                                            ? Icons.remove_red_eye
                                            : Icons.fingerprint,
                                        color: Colors.black,
                                        size: screenHeight * 0.08,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        biometricType == BiometricType.face
                                            ? 'Reconocimiento facial'
                                            : biometricType ==
                                                BiometricType.iris
                                            ? 'Reconocimiento de iris'
                                            : 'Huella dactilar',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
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

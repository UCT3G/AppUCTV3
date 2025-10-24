import 'package:app_uct/routes/app_navigator.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/onboarding/page_five.dart';
import 'package:app_uct/screens/onboarding/page_four.dart';
import 'package:app_uct/screens/onboarding/page_one.dart';
import 'package:app_uct/screens/onboarding/page_three.dart';
import 'package:app_uct/screens/onboarding/page_two.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  //
  final List<Widget> _pages = [
    PageOne(),
    PageTwo(),
    PageThree(),
    PageFour(),
    PageFive(),
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
      AppRoutes.login,
    );
  }

  void nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void skip() => finishOnboarding();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: skip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF574293),
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Omitir",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize:
                          isLandscape ? size.width * 0.025 : size.height * 0.02,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged:
                      (value) => setState(() => _currentIndex = value),
                  children: _pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentIndex == index ? 22 : 8,
                    decoration: BoxDecoration(
                      color:
                          _currentIndex == index
                              ? Color(0xFF574293)
                              : Color.fromRGBO(87, 66, 147, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: isLandscape ? size.width * 0.02 : size.height * 0.02,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF86CBC8), Color(0xFF574293)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          _currentIndex == _pages.length - 1
                              ? "Comenzar"
                              : "Continuar",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize:
                                isLandscape
                                    ? size.width * 0.02
                                    : size.height * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selfcheckoutapp/screens/onboarding/onboarding_screen.dart';
import 'package:selfcheckoutapp/services/shared_pref_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _setupSplashTimer();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset("assets/onboarding2.png"),
          ),
        ),
      ),
    );
  }

  /// Open signin screen if app is not first run and onboarding is already visited
  /// Otherwise open Change language and onboarding screen at first run
  Future<void> _setupSplashTimer() async {
    bool isOnBoardingVisited = await SharedPref.sharePref.isOnBoardingVisited();
    Timer(Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    });
    // Timer(
    //     const Duration(seconds: 3),
    //     () => isOnBoardingVisited
    //         ? Navigator.push(
    //             context, MaterialPageRoute(builder: (context) => LandingPage()))
    //         : Navigator.push(context,
    //             MaterialPageRoute(builder: (context) => OnboardingScreen())));
  }
}

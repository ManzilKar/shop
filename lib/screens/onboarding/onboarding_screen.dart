
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selfcheckoutapp/services/shared_pref_service.dart';
import 'package:selfcheckoutapp/widgets/custom_button.dart';

import '../landing_page.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  // static void presentScreen(BuildContext context) {
  //   Navigator.pushReplacementNamed(context, AppRoutes.introScreen);
  // }

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController? _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  int _currentPage = 0;

  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          color: _currentPage == index ? Colors.green : Colors.greenAccent),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      curve: Curves.easeIn,
      width: _currentPage == index ? 32 : 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;
    EdgeInsetsGeometry padding = EdgeInsets.only(
        top: SizeConfig.screenH! * 0.05,
        left: SizeConfig.screenW!* 0.07,
        right: SizeConfig.screenW! * 0.07,
        bottom: SizeConfig.screenH! * 0.05);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.screenH! * 0.85,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: SizeConfig.blockV! * 8,
                        ),
                        Image.asset(
                          contents[i].image,
                          height: SizeConfig.blockV! * 30,
                        ),
                        SizedBox(
                          height: SizeConfig.blockV! * 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            contents.length,
                            (int index) => _buildDots(
                              index: index,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: (height >= 840) ? 60 : 30,
                        ),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: (width <= 550) ? 30 : 35,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockH! * 4,
                        ),
                        Text(
                          contents[i].desc,
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: (width <= 550) ? 16 : 25,
                          ),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {
              //  SharedPref.shared.setOnBoardingVisited(true);
              SharedPref.sharePref.setOnBoardingVisited(true);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LandingPage()));
            },
            style: TextButton.styleFrom(
              elevation: 0,
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: (width <= 550) ? 13 : 17,
              ),
            ),
            child: Text(
              "Skip",
              style: TextStyle(color: Colors.green),
            ),
          ),
          SizedBox(
            width: 200,
            child: CustomBtn(
              text: "Next",

              // height: SizeConfig.blockH! * 10,
              outlineBtn: false,
              onPressed: () {
                if (_controller!.page == 1) {
                  SharedPref.sharePref.setOnBoardingVisited(true);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LandingPage()));
                }

                _controller?.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              }, isLoading: false,
            ),
          )
        ],
      ),
    );
  }
}

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenW;
  static double? screenH;
  static double? blockH;
  static double? blockV;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenW = _mediaQueryData!.size.width;
    screenH = _mediaQueryData!.size.height;
    blockH = screenW! / 100;
    blockV = screenH! / 100;
  }
}

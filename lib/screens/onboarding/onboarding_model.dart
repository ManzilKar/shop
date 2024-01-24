class OnBoardingModel {
  final String title;
  final String image;
  final String desc;

  OnBoardingModel({
   required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnBoardingModel> contents = [
  OnBoardingModel(
    title: "Easy Shopping \n"
        "Pay yourself",
    image: "assets/onboarding1.png",
    desc: "An idea to pay yourself to avoid long queue and hassle.",
  ),
  OnBoardingModel(
    title: "Online Grocery Shoping App",
    image: "assets/onboarding2.png",
    desc: "Project by: Manzil Karmacharya\n"
        "Sunway International Business School",
  ),
];

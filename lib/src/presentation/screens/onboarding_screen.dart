import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  void _onPageChanged(int page) {
    if (page == 3) {
      // Last page index
      SharedPreferencesService.instance.setData('intro', true).then((_) async {
        await Future.delayed(const Duration(milliseconds: 1));
        if (mounted) context.go('/connect');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: [
                OnboardingPage(
                  image: AppImages.instance.onboarding1,
                  title: 'Praticité',
                  description:
                      'Votre partenaire quotidien pour des solutions monétaires innovantes et pratiques.',
                ),
                OnboardingPage(
                  image: AppImages.instance.onboarding2,
                  title: 'Innovation',
                  description:
                      'Rechargez du credit et gérer tous vos finances en une appli.',
                ),
                OnboardingPage(
                  image: AppImages.instance.onboarding3,
                  title: 'Rentabilité',
                  description:
                      'Faites vos courses et profitez d’offres inédites sur notre marketplace.',
                ),
                SizedBox(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const ExpandingDotsEffect(dotHeight: 8, dotWidth: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

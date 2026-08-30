import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuth();
  }

  void _handleAuth() async {
    bool intro = await SharedPreferencesService.instance.getData('intro');
    User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(seconds: 1));
    if (!intro) {
      _navigateTo('/onboarding');
    } else if (user == null) {
      _navigateTo('/connect');
      return;
    } else {
      _navigateTo('/home-welit');
    }
  }

  void _navigateTo(String routeName) {
    if (mounted) {
      context.go(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradiantWidget(
        widget: Center(
          child: Image(
            width: 277,
            height: 130,
            image: AssetImage(AppImages.instance.logo),
          ),
        ),
      ),
    );
  }
}

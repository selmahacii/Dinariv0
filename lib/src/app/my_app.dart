import 'package:dinari/src/core/config/router/app_router.dart';
import 'package:dinari/src/core/config/theme/theme_config.dart';
import 'package:dinari/src/core/utils/constants/app_strings.dart';
import 'package:dinari/src/presentation/screens/auth/connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 917),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppStrings.instance.appName,
          theme: ThemeConfig.instance.lightTheme,
          themeMode: ThemeMode.light,
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(
            debugLabel: 'scaffoldMessengerKey',
          ),
          routerConfig: AppRouter.instance.route,
        );
      },
      child: const ConnectScreen(),
    );
  }
}

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/core/utils/constants/app_svg.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/presentation/screens/WELIT/home/pages/accueil_page.dart';
import 'package:dinari/src/presentation/screens/WELIT/home/pages/profile_page.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:go_router/go_router.dart';

class WelitHomeScreen extends StatefulWidget {
  const WelitHomeScreen({super.key});

  @override
  State<WelitHomeScreen> createState() => _WelitHomeScreenState();
}

class _WelitHomeScreenState extends State<WelitHomeScreen> {
  final user = SharedPreferencesService.instance.getUserData('user');
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: Image.asset(
          AppImages.instance.horizontalLogo,
          width: 0.4.sw,
          height: 50.h,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/notification');
            },
            icon: Icon(Icons.notifications, color: Colors.white, size: 35.r),
          ),
          8.horizontalSpace,
        ],
        leading: IconButton(
          onPressed: () {
            context.push('/profile');
          },
          icon: Container(
            padding: REdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.instance.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.instance.surfaceColor,
              size: 25.5.r,
            ),
            // child: Image(
            //   width: 37.5.r,
            //   height: 37.5.r,
            //   image: Svg(AppSvg.instance.monMarcheeSelected),
            // ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AccueilPage(user: user),
          Scaffold(body: GradiantWidget(widget: Container())),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,

        // animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        color: AppColors.instance.primaryColor,

        items: [
          CurvedNavigationBarItem(
            child: Image(
              width: _selectedIndex == 0 ? 37.5.r : 25.r,
              height: _selectedIndex == 0 ? 37.5.r : 25.r,
              image: Svg(
                _selectedIndex == 0
                    ? AppSvg.instance.accueilSelected
                    : AppSvg.instance.accueil,
              ),
            ),
            label: 'Accueil',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 0
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),

          CurvedNavigationBarItem(
            child: Image(
              width: _selectedIndex == 1 ? 37.5.r : 25.r,
              height: _selectedIndex == 1 ? 37.5.r : 25.r,
              image: Svg(
                _selectedIndex == 1
                    ? AppSvg.instance.monMarcheeSelected
                    : AppSvg.instance.monMarchee,
              ),
            ),

            label: 'Mon marché',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 1
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              color:
                  _selectedIndex == 2
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
              size: _selectedIndex == 2 ? 37.5.r : 25.r,
              Icons.person,
            ),
            label: 'Profile',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 2
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _selectedIndex = 0;
            context.push('/home-marketplace');
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}

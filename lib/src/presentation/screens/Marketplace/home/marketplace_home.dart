import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/core/utils/marketplace_image_seeder.dart';
import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/core/utils/constants/app_svg.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/custom_bottom_sheet.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/categories_page.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/chat_list_screen.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/marketplace_home_page.dart';
import 'package:dinari/src/presentation/screens/WELIT/home/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:go_router/go_router.dart';

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  final user = SharedPreferencesService.instance.getUserData('user');
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    MarketplaceImageSeeder.run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.instance.horizontalLogoBlack,
              width: 0.4.sw,
              height: 50.h,
            ),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: const Color(0xFF008080),
            //       foregroundColor: Colors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: const Text('Publier annonce'),
            //   ),
            // ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size(200.r, 40.r),

          child: InkWell(
            onTap: () => context.pop(),
            child: Container(
              width: 250.r,
              height: 40.r,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.instance.primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  'Retour au portefeuille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/notification');
            },
            icon: Icon(
              Icons.notifications,
              color: AppColors.instance.primaryColor,
              size: 35.r,
            ),
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
          MarketplaceHomePage(),
          CategoriesPage(),
          Scaffold(body: Container()),
          ChatListScreen(),
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
                    ? AppSvg.instance.categoriesSelected
                    : AppSvg.instance.categories,
              ),
            ),
            label: 'Catégories',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 1
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),
          CurvedNavigationBarItem(
            child: Image(
              width: _selectedIndex == 2 ? 37.5.r : 25.r,
              height: _selectedIndex == 2 ? 37.5.r : 25.r,
              image: Svg(
                _selectedIndex == 2
                    ? AppSvg.instance.venteSelected
                    : AppSvg.instance.vente,
              ),
            ),
            label: 'Vente',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 2
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),
          CurvedNavigationBarItem(
            child: Image(
              width: _selectedIndex == 3 ? 37.5.r : 25.r,
              height: _selectedIndex == 3 ? 37.5.r : 25.r,
              image: Svg(
                _selectedIndex == 3
                    ? AppSvg.instance.messageSelected
                    : AppSvg.instance.message,
              ),
            ),
            label: 'Message',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 3
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),

          CurvedNavigationBarItem(
            child: Icon(
              color:
                  _selectedIndex == 4
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
              size: _selectedIndex == 4 ? 37.5.r : 25.r,
              Icons.person,
            ),
            label: 'Profile',
            labelStyle: TextStyle(
              color:
                  _selectedIndex == 4
                      ? AppColors.instance.secondaryColor
                      : AppColors.instance.surfaceColor,
            ),
          ),
        ],
        onTap: (index) async {
          if (index == 2) {
            CustomBottomSheet.show(context);
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Usage example
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            CustomBottomSheet.show(context);
          },
          child: const Text('Show Bottom Sheet'),
        ),
      ),
    );
  }
}

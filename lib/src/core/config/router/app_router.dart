import 'package:dinari/src/presentation/screens/Marketplace/home/marketplace_home.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/store_package_selection_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/charge_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/flexi_pin_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/operation_detail_screen.dart';
import 'package:dinari/src/database/models/operation_model.dart';
import 'package:dinari/src/presentation/screens/WELIT/contacts_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/delivery_company_selection_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/money_transfes_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/operations_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/payment_options_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/vendor_space_screen.dart';
import 'package:dinari/src/presentation/screens/auth/connect_screen.dart';
import 'package:dinari/src/presentation/screens/auth/forgotten_password_screen.dart';
import 'package:dinari/src/presentation/screens/auth/link_sent_screen.dart';
import 'package:dinari/src/presentation/screens/auth/register_screen.dart';
import 'package:dinari/src/presentation/screens/WELIT/home/welit_home_screen.dart';
import 'package:dinari/src/presentation/screens/edit_profile_screen.dart';
import 'package:dinari/src/presentation/screens/my_ads_screen.dart';
import 'package:dinari/src/presentation/screens/notification_screen.dart';
import 'package:dinari/src/presentation/screens/onboarding_screen.dart';
import 'package:dinari/src/presentation/screens/profile_screen.dart';
import 'package:dinari/src/presentation/screens/scan_screen.dart';
import 'package:dinari/src/presentation/screens/spalsh_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();
  static final instance = AppRouter._();

  final GoRouter route = GoRouter(
    initialLocation: '/', // Start with the splash screen
    routes: [
      // Splash Screen
      GoRoute(path: '/', builder: (context, state) => SpalshScreen()),
      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      // Connect Screen
      GoRoute(
        path: '/connect',
        builder: (context, state) => ConnectScreen(),
        routes: [
          // Register Screen
          GoRoute(
            path: 'register',
            builder: (context, state) => RegisterScreen(),
          ),
          // Forgotten Password Screen
          GoRoute(
            path: 'forgotten-password',
            builder: (context, state) => ForgottenPasswordScreen(),
          ),
          // Link Sent Screen
          GoRoute(
            path: 'link-sent',
            builder: (context, state) => LinkSentScreen(),
          ),
        ],
      ),
      // Home Screen
      GoRoute(
        path: '/home-welit',
        builder: (context, state) => WelitHomeScreen(),
        routes: [
          //PaymentOptionsScreen
          GoRoute(
            path: '/payment-options-welit',
            builder: (context, state) => PaymentOptionsScreen(),
          ),
          //ChargeScreen
          GoRoute(
            path: '/charge-welit',
            builder: (context, state) => ChargeScreen(),
          ),
          //FlexiPinScreen
          GoRoute(
            path: '/flexi-welit',
            builder: (context, state) => const FlexiPinScreen(),
          ),
          GoRoute(
            path: '/contacts-welit',
            builder: (context, state) => ContactsScreen(),
          ),
          //MoneyTransferScreen
          GoRoute(
            path: '/money-transfer-welit',
            builder: (context, state) {
              final userId = state.extra as String;
              return MoneyTransferScreen(userId: userId);
            },
          ),
          //OperationsScreen
          GoRoute(
            path: '/operations-welit',
            builder: (context, state) => OperationsScreen(),
          ),
          //OperationDetailScreen
          GoRoute(
            path: '/operation-detail-welit',
            builder: (context, state) => OperationDetailScreen(
              operation: state.extra as OperationModel,
            ),
          ),
          //VendorSpaceScreen
          GoRoute(
            path: '/vendor-space-welit',
            builder: (context, state) => VendorSpaceScreen(),
            routes: [
              //DeliveryCompanySelectionScreen
              GoRoute(
                path: '/delivery-company-selection-welit',
                builder: (context, state) => DeliveryCompanySelectionScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/home-marketplace',
        builder: (context, state) => MarketplaceHome(),
        routes: [
          //StorePackageSelectionScreen
          GoRoute(
            path: '/store-package-selection-marketplace',
            builder: (context, state) => StorePackageSelectionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => NotificationsScreen(),
      ),
      //profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(),
        routes: [
          GoRoute(
            path: '/my-ads',
            builder: (context, state) => const MyAdsScreen(),
          ),
        ],
      ),
      //EditProfileScreen
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => EditProfileDialogWidget(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
    ],
    // Fallback for unknown routes
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Page not found'))),
  );
}

import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/presentation/widgets/card_verification_bottom_sheet.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:dinari/src/presentation/widgets/payment_card.dart';
import 'package:dinari/src/presentation/widgets/sold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final user = SharedPreferencesService.instance.getUserData('user');
  void _showCardVerificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const CardVerificationBottomSheet(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Recharger', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),
      body: GradiantWidget(
        widget: SafeArea(
          child: Column(
            children: [
              32.verticalSpace,
              Text(
                'Dinari : Solde disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFEBFFEE),
                  fontSize: 14.sp,
                  fontFamily: 'Kumbh Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.verticalSpace,
              SoldWidget(),
              8.verticalSpace,
              Text(
                'Bonjour, ${user.fullName.split(' ').first}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              32.verticalSpace,
              GestureDetector(
                onTap: () => context.push('/home-welit/flexi-welit'),
                child: PaymentCard(
                  label: 'Flexi',
                  hasPromoTag: false,
                  child: Image.asset(
                    AppImages.instance.logo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // CIB/Edahabia Card
              PaymentCard(
                label: 'cib/edahabia',
                hasPromoTag: true,
                child: Image.asset(
                  AppImages.instance.card,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),

              // Carte de recharge Card
              GestureDetector(
                onTap: _showCardVerificationSheet,
                child: PaymentCard(
                  label: 'Carte de recharge',
                  hasPromoTag: false,
                  child: Image.asset(
                    AppImages.instance.rechareg,
                    fit: BoxFit.contain,
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

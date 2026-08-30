import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/database/models/user_model.dart';
import 'package:dinari/src/presentation/screens/edit_profile_screen.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:dinari/src/presentation/widgets/language_bottom_sheet.dart';
import 'package:dinari/src/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:dinari/src/presentation/widgets/user_q_r_code_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel user = SharedPreferencesService.instance.getUserData('user');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradiantWidget(
        widget: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: REdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      height: 70.r,
                      width: 70.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.sp),
                        color: Colors.white,
                      ),
                      child: Icon(Icons.person, color: Colors.grey, size: 70.r),
                    ),
                    8.verticalSpace,

                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                    Text(
                      user.phoneNumber,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
                //   ],
                // ),
              ),
              16.verticalSpace,
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.r),
                      topRight: Radius.circular(15.r),
                    ),
                  ),
                  child: ListView(
                    // padding: REdgeInsets.only(top: 8),
                    children: [
                      _profilItem('Mon compte', () {
                        showDialog(
                          context: context,
                          builder: (c) {
                            return EditProfileDialogWidget();
                          },
                        ).then(
                          (value) => setState(() {
                            user = SharedPreferencesService.instance
                                .getUserData('user');
                          }),
                        );
                      }),
                      _profilItem('statistiques', () {}),
                      _profilItem('Ma publicité', () {
                        context.push('/profile/my-ads');
                      }),
                      _profilItem('Sécurité', () {}),
                      _profilItem('Mon code QR', () {
                        _showUserQRCodeSheet(context);
                      }),
                      _profilItem('Mes transferts', () {}),
                      _profilItem('Language', () {
                        _showLanguageSelectionSheet(context);
                      }),
                      _profilItem('politique de confidentialité', () {}),
                      _profilItem('Termes et conditions', () {}),
                      _profilItem('déconnecter', () {
                        _showLogoutDialog(context);
                      }),
                      16.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _profilItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey,
        size: 20.r,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop();
          },
          onLogout: () async {
            await FirebaseAuth.instance.signOut();
            context.go('/');
          },
        );
      },
    );
  }

  void _showLanguageSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => LanguageBottomSheet(
            onLanguageSelected: (language) {
              // Handle language selection here
              print('Selected language: $language');
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showUserQRCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => UserQRCodeBottomSheet(
            userId: user.id, // Assuming your UserModel has an id field
            userName: user.fullName,
          ),
      isScrollControlled: true,
    );
  }
}

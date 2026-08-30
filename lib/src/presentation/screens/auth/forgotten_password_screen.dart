import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgottenPasswordScreen extends StatefulWidget {
  const ForgottenPasswordScreen({super.key});

  @override
  State<ForgottenPasswordScreen> createState() =>
      _ForgottenPasswordScreenState();
}

class _ForgottenPasswordScreenState extends State<ForgottenPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  FocusNode emailFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    emailFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String errorMessage;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (mounted) {
        context.go('/connect/link-sent');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'invalid_credential';
          break;
        case 'not-found':
          errorMessage = 'user_data_not_found';
          break;
        case 'invalid-email':
          errorMessage = 'invalid_email';
          break;
        case 'user-disabled':
          errorMessage = 'user_disabled';
          break;
        case 'user-not-found':
          errorMessage = 'user_not_found';
          break;
        case 'wrong-password':
          errorMessage = 'wrong_password';
          break;
        case 'too-many-requests':
          errorMessage = 'too_many_requests';
          break;
        case 'operation-not-allowed':
          errorMessage = 'operation_not_allowed';
          break;
        case 'network-request-failed':
          errorMessage = 'network_request_failed';
          break;
        default:
          errorMessage = 'unexpected_error';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // Handle any other errors
      errorMessage = 'unexpected_error';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: AppColors.instance.surfaceColor,
          size: 30.r,
        ),
      ),
      body: GradiantWidget(
        widget: SizedBox(
          width: 327.w,
          height: 516.h,
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    width: 145.w,
                    height: 28.h,
                    image: AssetImage(AppImages.instance.horizontalWhiteLogo),
                    fit: BoxFit.contain,
                  ),
                  8.verticalSpace,
                  Text(
                    'Mot de passe oublié ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // 8.verticalSpace,
                  Text(
                    'Entrez votre email ci-dessous',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  16.verticalSpace,
                  Card(
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: REdgeInsets.all(6.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: REdgeInsets.symmetric(horizontal: 8),
                            child: TextFormField(
                              controller: emailController,
                              focusNode: emailFocusNode,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.email_outlined,
                                  color: const Color(0xFF0052B4),
                                  size: 24.r,
                                ),
                                hintText: 'habib@gmail.com',
                                hintMaxLines: 1,
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please_enter_email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'enter_valid_email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_isLoading) return;
                          setState(() {
                            _isLoading = !_isLoading;
                          });
                          _sendLink();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFD700,
                        ), // Yellow color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                'Envoyer le lien',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

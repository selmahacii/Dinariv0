import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/database/models/user_model.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:dinari/src/presentation/widgets/login_card.dart';
import 'package:dinari/src/presentation/widgets/login_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginWithFirebase() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String errorMessage;
    try {
      // Log in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get the logged-in user's UID
      String uid = userCredential.user?.uid ?? '';

      if (uid.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'user_not_found',
        );
      }

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'not-found',
          message: 'user_data_not_found',
        );
      }

      // Convert the Firestore document into a UserModel
      final userModel = UserModel.fromFirestore(userDoc);
      await SharedPreferencesService.instance.setUserData('user', userModel);

      if (mounted) {
        context.go('/home-welit');
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
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      switch (e.code) {
        case 'not-found':
          errorMessage = 'user_not_found';
          break;
        case 'permission-denied':
          errorMessage = 'permission_denied';
          break;
        case 'resource-exhausted':
          errorMessage = 'resource_exhausted';
          break;
        case 'unavailable':
          errorMessage = 'service_unavailable';
          break;
        case 'network-failed':
          errorMessage = 'network_failed';
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
      resizeToAvoidBottomInset: true,
      body: GradiantWidget(
        widget: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 1.sh -
                    MediaQuery.of(context).padding.vertical -
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              width: 327.w,
              alignment: Alignment.center,
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
                    'Connectez-vous à\nvotre compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // 8.verticalSpace,
                  TextButton(
                    onPressed: () => context.go('/connect/register'),
                    child: Text(
                      'Vous n’avez pas de compte ? S\'inscrire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  AuthCard(
                    emailController: emailController,
                    passwordController: passwordController,
                    emailFocusNode: emailFocusNode,
                    passwordFocusNode: passwordFocusNode,
                    isRegister: false,
                  ),
                  // 16.verticalSpace,
                  TextButton(
                    onPressed: () => context.go('/connect/forgotten-password'),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        decoration:
                            TextDecoration.underline, // This adds the underline
                        decorationThickness:
                            2.0, // This sets the thickness of the underline
                        decorationColor:
                            Colors
                                .white, // This sets the color of the underline
                      ),
                    ),
                  ),
                  AuthOptions(
                    text: 'Se connecter',
                    isLoading: _isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = !_isLoading;
                        });
                        _loginWithFirebase();
                      }
                    },
                  ),

                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

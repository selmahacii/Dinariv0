import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    phoneController.dispose();
    phoneFocusNode.dispose();
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmailAndPassword() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    nameFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String errorMessage;
    try {
      // Create a new user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get the newly created user's UID
      String uid = userCredential.user?.uid ?? '';

      if (uid.isEmpty) {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'unknown_error',
        );
      }

      Map<String, dynamic> data = {
        'id': uid,
        'fullName': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'sold': 0.0,
        'contacts' : [],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).set(data);

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'not-found',
          message: 'user_data_not_found',
        );
      }

      UserModel userModel = UserModel.fromFirestore(userDoc);
      await SharedPreferencesService.instance.setUserData('user', userModel);

      if (mounted) {
        context.go('/home-welit');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'email_already_in_use';
          break;
        case 'invalid-email':
          errorMessage = 'invalid_email';
          break;
        case 'weak-password':
          errorMessage = 'weak_password';
          break;
        case 'operation-not-allowed':
          errorMessage = 'account_creation_disabled';
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
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // 8.verticalSpace,
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Vous n’avez pas de compte ? Se connecter',
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
                    nameController: nameController,
                    phoneController: phoneController,
                    nameFocusNode: nameFocusNode,
                    phoneFocusNode: phoneFocusNode,
                    isRegister: true,
                  ),
                  AuthOptions(
                    text: 'S\'inscrire',
                    isLoading: _isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_isLoading) return;
                        setState(() {
                          _isLoading = !_isLoading;
                        });
                        _signUpWithEmailAndPassword();
                      }
                    },
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

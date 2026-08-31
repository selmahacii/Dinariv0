import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:dinari/src/presentation/widgets/sold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlexiPinScreen extends StatefulWidget {
  const FlexiPinScreen({super.key});

  @override
  State<FlexiPinScreen> createState() => _FlexiPinScreenState();
}

class _FlexiPinScreenState extends State<FlexiPinScreen> {
  final user = SharedPreferencesService.instance.getUserData('user');
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    _pinFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code saisi : ${_pinController.text.trim()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Flexi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradiantWidget(
        widget: SafeArea(
          child: SingleChildScrollView(
            padding: REdgeInsets.only(bottom: 24),
            child: Column(
              children: [
              32.verticalSpace,
              Text(
                'Dinari : Solde disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFEBFFEE),
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
              Container(
                margin: REdgeInsets.symmetric(horizontal: 16),
                padding: REdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code',
                        style: TextStyle(
                          color: const Color(0xFF01796F),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      12.verticalSpace,
                      TextFormField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 16,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Saisir le code',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir le code';
                          }
                          if (value.trim().length < 4) {
                            return 'Le code doit contenir au moins 4 chiffres';
                          }
                          return null;
                        },
                      ),
                      20.verticalSpace,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A9D8F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

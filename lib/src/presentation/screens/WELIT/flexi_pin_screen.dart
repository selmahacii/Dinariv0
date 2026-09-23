import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isProcessing = false;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _pinFocusNode.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_isProcessing) return;

    final enteredCode = _pinController.text.trim();

    setState(() {
      _isProcessing = true;
    });

    try {
      final codeSnapshot = await FirebaseFirestore.instance
          .collection('recharge_codes')
          .doc(enteredCode)
          .get();

      if (!codeSnapshot.exists) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code invalide')),
          );
        }
        return;
      }

      final codeSnapshotData = codeSnapshot.data() as Map<String, dynamic>;

      if (codeSnapshotData['isUsed'] == true) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ce code a déjà été utilisé')),
          );
        }
        return;
      }

      if (codeSnapshotData['expiresAt'] != null) {
        DateTime expiryDate =
            (codeSnapshotData['expiresAt'] as Timestamp).toDate();
        if (expiryDate.isBefore(DateTime.now())) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ce code a expiré')),
            );
          }
          return;
        }
      }

      double amount = double.parse(codeSnapshotData['amount'].toString());
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      if (currentUid != null) {
        await FirebaseFirestore.instance
            .collection('recharge_codes')
            .doc(codeSnapshot.id)
            .update({
              'isUsed': true,
              'userID': currentUid,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .update({
              'sold': FieldValue.increment(amount),
            });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('operations')
            .add({
              'amount': amount,
              'type': 'Recharge',
              'counterparty': 'Flexi Dinari',
              'reference': 'FLX-${DateTime.now().millisecondsSinceEpoch}',
              'timestamp': FieldValue.serverTimestamp(),
            });
      }

      _pinController.clear();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Votre compte a été rechargé de ${amount.toStringAsFixed(2)} DZD',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
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
                'Bonjour, ${(user.fullName.trim().isNotEmpty) ? user.fullName.trim().split(' ').first : ''}',
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
                          onPressed: _isProcessing ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A9D8F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Confirmer'),
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

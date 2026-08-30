import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet for card verification
class CardVerificationBottomSheet extends StatefulWidget {
  const CardVerificationBottomSheet({super.key});

  @override
  State<CardVerificationBottomSheet> createState() =>
      _CardVerificationBottomSheetState();
}

class _CardVerificationBottomSheetState
    extends State<CardVerificationBottomSheet> {
  bool _acceptedConditions = false;
  bool _isProcessing = false;
  final _cardCodeController = TextEditingController();

  @override
  void dispose() {
    _cardCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _cardCodeController,
            decoration: InputDecoration(
              hintText: 'Saisir le code de la carte',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _acceptedConditions,
                  onChanged: (value) {
                    setState(() {
                      _acceptedConditions = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Il a accepté les conditions',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _acceptedConditions
                          ? () async {
                            setState(() {
                              _isProcessing = true;
                            });
                            final enteredCode = _cardCodeController.text.trim();

                            if (enteredCode.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez saisir un code'),
                                ),
                              );
                              return;
                            }

                            try {
                              // Query Firestore to find the code
                              final codeSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('recharge_codes')
                                      .doc(enteredCode)
                                      .get();

                              if (!codeSnapshot.exists) {
                                setState(() {
                                  _isProcessing = false;
                                });
                                print('=> Code invalide');
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Code invalide'),
                                  ),
                                );
                                return;
                              }

                              final codeSnapshotData =
                                  codeSnapshot.data() as Map<String, dynamic>;

                              // Check if code is already used
                              if (codeSnapshotData['isUsed'] == true) {
                                setState(() {
                                  _isProcessing = false;
                                });
                                Navigator.of(context).pop();
                                print('=> Ce code a déjà été utilisé');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ce code a déjà été utilisé'),
                                  ),
                                );
                                return;
                              }

                              // Check if code is expired
                              DateTime expiryDate =
                                  (codeSnapshotData['expiresAt'] as Timestamp)
                                      .toDate();
                              if (expiryDate.isBefore(DateTime.now())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ce code a expiré'),
                                  ),
                                );
                                return;
                              }

                              double amount = double.parse(
                                codeSnapshotData['amount'].toString(),
                              );

                              // Update the code as used and set userID
                              await FirebaseFirestore.instance
                                  .collection('recharge_codes')
                                  .doc(codeSnapshot.id)
                                  .update({
                                    'isUsed': true,
                                    'userID':
                                        FirebaseAuth.instance.currentUser?.uid,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                    'sold': FieldValue.increment(amount),
                                  });

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('operations')
                                  .add({
                                    'amount': amount,
                                    'type': 'Recharge',
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });
                              // Close bottom sheet and return the amount to the caller

                              setState(() {
                                _isProcessing = false;
                              });
                              Navigator.of(context).pop();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Votre compte a été rechargé de ${amount.toStringAsFixed(2)} unités',
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Close loading dialog if still showing
                              setState(() {
                                _isProcessing = false;
                              });

                              // Show error message
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A9D8F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirmer'),
                ),
              ),
            ],
          ),
          // Add padding at the bottom to account for safe area
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
        ],
      ),
    );
  }
}

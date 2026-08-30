import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoneyTransferScreen extends StatefulWidget {
  const MoneyTransferScreen({super.key, required this.userId});
  final String userId;

  @override
  State<MoneyTransferScreen> createState() => _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Combien voulez-vous envoyer ?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FutureBuilder(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .get(),
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Body(snapshot: snapshot.data!, userId: widget.userId);
          },
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key, required this.snapshot, required this.userId});
  final DocumentSnapshot snapshot;
  final String userId;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  bool _isLoading = false;

  Future<void> _transfer(String amount, String userIdToSend) async {
    String? errorMessage;
    setState(() {
      _amountFocusNode.unfocus();
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the sender's document
        DocumentReference senderRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        DocumentSnapshot senderSnapshot = await transaction.get(senderRef);

        // Get the recipient's document
        DocumentReference recipientRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userIdToSend);
        DocumentSnapshot recipientSnapshot = await transaction.get(
          recipientRef,
        );

        if (!senderSnapshot.exists) {
          throw Exception("Sender does not exist");
        }

        Map<String, dynamic> senderData =
            senderSnapshot.data() as Map<String, dynamic>;
        if (!senderData.containsKey('sold')) {
          throw Exception("Sender's balance not found");
        }
        double senderBalance = double.parse(senderData['sold'].toString());
        double transferAmount = double.parse(amount);

        if (senderBalance == 0) {
          throw Exception('Solde insuffisant');
        }

        if (senderBalance >= transferAmount) {
          // Update sender's balance
          transaction.update(senderRef, {
            'sold': senderBalance - transferAmount,
          });

          if (!recipientSnapshot.exists) {
            throw Exception("Recipient does not exist");
          }

          Map<String, dynamic> recipientData =
              recipientSnapshot.data() as Map<String, dynamic>;
          if (!recipientData.containsKey('sold')) {
            throw Exception("Recipient's balance not found");
          }
          double recipientBalance = double.parse(
            recipientData['sold'].toString(),
          );

          // Update recipient's balance
          transaction.update(recipientRef, {
            'sold': recipientBalance + transferAmount,
          });
          transaction.set(senderRef.collection('operations').doc(), {
            'type': 'Envoi',
            'amount': transferAmount * -1,
            'timestamp': Timestamp.now(),
          });
          transaction.set(recipientRef.collection('operations').doc(), {
            'type': 'Reception',
            'amount': transferAmount,
            'timestamp': Timestamp.now(),
          });
          transaction.set(senderRef.collection('contacts').doc(userIdToSend), {
            'userId': userIdToSend,
            'name': recipientData['fullName'],
            'email': recipientData['email'],
            'phone': recipientData['phoneNumber'],
            'updatedAt': Timestamp.now(),
          });
        } else {
          throw Exception("Insufficient funds");
        }
      });
    } catch (e) {
      print("=> Transfer failed: $e");
      errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
        if (errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        } else {
          context.pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Transfer successful')));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              // Profile picture
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // Recipient name
              Text(
                widget.snapshot['fullName'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              // Email
              Text(
                widget.snapshot['email'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Amount input field
        TextField(
          controller: _amountController,
          focusNode: _amountFocusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const Spacer(),
        // Send button
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  () =>
                      _amountController.text.isNotEmpty
                          ? _isLoading
                              ? null
                              : _transfer(_amountController.text, widget.userId)
                          : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _amountController.text.isNotEmpty
                        ? const Color(0xFF10877F)
                        : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Envoyer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

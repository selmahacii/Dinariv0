// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Taux de TVA appliqué (Algérie : 19%).
const double kVatRate = 0.19;

class OperationModel extends Equatable {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String counterparty;
  final String reference;

  const OperationModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.counterparty,
    required this.reference,
  });

  /// Montant TTC (toujours positif).
  double get ttc => amount.abs();

  /// Montant hors taxe.
  double get ht => ttc / (1 + kVatRate);

  /// Montant de la TVA.
  double get tva => ttc - ht;

  /// true si l'opération crédite le compte.
  bool get isCredit => amount > 0;

  factory OperationModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['timestamp'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return OperationModel(
      id: id,
      type: (map['type'] ?? 'Opération').toString(),
      amount: double.tryParse('${map['amount']}') ?? 0.0,
      date: parsedDate,
      counterparty: (map['counterparty'] ?? '—').toString(),
      reference:
          (map['reference'] ?? id.substring(0, id.length >= 8 ? 8 : id.length))
              .toString()
              .toUpperCase(),
    );
  }

  factory OperationModel.fromFirestore(DocumentSnapshot doc) {
    return OperationModel.fromMap(
      doc.id,
      (doc.data() as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  List<Object?> get props => [id, type, amount, date, counterparty, reference];
}

import 'package:dinari/src/database/models/operation_model.dart';
import 'package:dinari/src/presentation/widgets/gradiant_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class OperationDetailScreen extends StatelessWidget {
  const OperationDetailScreen({super.key, required this.operation});

  final OperationModel operation;

  IconData get _icon {
    switch (operation.type) {
      case 'Transfert':
        return Icons.swap_horiz;
      case 'Recharge':
        return Icons.account_balance_wallet;
      case 'Envoi':
        return Icons.arrow_downward;
      case 'Reception':
        return Icons.arrow_upward;
      case 'Paiement':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  String _money(double value) {
    final formatted = NumberFormat('#,##0.00').format(value);
    return '$formatted DZD';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(operation.date);
    final timeStr = DateFormat('HH:mm').format(operation.date);
    final sign = operation.isCredit ? '+' : '-';
    final amountColor = operation.isCredit ? Colors.green : Colors.red;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Détail de l\'opération',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradiantWidget(
        widget: SafeArea(
          child: SingleChildScrollView(
            padding: REdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    color: const Color(0xFF007373),
                    size: 38.r,
                  ),
                ),
                12.verticalSpace,
                Text(
                  operation.type,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.verticalSpace,
                Text(
                  '$sign ${_money(operation.ttc)}',
                  style: TextStyle(
                    color: amountColor == Colors.green
                        ? const Color(0xFFB9F6CA)
                        : const Color(0xFFFFCDD2),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                24.verticalSpace,
                Container(
                  padding: REdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row('Type d\'opération', operation.type),
                      _divider(),
                      _row('Date', dateStr),
                      _divider(),
                      _row('Heure', timeStr),
                      _divider(),
                      _row(
                        operation.isCredit ? 'Reçu de' : 'Envoyé à',
                        operation.counterparty,
                      ),
                      _divider(),
                      _row('Référence', operation.reference),
                      _divider(),
                      _row('Montant exact', '$sign ${_money(operation.ttc)}'),
                      _divider(),
                      _row('Montant HT', _money(operation.ht)),
                      _divider(),
                      _row(
                        'TVA (${(kVatRate * 100).toStringAsFixed(0)} %)',
                        _money(operation.tva),
                      ),
                      _divider(),
                      _row(
                        'Total TTC',
                        _money(operation.ttc),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: emphasize ? 16.sp : 14.sp,
                color: emphasize ? const Color(0xFF01796F) : Colors.black87,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[200]);
}

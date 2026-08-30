import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final DateTime date;
  final double amount;
  final String currency;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.currency,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday · ${DateFormat('HH:mm').format(date)}';
    } else {
      return '${DateFormat('MMM dd, yyyy').format(date)} · ${DateFormat('HH:mm').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 35.r,
            height: 35.r,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              // borderRadius: BorderRadius.circular(12.r),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24.r),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(fontSize: 14.r, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          16.verticalSpace,
          Text(
            '${amount > 0 ? '+' : '-'}$currency ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: amount > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

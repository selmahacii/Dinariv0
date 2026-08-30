import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<Map<String, dynamic>> paymentOptions = [
  {'title': 'Flexi', 'icon': Icons.credit_card, 'color': Color(0xFF00897B)},
  {'title': 'Sonelgaz', 'icon': Icons.bolt, 'color': Color(0xFF00897B)},
  {
    'title': 'Ticket en ligne',
    'icon': Icons.confirmation_number,
    'color': Color(0xFF00897B),
  },
  {'title': 'Education', 'icon': Icons.school, 'color': Color(0xFF00897B)},
  {'title': 'ADE', 'icon': Icons.favorite, 'color': Color(0xFF00897B)},
  {'title': 'SEAAL', 'icon': Icons.water_drop, 'color': Color(0xFF00897B)},
  {'title': 'Télécom', 'icon': Icons.wifi, 'color': Color(0xFF00897B)},
  {
    'title': 'Bon De Jeu',
    'icon': Icons.sports_esports,
    'color': Color(0xFF00897B),
  },
];

class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste de paiement', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: Padding(
        padding: REdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.r,
            mainAxisSpacing: 32.r,
          ),
          itemCount: paymentOptions.length,
          itemBuilder: (context, index) {
            return PaymentOptionItem(
              title: paymentOptions[index]['title'],
              icon: paymentOptions[index]['icon'],
              iconColor: paymentOptions[index]['color'],
            );
          },
        ),
      ),
    );
  }
}

class PaymentOptionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const PaymentOptionItem({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 24)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'SOON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

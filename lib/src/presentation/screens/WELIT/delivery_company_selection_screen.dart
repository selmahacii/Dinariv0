import 'package:flutter/material.dart';

class DeliveryCompanySelectionScreen extends StatefulWidget {
  const DeliveryCompanySelectionScreen({super.key});

  @override
  State<DeliveryCompanySelectionScreen> createState() =>
      _DeliveryCompanySelectionScreenState();
}

class _DeliveryCompanySelectionScreenState
    extends State<DeliveryCompanySelectionScreen> {
  int? selectedCompanyIndex;

  final List<Map<String, dynamic>> deliveryCompanies = [
    {
      'name': 'ZR EXPRESS',
      'logo': 'assets/zr_express_logo.png',
      'color': Color(0xFFFFFFFF),
      'borderColor': Color(0xFFEEEEEE),
    },
    {
      'name': 'YALIDINE EXPRESS',
      'logo': 'assets/yalidine_express_logo.png',
      'color': Color(0xFFE32726),
      'borderColor': Color(0xFFE32726),
    },
    {
      'name': 'NOEST EXPRESS',
      'logo': 'assets/noest_express_logo.png',
      'color': Color(0xFFFFFFFF),
      'borderColor': Color(0xFFEEEEEE),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Achat', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez La Société De Livraison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Choisissez Votre Entreprise De Livraison Préférée',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: deliveryCompanies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCompanyIndex = index;
                        });
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: deliveryCompanies[index]['color'],
                          border: Border.all(
                            color:
                                selectedCompanyIndex == index
                                    ? Color(0xFF008080)
                                    : deliveryCompanies[index]['borderColor'],
                            width: selectedCompanyIndex == index ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: buildCompanyLogo(index)),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    selectedCompanyIndex != null
                        ? () {
                          // Handle validation
                        }
                        : null,
                child: Text(
                  'Valider',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF008080),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Color(0xFF008080).withOpacity(0.6),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCompanyLogo(int index) {
    // Since we can't use actual image assets in this example, we'll create custom widgets
    // for each logo based on the screenshot

    if (index == 0) {
      // ZR EXPRESS - Yellow and black logo
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ZR',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'EXPRESS',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (index == 1) {
      // YALIDINE EXPRESS - White logo on red background
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'YALIDINE EXPRESS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      // NOEST EXPRESS - Blue and red logo
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NOEST',
            style: TextStyle(
              color: Color(0xFF003B73),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COURRIER ET COLIS',
                style: TextStyle(
                  color: Color(0xFFE32726),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'EXPRESS',
                style: TextStyle(
                  color: Color(0xFFE32726),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}

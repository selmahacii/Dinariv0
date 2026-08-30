import 'package:flutter/material.dart';

class StorePackageSelectionScreen extends StatefulWidget {
  const StorePackageSelectionScreen({super.key});

  @override
  State<StorePackageSelectionScreen> createState() =>
      _StorePackageSelectionScreenState();
}

class _StorePackageSelectionScreenState
    extends State<StorePackageSelectionScreen> {
  // Packages data
  final Map<String, String> featureDescriptions = {
    'Outils de communication':
        'Cela apporte au vendeur de la publicité en lui permettant d\'ajouter ses informations, telles que son numéro de téléphone, ses réseaux sociaux et sa localisation. Ces informations seront visibles par les clients, et il aura également accès à l\'espace chat Dinari.',
    'Outils de gestion':
        'Cela facilite la traçabilité, le suivi précis et l\'organisation de la boutique pour le vendeur, notamment en ce qui concerne les informations sur les consommateurs, le nombre de vues et les statistiques de la boutique.',
    'Compte de livraison':
        'Cela permet au vendeur de gagner du temps et d\'efforts, car il bénéficiera d\'un compte chez une société de livraison partenaire de Dinari, avec un tarif exceptionnel et un remplissage automatique des informations de suivi et de tracking.',
    'Store à la une':
        'Les boutiques qui bénéficient de cette option ont accès aux catégories "Top vendeur" et "Top produit", ce qui leur confère une visibilité très élevée et, par conséquent, un volume de ventes plus important.',
    'Publicité':
        'Les boutiques VIP ont accès à cette option et peuvent s\'afficher sur la page d\'accueil de Dinari.',
  };
  final List<Map<String, dynamic>> packages = [
    {
      'name': 'Pack batolis',
      'price': '00 DA',
      'features': ['Nombre d\'annonces 10', 'Outils de gestion'],
    },
    {
      'name': 'Pack Bronze',
      'price': '1500 DA',
      'features': [
        'Nombre d\'annonces 50',
        'Outils de gestion',
        'Outils de communication',
        'Compte de livraison',
      ],
    },
    {
      'name': 'Store Silver',
      'price': '5 000 DA',
      'features': [
        'Annonces illimitées',
        'Outils de gestion',
        'Outils de communication',
        'Compte de livraison',
        'Store à la une',
      ],
    },
    {
      'name': 'Pack Gold',
      'price': '15 000 DA',
      'features': [
        'Annonces illimitées',
        'Outils de gestion',
        'Outils de communication',
        'Compte de livraison',
        'Store à la une',
        'Publicité off',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Acheter un store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choix De L\'Offre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return _buildPackageCard(package);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package['name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              package['price'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement purchase logic
                _showPurchaseConfirmation(package);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Achat',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...package['features']
                .map<Widget>((feature) => _buildFeatureRow(feature))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
          if (featureDescriptions.containsKey(feature))
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.grey,
                size: 20,
              ),
              onPressed:
                  () => FeatureDescriptionDialog.show(
                    context,
                    title: feature,
                    description: featureDescriptions[feature]!,
                  ),
            ),
          // else
          //   const Icon(Icons.info_outline, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void _showPurchaseConfirmation(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer l\'achat de ${package['name']}'),
            content: Text(
              'Voulez-vous acheter le ${package['name']} pour ${package['price']} ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement actual purchase logic
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Achat de ${package['name']} confirmé'),
                    ),
                  );
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );
  }
}

class FeatureDescriptionDialog extends StatelessWidget {
  final String title;
  final String description;

  const FeatureDescriptionDialog({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              // textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show the dialog
  static void show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showDialog(
      context: context,
      builder:
          (context) =>
              FeatureDescriptionDialog(title: title, description: description),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorSpaceScreen extends StatefulWidget {
  const VendorSpaceScreen({super.key});

  @override
  State<VendorSpaceScreen> createState() => _VendorSpaceScreenState();
}

class _VendorSpaceScreenState extends State<VendorSpaceScreen> {
  final _vendorNameController = TextEditingController();
  final _vendorEmailController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productNameController = TextEditingController();

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorEmailController.dispose();
    _productPriceController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text('Achat', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.transparent,

        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Espace vendeur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007B76),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Nom du vendeur', _vendorNameController),
              const SizedBox(height: 16),
              _buildTextField('E-mail du vendeur', _vendorEmailController),
              const SizedBox(height: 16),
              _buildTextField('Prix du produit', _productPriceController),
              const SizedBox(height: 16),
              _buildTextField('produit', _productNameController),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(
                      '/home-welit/vendor-space-welit/delivery-company-selection-welit',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007B76),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Suivant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

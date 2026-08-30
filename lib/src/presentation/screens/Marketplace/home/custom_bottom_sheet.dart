import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/multi_stage_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Illustration
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  AppImages
                      .instance
                      .buttonDialog, // Replace with your illustration
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Commence à vendre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Choisis comment tu veux commencer',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for "Publier annonce"
                        Navigator.pop(context);
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => StepOne()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Publier annonce'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for "Ouvrir magasin"
                        Navigator.pop(context);
                        // Add your navigation or action logic here
                        context.push(
                          '/home-marketplace/store-package-selection-marketplace',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF008080),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xFF008080),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text('Ouvrir magasin'),
                    ),
                  ),
                ],
              ),

              // Bottom padding
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

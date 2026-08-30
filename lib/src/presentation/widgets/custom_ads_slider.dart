// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class CustomAdsSlider extends StatelessWidget {
  final String text;
  final String descrip;
  final String imgPath;
  const CustomAdsSlider({
    super.key,
    required this.text,
    required this.descrip,
    required this.imgPath,
  });

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  descrip,
                  style: TextStyle(fontSize: 16, color: Color(0xFF797979)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: w * 0.05),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            alignment: Alignment.centerLeft,
            height: h * 0.25,
            width: w * 0.5,
            padding: EdgeInsets.only(left: w * 0.02, top: h * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            child: Image.asset(imgPath),
          ),
        ),
      ],
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dinari/src/core/utils/constants/app_colors.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/ads_item.dart';
import 'package:dinari/src/presentation/screens/Marketplace/home/pages/marketplace_home_page.dart';
import 'package:flutter/material.dart';

class ScrollbarCardWidget extends StatefulWidget {
  const ScrollbarCardWidget({super.key, required this.adsItems});
  final List<AdsItem> adsItems;

  @override
  State<ScrollbarCardWidget> createState() => _ScrollbarCardWidgetState();
}

class _ScrollbarCardWidgetState extends State<ScrollbarCardWidget> {
  int current = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      height: 220,
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: widget.adsItems.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: screenWidth,
                height: 180,
                // margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black,
                  image: DecorationImage(
                    image: NetworkImage(widget.adsItems[index].imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 180,
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  current = index;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [
                  ...List.generate(widget.adsItems.length, (index) => index),
                ].asMap().entries.map((entry) {
                  return Container(
                    width: current == entry.key ? 24.0 : 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      color:
                          (current == entry.key
                              ? AppColors.instance.primaryColor
                              : Colors.grey),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

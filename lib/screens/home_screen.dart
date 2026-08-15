import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_openui/utils/sizing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeTextAnimation;
  Timer? _fadeTimer;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeTextAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        controller.forward();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      'showcase/animated_fruits.png',
      'showcase/animate_cover.png',
      'showcase/car.png',
      'showcase/circle_carousel.png',
      'showcase/docking_bar_01.png',
      'showcase/doctor_appointment.png',
      'showcase/doughnuts_animate.png',
      'showcase/fade_carousel.png',
      'showcase/fashion_shop.png',
      'showcase/fruity_lips.png',
      'showcase/language_app.png',
      'showcase/nft_card_gallery.png',
      'showcase/nike_shop.png',
    ];
    return Scaffold(
      body: Transform.rotate(
        angle: 0.5 * pi,
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, val) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(1.0),
                child: Opacity(
                  opacity: fadeTextAnimation.value,
                  child: ListWheelScrollView(
                    controller: ScrollController(initialScrollOffset: 200),
                    perspective: 0.009,
                    itemExtent: AppSizing.height(context) * 0.15,
                    children: items.map(
                      (imagePath) {
                        return GestureDetector(
                          onTap: () async {},
                          child: Transform.rotate(
                            angle: -0.5 * pi,
                            child: Hero(
                              tag: imagePath,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: AppSizing.width(context) * 0.3,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

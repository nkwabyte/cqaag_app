import 'package:flutter/cupertino.dart';

class BoardingData {
  final String title;
  final String description;
  final IconData? icon;
  final String? svgAsset;

  BoardingData({
    required this.title,
    required this.description,
    this.icon,
    this.svgAsset,
  });
}

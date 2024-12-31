import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  const FeatureBox({
    super.key,
    required this.title,
    required this.description,
    required this.color,
  });

  final Color color;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cera Pro',
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Cera Pro',
            ),
          ),
        ],
      ),
    );
  }
}

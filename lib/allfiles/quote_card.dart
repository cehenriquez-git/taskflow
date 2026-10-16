import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Tarjeta de frase: fondo #EEEBF7 · texto en cursiva 13 pt.
class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.margin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.quoteBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '“',
              style: TextStyle(
                fontSize: 28,
                height: 0.8,
                color: AppColors.primaryMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              quote,
              style: const TextStyle(
                fontSize: AppDimensions.quoteTextSize,
                fontStyle: FontStyle.italic,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— $author',
              style: const TextStyle(
                fontSize: AppDimensions.quoteTextSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/product.dart';
import '../../screen/favorites/controller/favorites_controller.dart';

/// Toggles the favourite state for [product]. Reacts to the shared
/// [FavoritesController] so every instance stays in sync.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.product, this.iconSize = 24});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isFavorite = controller.isFavorite(product.id);
      return IconButton(
        tooltip: isFavorite ? 'Remove from favourites' : 'Add to favourites',
        onPressed: () => controller.toggle(product),
        iconSize: iconSize,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? colorScheme.error : colorScheme.outline,
        ),
      );
    });
  }
}

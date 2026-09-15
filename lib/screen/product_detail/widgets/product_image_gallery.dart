import 'package:flutter/material.dart';

import '../../../core/widgets/product_network_image.dart';

class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    required this.heroTag,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final String heroTag;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (images.isEmpty) {
      return SizedBox(
        height: 240,
        child: ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported_outlined, color: colorScheme.outline),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final image = ProductNetworkImage(url: images[index]);
              if (index == 0) {
                return Hero(tag: heroTag, child: image);
              }
              return image;
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final selected = index == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

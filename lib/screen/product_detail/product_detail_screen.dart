import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/state/view_status.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loading.dart';
import '../../domain/entities/product.dart';
import 'controller/product_detail_controller.dart';
import 'widgets/product_image_gallery.dart';

class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: Obx(() {
        switch (controller.viewStatus.value) {
          case ViewStatus.loading:
            return const AppLoading(message: 'Loading product...');
          case ViewStatus.error:
            return AppErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.loadProduct,
            );
          case ViewStatus.empty:
            return AppErrorView(
              message: 'Product not found.',
              onRetry: controller.loadProduct,
            );
          case ViewStatus.success:
            final product = controller.product.value;
            if (product == null) {
              return AppErrorView(
                message: 'Product not found.',
                onRetry: controller.loadProduct,
              );
            }
            return _ProductDetailBody(
              product: product,
              imageIndex: controller.imageIndex.value,
              onImageChanged: controller.onImageChanged,
            );
        }
      }),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.product,
    required this.imageIndex,
    required this.onImageChanged,
  });

  final Product product;
  final int imageIndex;
  final ValueChanged<int> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final galleryImages = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    return ListView(
      children: [
        ProductImageGallery(
          images: galleryImages,
          heroTag: 'product-thumb-${product.id}',
          currentIndex: imageIndex,
          onPageChanged: onImageChanged,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.brand != null && product.brand!.isNotEmpty)
                Text(
                  product.brand!.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                product.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    product.formattedPrice,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _RatingChip(rating: product.rating),
                ],
              ),
              const SizedBox(height: 24),
              Text('Description', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(2),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

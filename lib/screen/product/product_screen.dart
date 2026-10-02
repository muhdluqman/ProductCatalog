import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/state/view_status.dart';
import '../../core/widgets/app_empty.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loading.dart';
import 'controller/product_controller.dart';
import 'widgets/product_list_tile.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.unfocusSearch,
          child: const Text('Product Catalog'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: controller.searchController,
              focusNode: controller.searchFocusNode,
              onChanged: controller.onSearchChanged,
              onSubmitted: controller.runSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (!controller.hasSearchText.value) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: 'Clear search',
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: controller.unfocusSearch,
        child: Column(
          children: [
            Obx(() {
              if (!controller.showRecentSearches) {
                return const SizedBox.shrink();
              }
              return _RecentSearchesPanel(
                searches: controller.recentSearches.toList(),
                onSelected: controller.runSearch,
                onClear: controller.clearRecentSearches,
              );
            }),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
        switch (controller.viewStatus.value) {
          case ViewStatus.loading:
            return AppLoading(
              message: controller.isSearching
                  ? 'Searching products...'
                  : 'Loading products...',
            );
          case ViewStatus.error:
            return AppErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.retry,
            );
          case ViewStatus.empty:
            return AppEmptyView(
              title: controller.isSearching
                  ? 'No matches for "${controller.searchQuery.value}"'
                  : 'No products found',
              subtitle: controller.isSearching
                  ? 'Try a different keyword.'
                  : 'Pull to refresh or try again later.',
              icon: controller.isSearching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
            );
          case ViewStatus.success:
            return RefreshIndicator(
              onRefresh: controller.refreshProducts,
              child: ListView.separated(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount:
                    controller.products.length +
                    (controller.isLoadingMore.value || !controller.hasMore.value
                        ? 1
                        : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index >= controller.products.length) {
                    if (controller.isLoadingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "You're all caught up",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ProductListTile(product: controller.products[index]);
                },
              ),
            );
        }
      });
  }
}

class _RecentSearchesPanel extends StatelessWidget {
  const _RecentSearchesPanel({
    required this.searches,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Text(
                  'Recent searches',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          ...searches.map(
            (query) => ListTile(
              dense: true,
              leading: Icon(Icons.history, color: colorScheme.outline),
              title: Text(query),
              onTap: () => onSelected(query),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

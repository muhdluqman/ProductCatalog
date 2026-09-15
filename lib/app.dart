import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screen/routes/app_pages.dart';
import 'screen/routes/app_routes.dart';
import 'screen/theme/app_theme.dart';

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.productList,
      getPages: AppPages.pages,
    );
  }
}

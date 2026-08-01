import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import 'catalog_tab.dart';
import 'products_tab.dart';
import 'purchase_orders_tab.dart';
import 'stock_tab.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.inventoryTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.inventoryProducts),
              Tab(text: l10n.inventoryStockLevel),
              Tab(text: l10n.inventoryPurchaseOrders),
              const Tab(text: 'Catalog'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductsTab(),
            StockTab(),
            PurchaseOrdersTab(),
            CatalogTab(),
          ],
        ),
      ),
    );
  }
}

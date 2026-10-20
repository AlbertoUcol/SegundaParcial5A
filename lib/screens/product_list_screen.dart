import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'login_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({this.apiService, super.key});

  final ApiService? apiService;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final _apiService = widget.apiService ?? ApiService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _apiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> _addProduct() async {
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(builder: (_) => const ProductFormScreen()),
    );
    if (product == null || !mounted) return;

    setState(() {
      final nextId =
          _products.fold<int>(
            0,
            (highest, item) => item.id > highest ? item.id : highest,
          ) +
          1;
      _products = [
        Product(
          id: nextId,
          title: product.title,
          price: product.price,
          description: product.description,
          category: product.category,
          image: product.image,
        ),
        ..._products,
      ];
    });
  }

  void _updateProduct(Product updatedProduct) {
    setState(() {
      _products = _products
          .map(
            (product) =>
                product.id == updatedProduct.id ? updatedProduct : product,
          )
          .toList(growable: true);
    });
  }

  void _deleteProduct(int productId) {
    setState(() {
      _products.removeWhere((product) => product.id == productId);
    });
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded),
            SizedBox(width: 10),
            Text('Productos'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar catálogo',
            onPressed: _isLoading ? null : _loadProducts,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catálogo de productos',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Consulta y administra tu inventario',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o categoría',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent(products, theme)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar producto'),
      ),
    );
  }

  Widget _buildContent(List<Product> products, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: theme.colorScheme.primary,
                size: 52,
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: theme.colorScheme.primary,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                _products.isEmpty
                    ? 'Todavía no hay productos en el catálogo.'
                    : 'No encontramos productos con esa búsqueda.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(
                  product: product,
                  onProductUpdated: _updateProduct,
                  onProductDeleted: _deleteProduct,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

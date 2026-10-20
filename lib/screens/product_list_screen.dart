import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

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
  String? _selectedCategory;

  static const _apiCategories = [
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing",
  ];

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

  List<String> get _categories {
    final categories =
        <String>{
          ..._apiCategories,
          ..._products.map((product) => product.category),
        }.toList()..sort(
          (first, second) =>
              _categoryLabel(first).compareTo(_categoryLabel(second)),
        );
    return categories;
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products
        .where((product) {
          final matchesCategory =
              _selectedCategory == null ||
              product.category == _selectedCategory;
          final matchesSearch =
              query.isEmpty ||
              product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);
          return matchesCategory && matchesSearch;
        })
        .toList(growable: false);
  }

  String _categoryLabel(String category) {
    return switch (category.toLowerCase()) {
      'electronics' => 'Electrónica',
      'jewelery' => 'Joyería',
      "men's clothing" => 'Ropa de hombre',
      "women's clothing" => 'Ropa de mujer',
      _ => category[0].toUpperCase() + category.substring(1),
    };
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
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar(theme)),
            SliverToBoxAdapter(child: _buildCategorySelector(theme)),
            SliverToBoxAdapter(child: _buildMarketplaceBanner(theme)),
            SliverToBoxAdapter(child: _buildSectionHeading(theme, products)),
            _buildProductContent(products, theme),
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

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar productos',
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
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(theme: theme, label: 'Todos', category: null),
          ..._categories.map(
            (category) => _buildCategoryChip(
              theme: theme,
              label: _categoryLabel(category),
              category: category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required ThemeData theme,
    required String label,
    required String? category,
  }) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        key: ValueKey('category-${category ?? 'all'}'),
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildMarketplaceBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todo lo que buscas, en un solo lugar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explora el catálogo y encuentra tu próximo producto.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(ThemeData theme, List<Product> products) {
    final title = _selectedCategory == null
        ? 'Catálogo de productos'
        : _categoryLabel(_selectedCategory!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              key: const ValueKey('catalog-heading'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!_isLoading && _errorMessage == null)
            Text(
              '${products.length} productos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductContent(List<Product> products, ThemeData theme) {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
        ),
      );
    }

    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
                      : 'No encontramos productos con estos filtros.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = width < 360
              ? 2
              : (width / 190).floor().clamp(2, 5).toInt();

          return SliverGrid.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 300,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
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
        },
      ),
    );
  }
}

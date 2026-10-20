import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.product,
    required this.onProductUpdated,
    required this.onProductDeleted,
    super.key,
  });

  final Product product;
  final ValueChanged<Product> onProductUpdated;
  final ValueChanged<int> onProductDeleted;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product = widget.product;

  Future<void> _editProduct() async {
    final updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => ProductFormScreen(product: _product),
      ),
    );
    if (updatedProduct == null || !mounted) return;
    setState(() => _product = updatedProduct);
    widget.onProductUpdated(updatedProduct);
  }

  Future<void> _deleteProduct() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text('Se eliminará "${_product.title}" del catálogo actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    widget.onProductDeleted(_product.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de producto')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            height: 280,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Image.network(
              _product.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inventory_2_rounded,
                size: 90,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.sell_outlined, size: 18),
              label: Text(_product.category),
              backgroundColor: theme.colorScheme.secondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _product.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${_product.price.toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Descripción',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _product.description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteProduct,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _editProduct,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

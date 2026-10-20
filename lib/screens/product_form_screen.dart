import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({this.product, super.key});

  final Product? product;

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _imageController = TextEditingController(text: product?.image ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    final price = double.tryParse(value!.trim());
    if (price == null || price <= 0) {
      return 'Ingresa un precio válido mayor a 0';
    }
    return null;
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.product;
    final product = Product(
      id: existing?.id ?? 0,
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      image: _imageController.text.trim(),
    );

    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      color: theme.colorScheme.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Completa los datos del producto para agregarlo al catálogo.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: _priceValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: _saveProduct,
                icon: Icon(
                  widget.isEditing ? Icons.check_rounded : Icons.add_rounded,
                ),
                label: Text(
                  widget.isEditing ? 'Guardar cambios' : 'Agregar producto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

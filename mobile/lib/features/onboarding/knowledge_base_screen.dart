import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user/model/product_model.dart';
import '../user/model/knowledge_document_model.dart'
    show KnowledgeDocumentModel, DocumentType, UploadStatus;
import '../user/model/faq_model.dart';
import '../user/providers/user_provider.dart';
import '../ai/presentation/screens/home_screen.dart';
import 'greeting_template_screen.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primarySoft = Color(0xFFB3A1FF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);
  static const Color errorColor = Color(0xFFFF4D4F);

  bool _isLoading = false;
  bool _isLoadingInitialData = true;

  List<ProductModel> _products = [];
  List<KnowledgeDocumentModel> _documents = [];
  List<FaqModel> _faqs = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userProvider = context.read<UserProvider>();
    final products = await userProvider.loadProducts();
    final documents = await userProvider.loadDocuments();
    final faqs = await userProvider.loadFaqs();

    if (mounted) {
      setState(() {
        _products = products;
        _documents = documents;
        _faqs = faqs;
        _isLoadingInitialData = false;
      });
    }
  }

  bool get _hasKnowledge {
    return _products.isNotEmpty || _documents.isNotEmpty || _faqs.isNotEmpty;
  }

  Future<void> _continue() async {
    if (!_hasKnowledge || _isLoading) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.saveKnowledgeBase();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Failed to save knowledge base.'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => const HomeScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoadingInitialData
                  ? const Center(child: CircularProgressIndicator(color: primary))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 28),
                          _buildProductsSection(),
                          const SizedBox(height: 28),
                          _buildDocumentsSection(),
                          const SizedBox(height: 28),
                          _buildFaqsSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const GreetingTemplateScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textPrimary,
                    size: 17,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '8 of 8',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  color: card,
                ),
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Teach Vexa about your business',
          style: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Add your products, documents, and common questions so Vexa can answer customers accurately.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // PRODUCTS SECTION
  // ──────────────────────────────────────────────────────────────────

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products & Pricing',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            _buildAddButton(
              icon: Icons.add_rounded,
              label: 'Add Product',
              onTap: () => _showProductDialog(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_products.isEmpty)
          _buildEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products yet',
            subtitle: 'Add your first product or service',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildProductCard(_products[index]),
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: primarySoft,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description!,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.unit != null && product.unit!.isNotEmpty)
                    Text(
                      '/ ${product.unit}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showProductDialog(product: product),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: primarySoft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteProduct(product),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: errorColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showProductDialog({ProductModel? product}) async {
  final isEditing = product != null;

  final nameController = TextEditingController(
    text: product?.name ?? '',
  );

  final priceController = TextEditingController(
    text: product?.price.toString() ?? '',
  );

  final descriptionController = TextEditingController(
    text: product?.description ?? '',
  );

  final unitController = TextEditingController(
    text: product?.unit ?? '',
  );

  final formKey = GlobalKey<FormState>();

  String currency = product?.currency ?? 'INR';
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isEditing ? 'Edit Product' : 'Add Product',
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: textPrimary),
                      decoration: _inputDecoration(
                        label: 'Product/Service Name',
                        hint: 'e.g., Aluminium Door',
                        prefixIcon: Icons.inventory_2_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: priceController,
                            style: const TextStyle(color: textPrimary),
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              label: 'Price',
                              hint: '25000',
                              prefixIcon:
                                  Icons.currency_rupee_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }

                              final price = double.tryParse(v);

                              if (price == null || price <= 0) {
                                return 'Invalid price';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: currency,
                            dropdownColor: card,
                            style: const TextStyle(
                              color: textPrimary,
                            ),
                            decoration: _inputDecoration(
                              label: 'Currency',
                              hint: 'INR',
                              prefixIcon: Icons.flag_outlined,
                            ),
                            items: ['INR', 'USD', 'EUR', 'GBP']
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  currency = v;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      style: const TextStyle(color: textPrimary),
                      maxLines: 2,
                      decoration: _inputDecoration(
                        label: 'Description (optional)',
                        hint: 'Brief description of the product',
                        prefixIcon: Icons.description_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: unitController,
                      style: const TextStyle(color: textPrimary),
                      decoration: _inputDecoration(
                        label: 'Unit (optional)',
                        hint: 'per piece, per sq ft, per hour',
                        prefixIcon: Icons.straighten_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isSaving
                        ? null
                        : () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: textSecondary),
                ),
              ),

              ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setState(() {
                              isSaving = true;
                            });

                            final userProvider =
                                context.read<UserProvider>();

                            bool success;

                            if (isEditing) {
                              success =
                                  await userProvider.updateProduct(
                                productId: product!.id,
                                name: nameController.text.trim(),
                                price: double.parse(
                                  priceController.text,
                                ),
                                currency: currency,
                                description:
                                    descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text
                                            .trim(),
                                unit:
                                    unitController.text.trim().isEmpty
                                        ? null
                                        : unitController.text.trim(),
                              );
                            } else {
                              success =
                                  await userProvider.addProduct(
                                name: nameController.text.trim(),
                                price: double.parse(
                                  priceController.text,
                                ),
                                currency: currency,
                                description:
                                    descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text
                                            .trim(),
                                unit:
                                    unitController.text.trim().isEmpty
                                        ? null
                                        : unitController.text.trim(),
                              );
                            }

                            if (!dialogContext.mounted) {
                              return;
                            }

                            setState(() {
                              isSaving = false;
                            });

                            if (!success) {
                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    userProvider.error ??
                                        'Failed to save product.',
                                  ),
                                  backgroundColor: errorColor,
                                ),
                              );
                              return;
                            }

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            await _loadInitialData();
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          isEditing ? 'Save' : 'Add',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _confirmDeleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Product',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Delete "${product.name}"? This cannot be undone.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel',
                style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.deleteProduct(product.id);

      if (!context.mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to delete product.'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // DOCUMENTS SECTION
  // ──────────────────────────────────────────────────────────────────

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Business Documents',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            _buildAddButton(
              icon: Icons.upload_file_rounded,
              label: 'Upload Document',
              onTap: () => _pickAndUploadDocument(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_documents.isEmpty)
          _buildEmptyState(
            icon: Icons.description_outlined,
            title: 'No documents yet',
            subtitle: 'Upload price lists, menus, brochures, etc.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildDocumentCard(_documents[index]),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(KnowledgeDocumentModel document) {
    final isUploading = document.uploadStatus == UploadStatus.uploading;
    final isPending = document.uploadStatus == UploadStatus.pending;
    final isFailed = document.uploadStatus == UploadStatus.failed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFailed
              ? errorColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.055),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getDocumentTypeColor(document.documentType)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDocumentTypeIcon(document.documentType),
                  color: _getDocumentTypeColor(document.documentType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDocumentTypeColor(document.documentType)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            document.documentTypeLabel,
                            style: TextStyle(
                              color: _getDocumentTypeColor(document.documentType),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          document.formattedFileSize,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildDocumentStatusBadge(document),
            ],
          ),
          if (isFailed) ...[
            const SizedBox(height: 8),
            Text(
              document.errorMessage ?? 'Upload failed',
              style: const TextStyle(
                color: errorColor,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isUploading && !isPending)
                TextButton.icon(
                  onPressed: () => _confirmDeleteDocument(document),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: errorColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusBadge(KnowledgeDocumentModel document) {
    Color color;
    String label;
    IconData icon;

    switch (document.uploadStatus) {
      case UploadStatus.uploading:
        color = primary;
        label = 'Uploading...';
        icon = Icons.cloud_upload_outlined;
        break;
      case UploadStatus.pending:
        color = Colors.orangeAccent;
        label = 'Pending';
        icon = Icons.schedule_outlined;
        break;
      case UploadStatus.failed:
        color = errorColor;
        label = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.greenAccent;
        label = 'Ready';
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.priceList:
        return Colors.blueAccent;
      case DocumentType.menu:
        return Colors.greenAccent;
      case DocumentType.brochure:
        return Colors.purpleAccent;
      case DocumentType.catalog:
        return Colors.orangeAccent;
      case DocumentType.other:
        return textSecondary;
    }
  }

  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.priceList:
        return Icons.attach_money_outlined;
      case DocumentType.menu:
        return Icons.restaurant_menu_outlined;
      case DocumentType.brochure:
        return Icons.book_outlined;
      case DocumentType.catalog:
        return Icons.grid_view_outlined;
      case DocumentType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'csv', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      final documentType = await _showDocumentTypeDialog();
      if (documentType == null) return;

      final userProvider = context.read<UserProvider>();

      final uploadedDocument = await userProvider.uploadDocument(
        documentType: documentType,
        file: file,
      );

      if (!mounted) return;

      if (uploadedDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to upload document.'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      setState(() {
        _documents.insert(0, uploadedDocument);
      });
    } catch (e, stackTrace) {
      developer.log('Error picking/uploading document', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<DocumentType?> _showDocumentTypeDialog() async {
    return await showDialog<DocumentType>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Document Type',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentType.values.map((type) {
            return RadioListTile<DocumentType>(
              value: type,
              groupValue: DocumentType.other,
              title: Text(type.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}').trim(),
                  style: const TextStyle(color: textPrimary)),
              secondary: Icon(_getDocumentTypeIcon(type),
                  color: _getDocumentTypeColor(type)),
              activeColor: primary,
              onChanged: (value) {
                Navigator.pop(dialogContext, value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDocument(KnowledgeDocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Remove Document',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Remove "${document.fileName}"? This will delete the file from storage.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel',
                style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.deleteDocument(
        documentId: document.id,
        storagePath: document.storagePath,
      );

      if (!context.mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to remove document.'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      setState(() {
        _documents.removeWhere((d) => d.id == document.id);
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // FAQs SECTION
  // ──────────────────────────────────────────────────────────────────

  Widget _buildFaqsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Questions (FAQs)',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            _buildAddButton(
              icon: Icons.help_outline_rounded,
              label: 'Add FAQ',
              onTap: () => _showFaqDialog(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_faqs.isEmpty)
          _buildEmptyState(
            icon: Icons.help_outline_rounded,
            title: 'No FAQs yet',
            subtitle: 'Add common customer questions and answers',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildFaqCard(_faqs[index]),
          ),
      ],
    );
  }

  Widget _buildFaqCard(FaqModel faq) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: primarySoft,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q: ${faq.question}',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A: ${faq.answer}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showFaqDialog(faq: faq),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: primarySoft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteFaq(faq),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: errorColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showFaqDialog({FaqModel? faq}) async {
  final isEditing = faq != null;

  final questionController = TextEditingController(
    text: faq?.question ?? '',
  );

  final answerController = TextEditingController(
    text: faq?.answer ?? '',
  );

  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isEditing ? 'Edit FAQ' : 'Add FAQ',
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: questionController,
                      style: const TextStyle(
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      decoration: _inputDecoration(
                        label: 'Question',
                        hint: 'e.g., Do you provide home delivery?',
                        prefixIcon: Icons.question_answer_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Question is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: answerController,
                      style: const TextStyle(
                        color: textPrimary,
                      ),
                      maxLines: 4,
                      decoration: _inputDecoration(
                        label: 'Answer',
                        hint: 'e.g., Yes, we provide delivery within Indore.',
                        prefixIcon: Icons.lightbulb_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Answer is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: textSecondary,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        setState(() {
                          isSaving = true;
                        });

                        final userProvider =
                            context.read<UserProvider>();

                        bool success;

                        if (isEditing) {
                          success = await userProvider.updateFaq(
                            faqId: faq!.id,
                            question:
                                questionController.text.trim(),
                            answer:
                                answerController.text.trim(),
                          );
                        } else {
                          success = await userProvider.addFaq(
                            question:
                                questionController.text.trim(),
                            answer:
                                answerController.text.trim(),
                          );
                        }

                        if (!dialogContext.mounted) {
                          return;
                        }

                        setState(() {
                          isSaving = false;
                        });

                        if (!success) {
                          ScaffoldMessenger.of(
                            dialogContext,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                userProvider.error ??
                                    'Failed to save FAQ.',
                              ),
                              backgroundColor: errorColor,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(dialogContext);

                        await _loadInitialData();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Save' : 'Add',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _confirmDeleteFaq(FaqModel faq) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete FAQ',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Delete this FAQ? This cannot be undone.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel',
                style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.deleteFaq(faq.id);

      if (!context.mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to delete FAQ.'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      setState(() {
        _faqs.removeWhere((f) => f.id == faq.id);
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // SHARED UI HELPERS
  // ──────────────────────────────────────────────────────────────────

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primarySoft, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: primarySoft,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.055),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: textSecondary, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: textSecondary, fontSize: 13),
      hintStyle: TextStyle(
        color: textSecondary.withOpacity(0.55),
        fontSize: 13.5,
      ),
      prefixIcon: Icon(prefixIcon, color: textSecondary, size: 20),
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.055)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorColor, width: 1.2),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.045),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _hasKnowledge && !_isLoading ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            disabledBackgroundColor: card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: _hasKnowledge ? Colors.white : textSecondary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _hasKnowledge ? Colors.white : textSecondary,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

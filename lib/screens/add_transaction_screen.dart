import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../services/gemini_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryType _selectedCategory = CategoryType.food;
  DateTime _selectedDate = DateTime.now();
  List<TransactionItem> _scannedItems = []; // Add this

  bool _isScanning = false; // loading indicator for Gemini

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- SmartReceipt ---
  CategoryType _mapCategory(String? raw) {
    if (raw == null) return CategoryType.others;
    switch (raw.toLowerCase()) {
      case 'food':
        return CategoryType.food;
      case 'transportation':
        return CategoryType.transport;
      case 'groceries':
      case 'shopping':
        return CategoryType.shopping;
      case 'bills':
        return CategoryType.bills;
      case 'entertainment':
        return CategoryType.entertainment;
      default:
        return CategoryType.others;
    }
  }

  Future<void> _scanReceipt() async {
    // Ask user: camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan Receipt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt_rounded),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.photo_library_rounded),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() => _isScanning = true);

    try {
      final data = await GeminiService.scanReceipt(File(picked.path));

      setState(() {
        if (data.merchantName != null && data.merchantName!.isNotEmpty) {
          _titleController.text = data.merchantName!;
        }
        if (data.totalAmount != null) {
          _amountController.text = data.totalAmount!.toInt().toString();
        }
        if (data.date != null) {
          final parsed = DateTime.tryParse(data.date!);
          if (parsed != null) _selectedDate = parsed;
        }
        _selectedCategory = _mapCategory(data.category);
        _selectedType = TransactionType.expense;
        if (data.items != null) {
          _scannedItems = data.items!;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Struk berhasil dipindai! Periksa & edit hasilnya.'),
              ],
            ),
            backgroundColor: const Color(0xFF06D6A0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }
  // --- end SmartReceipt ---

  void _save() {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        type: _selectedType,
        category: _selectedType == TransactionType.income
            ? CategoryType.salary
            : _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        items: _scannedItems.isNotEmpty ? _scannedItems : null, // Add this
      );
      context.read<TransactionProvider>().addTransaction(transaction);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction added successfully!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Add Transaction',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              // SmartReceipt button in AppBar
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _isScanning ? null : _scanReceipt,
                  icon: const Icon(Icons.document_scanner_rounded, size: 20),
                  label: const Text(
                    'Scan Struk',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Type Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _TypeButton(
                        label: 'Expense',
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFFF6B6B),
                        isSelected: _selectedType == TransactionType.expense,
                        onTap: () => setState(
                            () => _selectedType = TransactionType.expense),
                      ),
                      _TypeButton(
                        label: 'Income',
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFF06D6A0),
                        isSelected: _selectedType == TransactionType.income,
                        onTap: () => setState(
                            () => _selectedType = TransactionType.income),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title / Merchant Name',
                    prefixIcon: Icon(Icons.title_rounded),
                    hintText: 'e.g. Lunch, Grab, Salary...',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (Rp)',
                    prefixIcon: Icon(Icons.payments_rounded),
                    hintText: '0',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter amount';
                    }
                    final num =
                        double.tryParse(v.replaceAll(',', '.'));
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date picker
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.note_alt_rounded),
                    hintText: 'Add a note...',
                  ),
                  maxLines: 2,
                ),

                // Scanned Items List
                if (_scannedItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Scanned Items',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _scannedItems.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final item = _scannedItems[i];
                        return ListTile(
                          dense: true,
                          title: Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              '${item.quantity} x Rp ${item.unitPrice.toStringAsFixed(0)}'),
                          trailing: Text(
                            'Rp ${item.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Category picker for expense
                if (_selectedType == TransactionType.expense) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Category',
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                    children: CategoryType.values
                        .where((c) => c != CategoryType.salary)
                        .map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color.withValues(alpha: 0.2)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                color: isSelected
                                    ? category.color
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? category.color
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save Transaction',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Full-screen loading overlay while scanning
        if (_isScanning) const _AIScanningOverlay(),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Animated AI Scanning Overlay
// ─────────────────────────────────────────────
class _AIScanningOverlay extends StatefulWidget {
  const _AIScanningOverlay();

  @override
  State<_AIScanningOverlay> createState() => _AIScanningOverlayState();
}

class _AIScanningOverlayState extends State<_AIScanningOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scanLineCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _dotCtrl;
  late final AnimationController _fadeCtrl;
  late final AnimationController _rotateCtrl;
  late final Animation<double> _scanLine;
  late final Animation<double> _pulse;
  late final Animation<double> _fade;

  final List<String> _messages = [
    'Menganalisis gambar struk...',
    'AI sedang membaca teks...',
    'Mengekstrak data merchant...',
    'Menghitung total belanja...',
    'Mengidentifikasi kategori...',
    'Hampir selesai...',
  ];
  int _msgIndex = 0;

  @override
  void initState() {
    super.initState();

    // Scanning line goes top → bottom → top
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanLine = CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut);

    // Pulse the receipt icon
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Rotating ring
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Dot loading
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Fade in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Cycle through messages
    _cycleMessages();
  }

  Future<void> _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) break;
      setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    }
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _dotCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated receipt scanner graphic ──
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating dashed ring
                      AnimatedBuilder(
                        animation: _rotateCtrl,
                        builder: (_, __) => Transform.rotate(
                          angle: _rotateCtrl.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(110, 110),
                            painter: _DashedRingPainter(color: primary),
                          ),
                        ),
                      ),
                      // Receipt card + scan line
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 80,
                          child: Stack(
                            children: [
                              // Receipt background
                              Container(
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primary.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                    (i) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: primary.withValues(
                                              alpha: i == 4 ? 0.5 : 0.2),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        width: i == 4 ? 28 : double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Scan line
                              AnimatedBuilder(
                                animation: _scanLine,
                                builder: (_, __) => Positioned(
                                  top: _scanLine.value * 72,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          primary,
                                          primary,
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              primary.withValues(alpha: 0.8),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Pulse ring
                      ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── AI Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'SmartReceipt AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Cycling status message ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _messages[_msgIndex],
                    key: ValueKey(_msgIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Animated dots ──
                _AnimatedDots(controller: _dotCtrl, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated 3-dot loader ──
class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _AnimatedDots({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((controller.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 0.5 + 0.5 * math.sin(value * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4 + 0.6 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Dashed ring painter ──
class _DashedRingPainter extends CustomPainter {
  final Color color;
  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 16;
    const dashAngle = 2 * math.pi / dashCount;
    const gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}


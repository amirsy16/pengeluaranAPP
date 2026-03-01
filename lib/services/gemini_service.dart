import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction_model.dart'; // Import TransactionItem

/// Data class returned after Gemini parses the receipt image.
class ReceiptData {
  final String? merchantName;
  final String? date; // YYYY-MM-DD
  final double? totalAmount;
  final String? category;
  final List<TransactionItem>? items; // Add items list

  const ReceiptData({
    this.merchantName,
    this.date,
    this.totalAmount,
    this.category,
    this.items, // Add to constructor
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    double? parseAmount(dynamic raw) {
      if (raw == null) return null;
      if (raw is num) return raw.toDouble();
      return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    // Parse items
    List<TransactionItem>? itemsList;
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List).map((itemJson) {
        final amount = parseAmount(itemJson['total_price']) ?? 0;
        final qty = itemJson['quantity'] is int
            ? itemJson['quantity'] as int
            : int.tryParse(itemJson['quantity'].toString()) ?? 1;
        final unitPrice = parseAmount(itemJson['unit_price']) ?? (qty > 0 ? amount / qty : 0);

        return TransactionItem(
          name: itemJson['name']?.toString() ?? 'Unknown Item',
          quantity: qty,
          unitPrice: unitPrice,
          amount: amount,
        );
      }).toList();
    }

    return ReceiptData(
      merchantName: json['merchant_name'] as String?,
      date: json['date'] as String?,
      totalAmount: parseAmount(json['total_amount']),
      category: json['category'] as String?,
      items: itemsList,
    );
  }
}

class GeminiService {
  static final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; // Use dotenv instead of hardcoded key
  static const _modelName = 'gemini-flash-latest';

  static const _prompt =
      'You are an automated receipt scanner. Extract information from the provided receipt image. '
      'Provide the response ONLY in pure JSON format without any additional text and without markdown backticks. '
      'Use the following keys: '
      '{ '
      '"merchant_name": "(String) Name of the store", '
      '"date": "(String) Date in YYYY-MM-DD format", '
      '"total_amount": "(Number) Final total amount", '
      '"category": "(String) Choose one: [Food, Transportation, Groceries, Bills, Entertainment, Others]", '
      '"items": [ '
      '  { '
      '    "name": "(String) Item name", '
      '    "quantity": "(Integer) quantity, default 1", '
      '    "unit_price": "(Number) Price per unit", '
      '    "total_price": "(Number) Total price for this line item" '
      '  } '
      '] '
      '} '
      'If any information is unreadable, set the value to null.';

  /// Compress image to ≤ 1 MB then send to Gemini.
  /// Returns [ReceiptData] on success, throws [Exception] on failure.
  static Future<ReceiptData> scanReceipt(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key not found. Please set GEMINI_API_KEY in .env file.');
    }

    // --- step 1: compress ---
    Uint8List? compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );

    if (compressed == null) {
      throw Exception('Gagal mengompresi gambar. Coba pilih gambar lain.');
    }

    // keep compressing if still > 1 MB
    if (compressed.length > 1024 * 1024) {
      final again = await FlutterImageCompress.compressWithList(
        compressed,
        quality: 40,
      );
      compressed = again;
    }

    // --- step 2: call Gemini ---
    final model = GenerativeModel(model: _modelName, apiKey: _apiKey);

    final content = [
      Content.multi([
        TextPart(_prompt),
        DataPart('image/jpeg', compressed),
      ])
    ];

    final response = await model.generateContent(content);
    final text = response.text;

    if (text == null || text.isEmpty) {
      throw Exception('Gemini tidak memberikan respons. Coba lagi.');
    }

    // --- step 3: parse JSON safely ---
    try {
      // Strip possible markdown fences just in case
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final Map<String, dynamic> jsonMap = jsonDecode(cleaned);
      return ReceiptData.fromJson(jsonMap);
    } catch (_) {
      throw Exception(
          'AI mengembalikan respons yang tidak valid. '
          'Pastikan foto struk jelas dan coba lagi.');
    }
  }
}

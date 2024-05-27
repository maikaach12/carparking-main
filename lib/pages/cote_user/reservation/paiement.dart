import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductCreationPage extends StatefulWidget {
  @override
  _ProductCreationPageState createState() => _ProductCreationPageState();
}

class _ProductCreationPageState extends State<ProductCreationPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productAmountController = TextEditingController();

  Future<void> addProduct() async {
    final url = 'https://pay.chargily.net/test/api/v2/products';
    final headers = {
      'Authorization':
          'Bearer test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      "name": productNameController.text,
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      // Product added successfully
      final productId = jsonDecode(response.body)['id'];
      setState(() {
        productIdController.text = productId;
      });
      await addPrice(productId);
    } else {
      // Handle error
      print('Failed to add product: ${response.body}');
    }
  }

  Future<void> addPrice(String productId) async {
    final url = 'https://pay.chargily.net/test/api/v2/prices';
    final headers = {
      'Authorization':
          'Bearer test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      "amount": int.parse(productAmountController.text),
      "currency": "dzd",
      "product_id": productId,
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      // Price added successfully
      print('Product and price added successfully.');
      await createCheckout(jsonDecode(response.body)['id']);
    } else {
      // Handle error
      print('Failed to add price: ${response.body}');
    }
  }

  Future<void> createCheckout(String priceId) async {
    final url = 'https://pay.chargily.net/test/api/v2/checkouts';
    final headers = {
      'Authorization':
          'Bearer test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      "items": [
        {"price": priceId, "quantity": 1}
      ],
      "success_url": "https://your-cool-website.com/payments/success"
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      // Checkout created successfully
      final checkoutUrl = jsonDecode(response.body)['url'];
      print('Checkout created successfully. URL: $checkoutUrl');
      // Navigate to checkout URL or open in browser
    } else {
      // Handle error
      print('Failed to create checkout: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Creation Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: productIdController,
              decoration: InputDecoration(labelText: 'Product ID'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: productAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Product Amount'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addProduct();
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductCreationPage(),
  ));
}

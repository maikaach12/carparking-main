import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaiementPage extends StatefulWidget {
  final String userId;

  PaiementPage({required this.userId});

  @override
  _PaiementPageState createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _signatureController = TextEditingController();

  // Expiration date fields
  String? _selectedMonth;
  String? _selectedYear;

  final List<String> _months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];

  final List<String> _years = List<String>.generate(
      20, (index) => (DateTime.now().year + index).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement', style: GoogleFonts.lato(fontSize: 24)),
        backgroundColor: Colors.blueAccent,
        leading: Icon(Icons.payment),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisir le mode de paiement:',
                  style: GoogleFonts.lato(fontSize: 20)),
              SizedBox(height: 10),
              _buildPaymentMethodGrid(),
              SizedBox(height: 20),
              Visibility(
                visible: _selectedPaymentMethod != null,
                child: Column(
                  children: [
                    _buildTextField('Nom', _nameController, Icons.person),
                    _buildTextField(
                        'Prenom', _surnameController, Icons.person_outline),
                    _buildTextField('Numéro de carte', _cardNumberController,
                        Icons.credit_card),
                    _buildTextField('Numéro CVV', _cvvController, Icons.lock,
                        isNumeric: true),
                    _buildExpirationDateSelector(),
                    _buildTextField(
                        'Signature', _signatureController, Icons.create),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.check_circle),
                        label: Text('Valider',
                            style: GoogleFonts.lato(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: GoogleFonts.lato(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPaymentMethodCard('Carte Bancaire', 'lib/images/banque.jpeg'),
        _buildPaymentMethodCard('Baridi Mob', 'lib/images/gg.png'),
        _buildPaymentMethodCard('Carte Edahabia', 'lib/images/dahabia.jpeg'),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          width: 100,
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(imagePath, height: 50, fit: BoxFit.cover),
              SizedBox(height: 8),
              Text(method, style: GoogleFonts.lato(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est obligatoire';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExpirationDateSelector() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                labelText: 'Mois',
                prefixIcon: Icon(Icons.date_range),
              ),
              value: _selectedMonth,
              items: _months.map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sélectionnez un mois';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                labelText: 'Année',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              value: _selectedYear,
              items: _years.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sélectionnez une année';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Process the payment with the provided information
      try {
        // Create a new document in the 'paiement' collection
        DocumentReference paymentRef =
            await FirebaseFirestore.instance.collection('paiement').add({
          'userId':
              widget.userId, // Use the userId passed from the previous page
          'paymentMethod': _selectedPaymentMethod,
          'name': _nameController.text,
          'surname': _surnameController.text,
          'cardNumber': _cardNumberController.text,
          'cvv': _cvvController.text,
          'expiryDate': '$_selectedMonth/$_selectedYear',
          'signature': _signatureController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement validé')),
        );

        // Clear the form fields after successful submission
        _nameController.clear();
        _surnameController.clear();
        _cardNumberController.clear();
        _cvvController.clear();
        _signatureController.clear();
        setState(() {
          _selectedPaymentMethod = null;
          _selectedMonth = null;
          _selectedYear = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

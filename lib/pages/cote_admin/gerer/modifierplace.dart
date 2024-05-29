import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierPlacePage extends StatefulWidget {
  final DocumentSnapshot document;

  ModifierPlacePage({required this.document});

  @override
  _ModifierPlacePageState createState() => _ModifierPlacePageState();
}

class _ModifierPlacePageState extends State<ModifierPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  List<String> _placeTypes = ['standard', 'handicapé'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.document['type'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier la place'),
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan
          Image.asset(
            'lib/images/blue.png', // Chemin de l'image d'arrière-plan
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 248, 248),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Modifier la place',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text('ID Parking: ${widget.document['id_parking']}'),
                        SizedBox(height: 16.0),
                        Text(
                          'Sélectionnez le type de place',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                          items: _placeTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _updatePlace();
                              }
                            },
                            child: Text(
                              'Modifier',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePlace() async {
    await _firestore.collection('placeU').doc(widget.document.id).update({
      'type': _selectedType,
    });
    Navigator.pop(context);
  }
}

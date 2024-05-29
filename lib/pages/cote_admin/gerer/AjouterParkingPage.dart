import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjouterParkingPage extends StatefulWidget {
  @override
  _AjouterParkingPageState createState() => _AjouterParkingPageState();
}

class _AjouterParkingPageState extends State<AjouterParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _nom, _place, _latitude, _longitude, _imageName;
  late int _capacite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un parking'),
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan
          Image.asset(
            'lib/images/blue.png',
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
                            'Ajouter un parking',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom du parking:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer un nom de parking';
                            }
                            return null;
                          },
                          onSaved: (value) => _nom = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Place du parking:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer la place de parking';
                            }
                            return null;
                          },
                          onSaved: (value) => _place = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Capacité:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer la capacité';
                            }
                            return null;
                          },
                          onSaved: (value) => _capacite = int.parse(value!),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Latitude:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer une latitude';
                            }
                            return null;
                          },
                          onSaved: (value) => _latitude = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Longitude:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer une longitude';
                            }
                            return null;
                          },
                          onSaved: (value) => _longitude = value!,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'image:',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer le nom de l\'image';
                            }
                            return null;
                          },
                          onSaved: (value) => _imageName = value!,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final User? user = _auth.currentUser;
                                final String? userId = user?.uid;
                                final int placesDisponible = _capacite;
                                await _firestore.collection('parkingu').add({
                                  'nom': _nom,
                                  'place': _place,
                                  'capacite': _capacite,
                                  'position': GeoPoint(
                                    double.parse(_latitude),
                                    double.parse(_longitude),
                                  ),
                                  'id_admin': userId,
                                  'image': _imageName,
                                  'placesDisponible': placesDisponible,
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
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
}

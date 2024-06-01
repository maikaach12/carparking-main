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
  late int _capacite, _prixParTranche, _prixParTrancheHandi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom du parking',
                            prefixIcon: Icon(Icons.local_parking),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer un nom de parking';
                            }
                            return null;
                          },
                          onSaved: (value) => _nom = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Place du parking',
                            prefixIcon: Icon(Icons.place),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer la place de parking';
                            }
                            return null;
                          },
                          onSaved: (value) => _place = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Capacité',
                            prefixIcon: Icon(Icons.directions_car),
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
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.map),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer une latitude';
                            }
                            return null;
                          },
                          onSaved: (value) => _latitude = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.map),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer une longitude';
                            }
                            return null;
                          },
                          onSaved: (value) => _longitude = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'image',
                            prefixIcon: Icon(Icons.image),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer le nom de l\'image';
                            }
                            return null;
                          },
                          onSaved: (value) => _imageName = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Prix par tranche',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer le prix par tranche';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              _prixParTranche = int.parse(value!),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Prix par tranche handicapé',
                            prefixIcon: Icon(Icons.money_off),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer le prix par tranche handicapé';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              _prixParTrancheHandi = int.parse(value!),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final User? user = _auth.currentUser;
                                final String? userId = user?.uid;
                                final int placesDisponible = _capacite;
                                await _firestore.collection('parking').add({
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
                                  'prixParTranche': _prixParTranche,
                                  'prixParTrancheHandi': _prixParTrancheHandi,
                                  'distance': 0, // Ajout de l'attribut distance
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

void main() {
  runApp(MaterialApp(
    home: AjouterParkingPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
    ),
  ));
}

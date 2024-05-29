import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierParkingPage extends StatefulWidget {
  final DocumentSnapshot document;

  ModifierParkingPage({required this.document});

  @override
  _ModifierParkingPageState createState() => _ModifierParkingPageState();
}

class _ModifierParkingPageState extends State<ModifierParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _nom, _place, _latitude, _longitude, _idAdmin;
  late int _capacite, _distance, _placesDisponible;

  @override
  void initState() {
    super.initState();
    _nom = widget.document['nom'];
    _place = widget.document['place'];
    _capacite = widget.document['capacite'];
    _distance = widget.document['distance'];
    _idAdmin = widget.document['id_admin'];
    _placesDisponible = widget.document['placesDisponible'];
    _latitude = widget.document['position'].latitude.toString();
    _longitude = widget.document['position'].longitude.toString();
  }

  void modifierCapacite(int nouvelleCapacite) {
    // Récupération des valeurs actuelles
    int capaciteActuelle = widget.document['capacite'];
    int placesDisponiblesActuelles = widget.document['placesDisponible'];

    int changement = nouvelleCapacite - capaciteActuelle;

    if (changement > 0) {
      // Augmentation de la capacité
      int nouvellesPlacesDisponibles = placesDisponiblesActuelles + changement;
      _firestore.collection('parkingu').doc(widget.document.id).update({
        'capacite': nouvelleCapacite,
        'placesDisponible': nouvellesPlacesDisponibles,
      });
    } else if (changement < 0) {
      // Diminution de la capacité
      int nouvellesPlacesDisponibles = placesDisponiblesActuelles + changement;
      if (nouvellesPlacesDisponibles < 0) {
        nouvellesPlacesDisponibles = 0;
      }
      _firestore.collection('parkingu').doc(widget.document.id).update({
        'capacite': nouvelleCapacite,
        'placesDisponible': nouvellesPlacesDisponibles,
      });
    } else {
      // Capacité inchangée
      _firestore.collection('parkingu').doc(widget.document.id).update({
        'capacite': nouvelleCapacite,
        'placesDisponible': placesDisponiblesActuelles,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le parking'),
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
                            'Modifier le parking',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          initialValue: _nom,
                          decoration: InputDecoration(
                            labelText: 'Nom du parking :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
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
                          initialValue: _place,
                          decoration: InputDecoration(
                            labelText: 'Place du parking :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer la place du parking';
                            }
                            return null;
                          },
                          onSaved: (value) => _place = value!,
                        ),
                        TextFormField(
                          initialValue: _capacite.toString(),
                          decoration: InputDecoration(
                            labelText: 'Capacité :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: _distance.toString(),
                          decoration: InputDecoration(
                            labelText: 'Distance :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer la distance';
                            }
                            return null;
                          },
                          onSaved: (value) => _distance = int.parse(value!),
                        ),
                        TextFormField(
                          initialValue: _idAdmin,
                          decoration: InputDecoration(
                            labelText: 'ID Admin :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Veuillez entrer l\'ID de l\'administrateur';
                            }
                            return null;
                          },
                          onSaved: (value) => _idAdmin = value!,
                        ),
                        TextFormField(
                          initialValue: _placesDisponible.toString(),
                          decoration: InputDecoration(
                            labelText: 'Places disponibles :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: _latitude,
                          decoration: InputDecoration(
                            labelText: 'Latitude :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
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
                          initialValue: _longitude,
                          decoration: InputDecoration(
                            labelText: 'Longitude :',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
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
                        SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _firestore
                                    .collection('parkingu')
                                    .doc(widget.document.id)
                                    .update({
                                  'nom': _nom,
                                  'place': _place,
                                  'distance': _distance,
                                  'id_admin': _idAdmin,
                                  'position': GeoPoint(
                                    double.parse(_latitude),
                                    double.parse(_longitude),
                                  ),
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Modifier'),
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

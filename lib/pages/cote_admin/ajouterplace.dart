import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AjouterPlacePage extends StatefulWidget {
  @override
  _AjouterPlacePageState createState() => _AjouterPlacePageState();
}

class _AjouterPlacePageState extends State<AjouterPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedParkingId;
  String? _selectedType;
  List<String> _parkingNames = [];
  List<String> _placeTypes = ['standard', 'handicapé'];
  Map<String, String> _parkingIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchParkingNamesAndIds();
  }

  Future<void> _fetchParkingNamesAndIds() async {
    QuerySnapshot querySnapshot = await _firestore.collection('parkingu').get();
    List<String> parkingNames = [];
    Map<String, String> parkingIdMap = {};
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      String parkingName = document['nom'];
      String parkingId = document.id;
      parkingNames.add(parkingName);
      parkingIdMap[parkingName] = parkingId;
    }
    setState(() {
      _parkingNames = parkingNames;
      _parkingIdMap = parkingIdMap;
    });
  }

  Future<String> _generateCustomId() async {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    Random random = Random();

    while (true) {
      String letter = letters[random.nextInt(letters.length)];
      String number = numbers[random.nextInt(numbers.length)];
      String customId = '$letter$number';

      // Check if the ID already exists in the collection
      QuerySnapshot querySnapshot = await _firestore
          .collection('placeU')
          .where('id', isEqualTo: customId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return customId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une place'),
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
          // Formulaire
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
                            'Ajouter une place',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sélectionnez un parking : ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedParkingId,
                          onChanged: (value) {
                            setState(() {
                              _selectedParkingId = value;
                            });
                          },
                          items: _parkingNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: _parkingIdMap[name],
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Sélectionnez le type de place :',
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
                        SizedBox(height: 24.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _addPlace();
                              }
                            },
                            child: Text(
                              'Ajouter',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
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

  Future<void> _addPlace() async {
    // Generate a custom ID
    String customId = await _generateCustomId();

    // Add the new place to the 'placeU' collection with the custom ID
    await _firestore.collection('placeU').doc(customId).set({
      'id': customId,
      'id_parking': _selectedParkingId,
      'type': _selectedType,
    });

    // Get the reference to the 'parkingu' document with the selected parking ID
    DocumentReference parkingRef =
        _firestore.collection('parkingu').doc(_selectedParkingId);

    // Get the current values of 'capacite' and 'placesDisponible' for the selected parking
    DocumentSnapshot parkingSnapshot = await parkingRef.get();
    int currentCapacite = parkingSnapshot.get('capacite') ?? 0;
    int currentPlacesDisponibles = parkingSnapshot.get('placesDisponible') ?? 0;

    // Increment the 'capacite' value
    int newCapacite = currentCapacite + 1;

    // Calculate the new value of 'placesDisponible'
    int newPlacesDisponibles = currentPlacesDisponibles + 1;

    // Update the 'parkingu' document with the new 'capacite' and 'placesDisponible' values
    await parkingRef.update({
      'capacite': newCapacite,
      'placesDisponible': newPlacesDisponibles,
    });

    // Show the confirmation dialog
    _showConfirmationDialog(customId);
  }

  void _showConfirmationDialog(String customId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 30,
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
                SizedBox(height: 20),
                Text(
                  'La place $customId a été ajoutée avec succès',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      Navigator.pop(context);
    });
  }
}

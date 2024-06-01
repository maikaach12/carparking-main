import 'dart:js';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupprimerParkingPage extends StatelessWidget {
  final DocumentSnapshot document;
  SupprimerParkingPage({required this.document});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer le parking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer le parking "${document['nom']}" ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _deleteParking(document);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteParking(DocumentSnapshot document) async {
    final parkingId = document.id;

    // Delete the parking document
    await _firestore.collection('parking').doc(parkingId).delete();

    // Delete related documents from the 'place' collection
    final placesQuery = await _firestore
        .collection('place')
        .where('id_parking', isEqualTo: parkingId)
        .get();
    for (var doc in placesQuery.docs) {
      await _firestore.collection('place').doc(doc.id).delete();
    }

    // Delete related documents from the 'reservation' collection
    final reservationsQuery = await _firestore
        .collection('reservation')
        .where('idParking', isEqualTo: parkingId)
        .get();
    for (var doc in reservationsQuery.docs) {
      await _firestore.collection('reservation').doc(doc.id).delete();
    }

    // Navigate back to the GererParkingPage after deletion
    Navigator.of(context as BuildContext).pop(); // Close the current page
    Navigator.pushReplacementNamed(context as BuildContext, '/gererParking');
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AjouterParkingPage.dart';
import 'ModifierParkingPage.dart';

class GererParkingPage extends StatefulWidget {
  @override
  _GererParkingPageState createState() => _GererParkingPageState();
}

class _GererParkingPageState extends State<GererParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteParking(DocumentSnapshot document) async {
    final parkingId = document.id;

    // Delete the parking document
    await _firestore.collection('parkingu').doc(parkingId).delete();

    // Delete related documents from the 'placeU' collection
    final placesQuery = await _firestore
        .collection('placeU')
        .where('id_parking', isEqualTo: parkingId)
        .get();
    for (var doc in placesQuery.docs) {
      await _firestore.collection('placeU').doc(doc.id).delete();
    }

    // Delete related documents from the 'reservationU' collection
    final reservationsQuery = await _firestore
        .collection('reservationU')
        .where('idParking', isEqualTo: parkingId)
        .get();
    for (var doc in reservationsQuery.docs) {
      await _firestore.collection('reservationU').doc(doc.id).delete();
    }

    // Show a snackbar or other UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Parking supprimé avec succès')),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le parking "${document['nom']}"?',
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteParking(document);
                Navigator.of(context).pop();
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gérer Parking',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('parkingu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Aucun parking trouvé'));
            }
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  color: Colors.white.withOpacity(0.95),
                  child: ListTile(
                    title: Text(
                      document['nom'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Places : ${document['place']}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(document['nom']),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Capacité: ${document['capacite']}'),
                                Text('Distance: ${document['distance']}'),
                                Text('ID Admin: ${document['id_admin']}'),
                                Text('Places: ${document['place']}'),
                                Text(
                                    'Places Disponibles: ${document['placesDisponible']}'),
                                Text(
                                    'Position: ${document['position'].toString()}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Fermer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModifierParkingPage(document: document),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(context, document);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjouterParkingPage()),
          );
        },
        child: Icon(
          Icons.add,
          size: 35,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GererParkingPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
  ));
}

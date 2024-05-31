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
    await _firestore.collection('parking').doc(parkingId).delete();

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
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/images/blue.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gérer Parking',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('parking').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucun parking trouvé',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 5.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.directions_car),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Capacité: ${document['capacite']}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Distance: ${document['distance']}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.person),
                                              SizedBox(width: 8),
                                              Text(
                                                  'ID Admin: ${document['id_admin']}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.place),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Places: ${document['place']}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.event_seat),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Places Disponibles: ${document['placesDisponible']}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.map),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Position: ${document['position'].toString()}'),
                                            ],
                                          ),
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
                                              ModifierParkingPage(
                                                  document: document),
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
              ),
            ],
          ),
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
            color: Colors.white,
          ),
          backgroundColor: Colors.teal,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GererParkingPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
    ),
  ));
}

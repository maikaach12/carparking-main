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
  late TextEditingController _searchController;
  List<DocumentSnapshot> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchParking(String searchQuery) async {
    if (searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    QuerySnapshot parkingSnapshot = await _firestore
        .collection('parking')
        .where('nom', isEqualTo: searchQuery)
        .get();

    setState(() {
      _searchResults = parkingSnapshot.docs;
    });
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
    return Scaffold(
      backgroundColor: Colors
          .lightBlue[50], // Définit la couleur de l'arrière-plan en bleu clair
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par nom de parking',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                _searchParking(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('parking').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = _searchResults.isNotEmpty
                      ? _searchResults
                      : snapshot.data!.docs;
                  if (documents.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun parking trouvé',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = documents[index];
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
                                          Icon(Icons.place),
                                          SizedBox(width: 8),
                                          Text('Places: ${document['place']}'),
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
                                      builder: (context) => ModifierParkingPage(
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
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
    ),
  ));
}

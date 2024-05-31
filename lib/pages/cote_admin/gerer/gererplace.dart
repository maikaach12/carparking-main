import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ajouterplace.dart';
import 'modifierplace.dart';

class GererPlacePage extends StatefulWidget {
  @override
  _GererPlacePageState createState() => _GererPlacePageState();
}

class _GererPlacePageState extends State<GererPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;
  List<DocumentSnapshot> _searchResults = [];
  QuerySnapshot? _snapshot;

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

  Future<void> _searchParkingOrPlace(String searchQuery) async {
    if (searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Try searching by place ID
    QuerySnapshot placeSnapshot = await _firestore
        .collection('placeU')
        .where(FieldPath.documentId, isEqualTo: searchQuery)
        .get();

    if (placeSnapshot.docs.isNotEmpty) {
      setState(() {
        _searchResults = placeSnapshot.docs;
      });
    } else {
      // If no place is found by ID, search by parking name
      QuerySnapshot parkingSnapshot = await _firestore
          .collection('parking')
          .where('nom', isEqualTo: searchQuery)
          .get();

      if (parkingSnapshot.docs.isNotEmpty) {
        String parkingId = parkingSnapshot.docs.first.id;
        QuerySnapshot placeSnapshotByParking = await _firestore
            .collection('placeU')
            .where('id_parking', isEqualTo: parkingId)
            .get();
        setState(() {
          _searchResults = placeSnapshotByParking.docs;
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par ID de place ou nom de parking',
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
                _searchParkingOrPlace(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('placeU').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _snapshot = snapshot.data;
                  return ListView.builder(
                    itemCount: _searchResults.isNotEmpty
                        ? _searchResults.length
                        : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = _searchResults.isNotEmpty
                          ? _searchResults[index]
                          : snapshot.data!.docs[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${document.id}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID Parking: ${document['id_parking']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (document['type'] == 'handicapé')
                                              Icon(Icons.accessible,
                                                  color: Colors.blue),
                                            if (document['type'] == 'standard')
                                              Icon(Icons.directions_car,
                                                  color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              'Type: ${document['type']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ModifierPlacePage(
                                              document: document,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmation'),
                                              content: Text(
                                                  'Êtes-vous sûr de vouloir supprimer cette place?'),
                                              backgroundColor: Colors.white,
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Annuler',
                                                      style: TextStyle(
                                                          color: Colors.blue)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deletePlace(document);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Supprimer',
                                                      style: TextStyle(
                                                          color: Colors.blue)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
            MaterialPageRoute(builder: (context) => AjouterPlacePage()),
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

  Future<void> _deletePlace(DocumentSnapshot document) async {
    DocumentReference parkingRef =
        _firestore.collection('parking').doc(document['id_parking']);

    DocumentSnapshot parkingSnapshot = await parkingRef.get();
    int currentCapacite = parkingSnapshot.get('capacite') ?? 0;
    int currentPlacesDisponibles = parkingSnapshot.get('placesDisponible') ?? 0;

    int newCapacite = currentCapacite - 1;

    int newPlacesDisponibles = currentPlacesDisponibles - 1;
    if (newPlacesDisponibles < 0) {
      newPlacesDisponibles = 0;
    }

    await parkingRef.update({
      'capacite': newCapacite,
      'placesDisponible': newPlacesDisponibles,
    });

    await _firestore.collection('placeU').doc(document.id).delete();

    QuerySnapshot reservations = await _firestore
        .collection('reservationU')
        .where('idPlace', isEqualTo: document.id)
        .get();

    for (DocumentSnapshot reservation in reservations.docs) {
      await _firestore.collection('reservationU').doc(reservation.id).delete();
    }
  }
}

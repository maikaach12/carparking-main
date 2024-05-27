import 'package:carparking/pages/cote_admin/ajouterplace.dart';
import 'package:carparking/pages/cote_admin/modifierplace.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GererPlacePage extends StatefulWidget {
  @override
  _GererPlacePageState createState() => _GererPlacePageState();
}

class _GererPlacePageState extends State<GererPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer Place'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AjouterPlacePage()),
                );
              },
              child: Text('Ajouter une place'),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('placeU').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling for the inner ListView
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text('ID: ${document.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID Parking: ${document['id_parking']}'),
                            Text('Type: ${document['type']}'),
                          ],
                        ),
                        onTap: () {
                          // Show additional details or navigate to another page
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ModifierPlacePage(document: document),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmation'),
                                      content: Text(
                                          'Êtes-vous sûr de vouloir supprimer cette place?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deletePlace(document);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Supprimer'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePlace(DocumentSnapshot document) async {
    // Delete the place
    await _firestore.collection('placeU').doc(document.id).delete();

    // Get all reservations with the place's ID
    QuerySnapshot reservations = await _firestore
        .collection('reservationU')
        .where('idPlace', isEqualTo: document.id)
        .get();

    // Delete each reservation
    for (DocumentSnapshot reservation in reservations.docs) {
      await _firestore.collection('reservationU').doc(reservation.id).delete();
    }
  }
}

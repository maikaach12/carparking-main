import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class reservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<reservationPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réservations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher par ID de place ou date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reservationU')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final reservations = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final startTime = (data['debut'] as Timestamp).toDate();
                  final endTime = (data['fin'] as Timestamp).toDate();
                  final now = DateTime.now();
                  final idPlace = data['idPlace'];
                  final searchLower = searchQuery.toLowerCase();
                  return (startTime.isAfter(now) &&
                      endTime.isAfter(now) &&
                      (idPlace.toLowerCase().contains(searchLower) ||
                          startTime.toString().contains(searchLower) ||
                          endTime.toString().contains(searchLower)));
                }).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Reservation(
                    id: doc.id,
                    userId: data['userId'] ?? '',
                    startTime: (data['debut'] as Timestamp).toDate(),
                    endTime: (data['fin'] as Timestamp).toDate(),
                    idPlace: data['idPlace'] ?? '',
                  );
                }).toList();

                if (reservations.isEmpty) {
                  return Center(child: Text('Aucune réservation en cours'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 1,
                    childAspectRatio:
                        2.5, // Augmenter le ratio pour réduire la hauteur
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8), // Réduction du padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, size: 16),
                                SizedBox(
                                    width:
                                        4), // Réduction de l'espacement horizontal
                                Expanded(
                                  child: Text(
                                    reservation.userId,
                                    style: TextStyle(
                                      fontSize:
                                          14, // Réduction de la taille de la police
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    4), // Réduction de l'espacement vertical
                            Row(
                              children: [
                                Icon(Icons.place, size: 16),
                                SizedBox(
                                    width:
                                        4), // Réduction de l'espacement horizontal
                                Expanded(
                                  child: Text(
                                    reservation.idPlace,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    4), // Réduction de l'espacement vertical
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(
                                    width:
                                        4), // Réduction de l'espacement horizontal
                                Expanded(
                                  child: Text(
                                    'Début: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.startTime)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(
                                    width:
                                        4), // Réduction de l'espacement horizontal
                                Expanded(
                                  child: Text(
                                    'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.endTime)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.blue, size: 20),
                                onPressed: () {
                                  _showNotificationForm(reservation.userId);
                                  FirebaseFirestore.instance
                                      .collection('reservationU')
                                      .doc(reservation.id)
                                      .delete(); // Supprimer la réservation de la collection reservationU

                                  // Supprimer la réservation du tableau "reservations" dans le document de la place
                                  _deleteReservationFromPlace(reservation);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationForm(String userId) {
    TextEditingController typeController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    // Remplir le champ userId avec la valeur fournie
    TextEditingController userIdController =
        TextEditingController(text: userId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nouvelle notification'),
          backgroundColor:
              Colors.white, // Couleur de fond de la boîte de dialogue
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                enabled:
                    false, // Empêcher l'utilisateur de modifier le champ userId
                decoration: InputDecoration(labelText: 'UserID'),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                    color: Colors.blue), // Couleur du texte du bouton Annuler
              ),
            ),
            TextButton(
              onPressed: () {
                String type = typeController.text;
                String description = descriptionController.text;
                _sendNotification(userId, type, description);
                // Vous pouvez également ajouter ici le code pour annuler la réservation
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                    color: Colors.blue), // Couleur du texte du bouton OK
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendNotification(String userId, String type, String description) {
    // Enregistrer les données dans la collection 'notifications' de Firestore
    FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': type,
      'description': description,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

  Future<void> _deleteReservationFromPlace(Reservation reservation) async {
    // Obtenir l'ID de la place associée à la réservation
    final idPlace = reservation.idPlace;

    // Récupérer le document de la place depuis la collection "placeU"
    final placeDoc = await FirebaseFirestore.instance
        .collection('placeU')
        .doc(idPlace)
        .get();

    // Mettre à jour le tableau "reservations" en supprimant la réservation annulée
    if (placeDoc.exists) {
      final reservations = placeDoc.data()?['reservations'] ?? [];
      final updatedReservations = reservations.where((res) {
        final resDebut = (res['debut'] as Timestamp).toDate();
        final resFin = (res['fin'] as Timestamp).toDate();
        return !(resDebut == reservation.startTime &&
            resFin == reservation.endTime);
      }).toList();

      await FirebaseFirestore.instance
          .collection('placeU')
          .doc(idPlace)
          .update({'reservations': updatedReservations});
    }
  }
}

class Reservation {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String idPlace;

  Reservation({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.idPlace,
  });

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      userId: data['userId'] ?? '',
      startTime: (data['debut'] as Timestamp).toDate(),
      endTime: (data['fin'] as Timestamp).toDate(),
      idPlace: data['idPlace'] ?? '',
    );
  }
}

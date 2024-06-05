import 'package:carparking/pages/cote_user/modifier_reservation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MesReservationsPage extends StatefulWidget {
  @override
  _MesReservationsPageState createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  String _getReservationStatus(
      Timestamp debutTimestamp, Timestamp finTimestamp, String etat) {
    if (etat == 'Annulée') {
      return 'Annulée';
    }

    DateTime currentTime = DateTime.now();
    DateTime debutTime = debutTimestamp.toDate();
    DateTime finTime = finTimestamp.toDate();

    if (currentTime.isBefore(debutTime) ||
        currentTime.isAtSameMomentAs(debutTime)) {
      return 'En cours';
    } else if (currentTime.isAfter(finTime)) {
      return 'Terminé';
    } else {
      return 'En cours';
    }
  }

  Future<void> _supprimerReservation(String reservationId) async {
    try {
      // Supprimer la réservation de Firestore
      await FirebaseFirestore.instance
          .collection('reservation')
          .doc(reservationId)
          .delete();

      // Mettre à jour l'interface utilisateur en supprimant la réservation de la liste
      setState(() {});
    } catch (e) {
      print('Erreur lors de la suppression de la réservation : $e');
    }
  }

  Future<void> _annulerReservation(String reservationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservation')
          .doc(reservationId)
          .update({'etat': 'Annulée'});

      // Afficher un message de confirmation d'annulation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation annulée avec succès'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {}); // Mettre à jour l'interface utilisateur
    } catch (e) {
      print('Erreur lors de l\'annulation de la réservation : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations', textAlign: TextAlign.center),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Afficher un champ de recherche ou ouvrir une boîte de dialogue pour la recherche
              // Implémentez la logique de recherche ici
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservation')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final reservations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final debutTimestamp = reservation['debut'];
              final finTimestamp = reservation['fin'];
              final idParking = reservation['idParking'];
              final etat = reservation['etat'];
              final reservationStatus =
                  _getReservationStatus(debutTimestamp, finTimestamp, etat);

              // Récupérer le nom du parking à partir de l'ID
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('parking')
                    .doc(idParking)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final parkingData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final nomParking = parkingData['nom'] ?? 'Parking inconnu';
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      color: Colors.white,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      nomParking,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    reservationStatus,
                                    style: TextStyle(
                                      color: reservationStatus == 'En cours'
                                          ? Colors.blue
                                          : (reservationStatus == 'Annulée'
                                              ? Colors.orange
                                              : Colors.red),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Place: ${reservation['idPlace']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'ID Reservation: ${reservation.id}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.blue,
                                    size: 16.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    ' ${DateFormat('dd/MM/yyyy HH:mm').format(debutTimestamp.toDate())}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_off,
                                        color: Colors.red,
                                        size: 16.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        ' ${DateFormat('dd/MM/yyyy HH:mm').format(finTimestamp.toDate())}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                        size: 16.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        reservation['matricule'],
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (reservationStatus == 'En cours')
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ModifierReservationPage(
                                              reservation: reservation,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 97, 154, 210),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Modifier',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        _annulerReservation(reservation.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(55, 125, 196, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Annuler',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (reservationStatus == 'Annulée' ||
                                reservationStatus == 'Terminé')
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: IconButton(
                                    onPressed: () {
                                      _supprimerReservation(reservation.id);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

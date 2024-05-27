import 'package:carparking/pages/cote_user/modifier_reservation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MesReservationsPage extends StatefulWidget {
  MesReservationsPage();

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
      Timestamp debutTimestamp, Timestamp finTimestamp) {
    DateTime currentTime = DateTime.now();
    DateTime debutTime = debutTimestamp.toDate();
    DateTime finTime = finTimestamp.toDate();

    if (currentTime.isBefore(debutTime) ||
        currentTime.isAtSameMomentAs(debutTime)) {
      return 'En cours';
    } else if (currentTime.isAfter(finTime)) {
      return 'Terminé';
    } else {
      return '';
    }
  }

  Future<void> _supprimerReservation(String reservationId) async {
    try {
      // Supprimer la réservation de Firestore
      await _annulerReservation(reservationId, true);

      // Mettre à jour l'interface utilisateur en supprimant la réservation de la liste
      setState(() {});
    } catch (e) {
      print('Erreur lors de la suppression de la réservation : $e');
    }
  }

  Future<void> _annulerReservation(String reservationId, bool supprimer) async {
    // Obtenir les informations de la réservation à annuler
    final reservationDoc = await FirebaseFirestore.instance
        .collection('reservationU')
        .doc(reservationId)
        .get();

    if (reservationDoc.exists) {
      // Récupérer l'ID de la place et l'ID du parking depuis le document de réservation
      final idPlace = reservationDoc.data()?['idPlace'];
      final idParking = reservationDoc.data()?['idParking'];

      // Supprimer la réservation de la collection reservationU
      await FirebaseFirestore.instance
          .collection('reservationU')
          .doc(reservationId)
          .delete();

      // Supprimer la réservation du tableau reservations dans la collection placeU
      if (idPlace != null && idParking != null) {
        final placeDoc = await FirebaseFirestore.instance
            .collection('placeU')
            .doc(idPlace)
            .get();

        if (placeDoc.exists) {
          final reservations = placeDoc.data()?['reservations'] ?? [];
          final updatedReservations = reservations.where((reservation) {
            final debutReservation = reservation['debut'];
            final finReservation = reservation['fin'];
            final reservationDebut = reservationDoc.data()?['debut'];
            final reservationFin = reservationDoc.data()?['fin'];

            return !(debutReservation == reservationDebut &&
                finReservation == reservationFin);
          }).toList();

          await FirebaseFirestore.instance
              .collection('placeU')
              .doc(idPlace)
              .update({'reservations': updatedReservations});
        }
      }

      if (supprimer) {
        // Afficher un message de confirmation de suppression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réservation supprimée avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Afficher un message de confirmation d'annulation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réservation annulée avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
            .collection('reservationU')
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
              final reservationStatus =
                  _getReservationStatus(debutTimestamp, finTimestamp);

              // Récupérer le nom du parking à partir de l'ID
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('parkingu')
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
                        borderRadius: BorderRadius.circular(0.0),
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
                                  Text(
                                    nomParking,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    reservationStatus,
                                    style: TextStyle(
                                      color: reservationStatus == 'En cours'
                                          ? Colors.blue
                                          : Colors.red,
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
                              title: Text(
                                'Début: ${DateFormat('dd/MM/yyyy HH:mm').format(debutTimestamp.toDate())}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(finTimestamp.toDate())}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
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
                                        reservation['matriculeEtMarque'],
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        backgroundColor: const Color.fromRGBO(
                                            25, 118, 210, 1),
                                      ),
                                      child: Text(
                                        'Modifier',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        _annulerReservation(
                                            reservation.id, false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(25, 118, 210, 1),
                                      ),
                                      child: Text(
                                        'Annuler',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (reservationStatus == 'Terminé')
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _supprimerReservation(reservation.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: Text(
                                      'Supprimer',
                                      style: TextStyle(color: Colors.white),
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

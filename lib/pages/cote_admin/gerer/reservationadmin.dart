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
        title: Text('Réservations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reservation')
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
                  return Center(
                      child: Text('Aucune réservation en cours',
                          style: TextStyle(fontSize: 18)));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(reservation.userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final userData = userSnapshot.data!.data()
                            as Map<String, dynamic>?; // This avoids null error
                        final familyName =
                            userData?['familyName'] ?? 'Nom non trouvé';
                        final name = userData?['name'] ?? 'Prénom non trouvé';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: Colors.white,
                          // Suppression de l'ombre
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 20, color: Colors.black),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '$familyName $name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.local_parking_sharp,
                                        size: 20, color: Colors.black),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reservation.idPlace,
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${DateFormat('dd/MM/yyyy HH:mm').format(reservation.startTime)}',
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.timer_off,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${DateFormat('dd/MM/yyyy HH:mm').format(reservation.endTime)}',
                                        style: TextStyle(fontSize: 14),
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
                                        color: Colors.redAccent, size: 24),
                                    onPressed: () {
                                      _showNotificationForm(reservation.userId);
                                      FirebaseFirestore.instance
                                          .collection('reservation')
                                          .doc(reservation.id)
                                          .delete();

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
    TextEditingController userIdController =
        TextEditingController(text: userId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nouvelle notification'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                enabled: false,
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
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                String type = typeController.text;
                String description = descriptionController.text;
                _sendNotification(userId, type, description);
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _sendNotification(String userId, String type, String description) {
    FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': type,
      'description': description,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

  Future<void> _deleteReservationFromPlace(Reservation reservation) async {
    final idPlace = reservation.idPlace;
    final placeDoc =
        await FirebaseFirestore.instance.collection('place').doc(idPlace).get();

    if (placeDoc.exists) {
      final reservations = placeDoc.data()?['reservations'] ?? [];
      final updatedReservations = reservations.where((res) {
        final resDebut = (res['debut'] as Timestamp).toDate();
        final resFin = (res['fin'] as Timestamp).toDate();
        return !(resDebut == reservation.startTime &&
            resFin == reservation.endTime);
      }).toList();

      await FirebaseFirestore.instance
          .collection('place')
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

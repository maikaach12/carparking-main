import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ModifierReservationPage extends StatefulWidget {
  final DocumentSnapshot reservation;

  ModifierReservationPage({required this.reservation});

  @override
  _ModifierReservationPageState createState() =>
      _ModifierReservationPageState();
}

class _ModifierReservationPageState extends State<ModifierReservationPage> {
  late TextEditingController _matriculeEtMarqueController;
  late TextEditingController _typePlaceController;
  late TextEditingController _debutController;
  late TextEditingController _finController;
  late DateTime _debutReservation;
  late DateTime _finReservation;

  @override
  void initState() {
    super.initState();
    _debutReservation = widget.reservation['debut'].toDate();
    _finReservation = widget.reservation['fin'].toDate();
    _matriculeEtMarqueController =
        TextEditingController(text: widget.reservation['matriculeEtMarque']);
    _typePlaceController =
        TextEditingController(text: widget.reservation['typePlace']);
    _debutController = TextEditingController(
        text: DateFormat('dd/MM/yyyy HH:mm').format(_debutReservation));
    _finController = TextEditingController(
        text: DateFormat('dd/MM/yyyy HH:mm').format(_finReservation));
  }

  Future<bool> checkPlaceAvailability() async {
    // Récupérer toutes les réservations pour vérifier la disponibilité
    QuerySnapshot reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservationU')
        .where('debut', isLessThan: _finReservation)
        .where('fin', isGreaterThan: _debutReservation)
        .get();

    // Exclure la réservation actuelle de la vérification de disponibilité
    return reservationsSnapshot.docs
        .where((doc) => doc.id != widget.reservation.id)
        .isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier la réservation'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/blue.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _debutController,
                      decoration: InputDecoration(
                          labelText:
                              'Début de la réservation (jj/mm/aaaa HH:mm)'),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _debutReservation,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(_debutReservation),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _debutReservation = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              _debutController.text =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_debutReservation);
                            });
                          }
                        }
                      },
                    ),
                    TextField(
                      controller: _finController,
                      decoration: InputDecoration(
                          labelText:
                              'Fin de la réservation (jj/mm/aaaa HH:mm)'),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _finReservation,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(_finReservation),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _finReservation = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              _finController.text =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_finReservation);
                            });
                          }
                        }
                      },
                    ),
                    TextField(
                      controller: _matriculeEtMarqueController,
                      decoration:
                          InputDecoration(labelText: 'Matricule et Marque'),
                    ),
                    TextField(
                      controller: _typePlaceController,
                      decoration: InputDecoration(labelText: 'Type de place'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Vérifier la disponibilité des places dans Firestore
                        checkPlaceAvailability().then((isAvailable) {
                          if (isAvailable) {
                            // Mettre à jour la réservation dans Firestore
                            FirebaseFirestore.instance
                                .collection('reservationU')
                                .doc(widget.reservation.id)
                                .update({
                              'debut': Timestamp.fromDate(_debutReservation),
                              'fin': Timestamp.fromDate(_finReservation),
                              'matriculeEtMarque':
                                  _matriculeEtMarqueController.text,
                              'typePlace': _typePlaceController.text,
                              // Mettre à jour d'autres champs si nécessaire
                            }).then((_) {
                              // Revenir à la page précédente après la modification
                              Navigator.pop(context);
                            }).catchError((error) {
                              // Gérer les erreurs éventuelles
                              print(
                                  'Erreur lors de la modification de la réservation : $error');
                            });
                          } else {
                            // Afficher un message d'erreur à l'utilisateur
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Erreur'),
                                  content: Text(
                                      'La place est déjà réservée pour cette période.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      child: Text('Enregistrer les modifications'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _matriculeEtMarqueController.dispose();
    _typePlaceController.dispose();
    _debutController.dispose();
    _finController.dispose();
    super.dispose();
  }
}

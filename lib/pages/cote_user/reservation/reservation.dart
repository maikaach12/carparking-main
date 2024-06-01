import 'dart:async';
import 'dart:math' as math;

import 'package:carparking/pages/cote_user/MesReservationsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final String parkingId;
  ReservationPage({required this.parkingId});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  Timestamp? _debutReservation;
  Timestamp? _finReservation;
  String _typePlace = 'standard';
  String? reservationId;
  String _matriculeEtMarque = '';
  List<bool> _isSelected = [
    true,
    false
  ]; // Initialisé pour sélectionner "Standard" par défaut

  Future<void> _selectDebutReservation(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.grey.shade800,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child ?? const SizedBox(),
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _debutReservation = Timestamp.fromDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  Future<void> _selectFinReservation(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _debutReservation?.toDate() ?? DateTime.now(),
      firstDate: _debutReservation?.toDate() ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                onSurface: Colors.grey.shade800,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child ?? const SizedBox(),
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _finReservation = Timestamp.fromDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  Future<void> _reserverPlace() async {
    String? placesAttribueId;

    try {
      // Get the parking document from the 'parkingu' collection
      final parkingDoc = await FirebaseFirestore.instance
          .collection('parking')
          .doc(widget.parkingId)
          .get();

      // Check if the parking document exists and has available spots
      if (parkingDoc.exists && parkingDoc.data()!['placesDisponible'] > 0) {
        // Get the current user ID
        String? userId = FirebaseAuth.instance.currentUser?.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('place')
            .where('id_parking', isEqualTo: widget.parkingId)
            .where('type', isEqualTo: _typePlace)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          bool chevauchementTotal = false;
          bool reservationEffectuee = false;

          for (final placesDoc in querySnapshot.docs) {
            placesAttribueId = placesDoc.id;

            final reservationsExistantes =
                placesDoc.data()['reservations'] ?? [];
            chevauchementTotal = false;
            for (final reservation in reservationsExistantes) {
              final debutExistante = reservation['debut'] != null
                  ? reservation['debut'].toDate()
                  : null;
              final finExistante = reservation['fin'] != null
                  ? reservation['fin'].toDate()
                  : null;
              if (debutExistante == null || finExistante == null) {
                continue;
              }
              if ((_debutReservation!.toDate().isBefore(finExistante) &&
                      _debutReservation!.toDate().isAfter(debutExistante)) ||
                  (_finReservation!.toDate().isBefore(finExistante) &&
                      _finReservation!.toDate().isAfter(debutExistante)) ||
                  (_debutReservation!
                          .toDate()
                          .isAtSameMomentAs(debutExistante) &&
                      _finReservation!
                          .toDate()
                          .isAtSameMomentAs(finExistante)) ||
                  (_debutReservation!.toDate().isBefore(debutExistante) &&
                      _finReservation!.toDate().isAfter(finExistante))) {
                chevauchementTotal = true;
                break;
              }
            }

            if (!chevauchementTotal) {
              await placesDoc.reference.update({
                'reservations': FieldValue.arrayUnion([
                  {
                    'debut': _debutReservation,
                    'fin': _finReservation,
                    'userId': userId, // Add user ID to reservation data
                  }
                ])
              });

              await FirebaseFirestore.instance.collection('reservation').add({
                'idParking': widget.parkingId,
                'debut': _debutReservation,
                'fin': _finReservation,
                'typePlace': _typePlace,
                'idPlace': placesAttribueId,
                'decrementPlacesDisponible': false,
                'userId': userId,
                'matriculeEtMarque': _matriculeEtMarque,
                // Add user ID to reservation data
              }).then((documentRef) async {
                reservationId = documentRef.id;

                // Calculer le prix ici
                final dureeTotale = _finReservation!
                    .toDate()
                    .difference(_debutReservation!.toDate());
                final dureeMinutes = dureeTotale.inMinutes;

                final reservationDoc = await documentRef.get();
                final idPlace = reservationDoc.data()?['idPlace'];

                final placeDoc = await FirebaseFirestore.instance
                    .collection('place')
                    .doc(idPlace)
                    .get();
                final type = placeDoc.data()?['type'];

                final idParking = reservationDoc.data()?['idParking'];
                final parkingDoc = await FirebaseFirestore.instance
                    .collection('parking')
                    .doc(idParking)
                    .get();

                int prixParTranche;
                if (type == 'handicapé' &&
                    parkingDoc.data()?['prixParTrancheHandi'] != null) {
                  prixParTranche = parkingDoc.data()?['prixParTrancheHandi'];
                } else if (type == 'standard' &&
                    parkingDoc.data()?['prixParTranche'] != null) {
                  prixParTranche = parkingDoc.data()?['prixParTranche'];
                } else {
                  print(
                      'Le document de parking ne contient pas le prix par tranche approprié');
                  return;
                }

                final nombreTranches = (dureeMinutes / 10).ceil();
                final prix = (nombreTranches * prixParTranche).toInt();

                await documentRef.update({'prix': prix});

                setState(() {});

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Réservation effectuée',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      content: Text(
                        'Votre réservation a été effectuée avec succès. La place attribuée est : $placesAttribueId \n\nPrix à payer : $prix DA',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to MesReservationsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MesReservationsPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Mes reservation',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                reservationEffectuee = true;

                return;
              });
            }
            if (reservationEffectuee) {
              break;
            }
          }

          if (!reservationEffectuee) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Erreur'),
                  content: Text(
                      'Désolé, aucune place n\'est actuellement disponible pour la période sélectionnée sans chevauchement de réservation'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erreur'),
                content: Text('Aucune place de type "$_typePlace" disponible'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Gérer l'erreur ici
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content:
                Text('Une erreur s\'est produite lors de la réservation : $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _gererPlacesDisponibles() async {
    try {
      // Obtenir l'heure actuelle

      DateTime currentTime = DateTime.now().toUtc();
      print('Heure actuelle: $currentTime');

      // Interroger les réservations en cours
      QuerySnapshot ongoingReservations = await FirebaseFirestore.instance
          .collection('reservation')
          .where('debut', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
          .where('fin', isGreaterThan: Timestamp.fromDate(currentTime))
          .get();

      // Obtenir le nombre de réservations en cours
      int ongoingReservationsCount = ongoingReservations.docs.length;
      print('Nombre de réservations en cours: $ongoingReservationsCount');
      // Obtenir le document de parking de la collection parkingu
      final parkingDoc = await FirebaseFirestore.instance
          .collection('parking')
          .doc(widget.parkingId)
          .get();

      // Vérifier si le document existe et a une valeur de capacite
      if (parkingDoc.exists && parkingDoc.data()!.containsKey('capacite')) {
        int capacite = parkingDoc.data()!['capacite'];
        print('Capacité de parking: $capacite');
        int placesDisponible = capacite - ongoingReservationsCount;
        print('Nombre de places disponibles: $placesDisponible');

        // Mettre à jour placesDisponible
        await FirebaseFirestore.instance
            .collection('parking')
            .doc(widget.parkingId)
            .update({
          'placesDisponible': placesDisponible,
        });
        print(
            'Mise à jour réussie: placesDisponible mise à jour à $placesDisponible');
      }
    } catch (e) {
      print('Erreur lors de la gestion des places disponibles: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(minutes: 1), (timer) {
      _gererPlacesDisponibles();
    });
  }

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(children: [
      Positioned(
        top: -0.2 * screenHeight,
        left: -0.2 * screenWidth,
        child: topWidget(screenWidth),
      ),
      Positioned(
        bottom: -0.4 * screenHeight,
        right: -0.4 * screenWidth,
        child: bottomWidget(screenWidth),
      ),
      Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'lib/images/blue.png'), // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 250, 248, 248),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    FittedBox(
                      child: Text(
                        "Parking.dz",
                        style: GoogleFonts.montserrat(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FittedBox(
                      child: Text(
                        "Réserver une place",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Début de la réservation',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectDebutReservation(context),
                                    child: Text(
                                      _debutReservation != null
                                          ? DateFormat('dd/MM/yyyy HH:mm')
                                              .format(
                                                  _debutReservation!.toDate())
                                          : 'Sélectionner la date',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(33, 150, 243, 1)
                                              .withOpacity(0.5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Fin de la réservation',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectFinReservation(context),
                                    child: Text(
                                      _finReservation != null
                                          ? DateFormat('dd/MM/yyyy HH:mm')
                                              .format(_finReservation!.toDate())
                                          : 'Sélectionner la date',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Type de place',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ToggleButtons(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'Standard',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'Handicapé',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                    isSelected: _isSelected,
                                    onPressed: (int index) {
                                      setState(() {
                                        for (int buttonIndex = 0;
                                            buttonIndex < _isSelected.length;
                                            buttonIndex++) {
                                          if (buttonIndex == index) {
                                            _isSelected[buttonIndex] = true;
                                            _typePlace = buttonIndex == 0
                                                ? 'standard'
                                                : 'handicapé';
                                          } else {
                                            _isSelected[buttonIndex] = false;
                                          }
                                        }
                                      });
                                    },
                                    renderBorder: false,
                                    selectedColor: Colors.blue.withOpacity(0.5),
                                    fillColor: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText:
                                          'Matricule et Marque (ex: 123543 - Peugeot 208)',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _matriculeEtMarque = value;
                                      });
                                    },
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _reserverPlace();
                                  }
                                },
                                child: Text(
                                  'Réserver',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.withOpacity(0.5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ]))
                  ])))))
    ]));
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:carparking/pages/cote_user/MesReservationsPage.dart';
import 'package:carparking/pages/cote_user/reservation/price.dart';

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
  String? _selectedMatricule;
  List<String> _matricules = [];
  List<bool> _isSelected = [
    true,
    false
  ]; // Initialisé pour sélectionner "Standard" par défaut
  int? _prixCalcule; // Variable pour stocker le prix calculé
  int _prix = 0;

  Future<void> _calculerPrix(
      String reservationId, Timestamp debut, Timestamp fin) async {
    final dureeTotale = fin.toDate().difference(debut.toDate());
    final dureeMinutes = dureeTotale.inMinutes;

    print('Durée totale en minutes: $dureeMinutes');

    // Récupérer le document de réservation à partir de l'idReservation
    final reservationDoc = await FirebaseFirestore.instance
        .collection('reservationU')
        .doc(reservationId)
        .get();

    if (reservationDoc.exists) {
      print('Document de réservation trouvé');
    } else {
      print('Document de réservation non trouvé');
    }

    // Vérifier si le document de réservation existe et contient idPlace
    if (reservationDoc.exists &&
        reservationDoc.data()!.containsKey('idPlace')) {
      final idPlace = reservationDoc.data()!['idPlace'];

      print('ID de la place: $idPlace');

      // Récupérer le document de place à partir de l'idPlace
      final placeDoc = await FirebaseFirestore.instance
          .collection('placeU')
          .doc(idPlace)
          .get();

      if (placeDoc.exists) {
        print('Document de place trouvé');
      } else {
        print('Document de place non trouvé');
      }

      // Vérifier si le document de place existe et contient type
      if (placeDoc.exists && placeDoc.data()!.containsKey('type')) {
        final type = placeDoc.data()!['type'];
        print('Type de place: $type');

        // Récupérer le document de parking associé à partir de l'idParking
        final idParking = reservationDoc.data()!['idParking'];
        final parkingDoc = await FirebaseFirestore.instance
            .collection('parking')
            .doc(idParking)
            .get();

        if (parkingDoc.exists) {
          print('Document de parking trouvé');
        } else {
          print('Document de parking non trouvé');
        }

        if (parkingDoc.exists) {
          int prixParTranche;
          if (type == 'handicapé' &&
              parkingDoc.data()!.containsKey('prixParTrancheHandi')) {
            prixParTranche = parkingDoc.data()!['prixParTrancheHandi'];
            print('Prix par tranche (handicapé): $prixParTranche');
          } else if (type == 'standard' &&
              parkingDoc.data()!.containsKey('prixParTranche')) {
            prixParTranche = parkingDoc.data()!['prixParTranche'];
            print('Prix par tranche (standard): $prixParTranche');
          } else {
            print(
                'Le document de parking ne contient pas le prix par tranche approprié');
            return;
          }

          final nombreTranches = (dureeMinutes / 10).ceil();
          print('Nombre de tranches: $nombreTranches');

          setState(() {
            _prix = (nombreTranches * prixParTranche).toInt();
          });
          setState(() {
            _prixCalcule = _prix;
          });
          print('Prix calculé: $_prix');

          // Mettre à jour le prix dans le document de réservation
          await FirebaseFirestore.instance
              .collection('reservationU')
              .doc(reservationId)
              .update({'prix': _prix});
        } else {
          print(
              'Le document de parking ne contient pas prixParTranche ou prixParTrancheHandi');
        }
      } else {
        print('Le document de place ne contient pas type');
      }
    } else {
      print('Le document de réservation ne contient pas idPlace');
    }
  }

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

  Future<void> _fetchMatricules() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matricule')
          .where('userId', isEqualTo: userId)
          .get();
      _matricules =
          querySnapshot.docs.map((doc) => doc.id).toList().cast<String>();
    }
    setState(() {});
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
      // Get the parking document from the 'parking' collection
      final parkingDoc = await FirebaseFirestore.instance
          .collection('parking')
          .doc(widget.parkingId)
          .get();

      // Check if the parking document exists
      if (parkingDoc.exists) {
        // Get the current user ID
        String? userId = FirebaseAuth.instance.currentUser?.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('placeU')
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

              await FirebaseFirestore.instance.collection('reservationU').add({
                'idParking': widget.parkingId,
                'debut': _debutReservation,
                'fin': _finReservation,
                'typePlace': _typePlace,
                'idPlace': placesAttribueId,
                'decrementPlacesDisponible': false, // Ajout de ce paramètre
                'userId': userId,
              }).then((documentRef) {
                reservationId = documentRef.id;
                _calculerPrix(
                        reservationId!, _debutReservation!, _finReservation!)
                    .then((_) {
                  setState(() {});

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        content: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                      size: 80.0,
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Votre place $placesAttribueId de parking a bien été réservé !',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    if (_prixCalcule != null)
                                      Text(
                                        'Prix à payer : ${_prixCalcule} DA',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Retrouvez les détails de votre réservation sur votre page "Mes réservations"',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0),
                              if (_prixCalcule != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      /*  Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                            //  PaiementOnlinePage(),
                                        ),
                                      );*/
                                    },
                                    child: Text('Payer'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  reservationEffectuee = true;

                  return;
                });
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
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 80.0,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Désolé, aucune place n\'est actuellement disponible pour la période sélectionnée ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 80.0,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Aucune place de type "$_typePlace" disponible',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
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
          .collection('reservationU')
          .where('debut', isLessThanOrEqualTo: Timestamp.fromDate(currentTime))
          .where('fin', isGreaterThan: Timestamp.fromDate(currentTime))
          .get();

      // Obtenir le nombre de réservations en cours
      int ongoingReservationsCount = ongoingReservations.docs.length;
      print('Nombre de réservations en cours: $ongoingReservationsCount');

      // Obtenir le document de parking de la collection parking
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

  ///
//

  @override
  void initState() {
    super.initState();
    _fetchMatricules();
    Timer.periodic(Duration(seconds: 1), (timer) {
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
                'lib/images/blue.png',
              ), // Replace with your background image path
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
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedMatricule,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedMatricule = value;
                                      });
                                    },
                                    items: _matricules.isNotEmpty
                                        ? _matricules.map((matriculeId) {
                                            return DropdownMenuItem<String>(
                                              value: matriculeId,
                                              child: Text(matriculeId),
                                            );
                                          }).toList()
                                        : [
                                            DropdownMenuItem<String>(
                                              value: null,
                                              child: Text(
                                                  'Aucune matricule disponible'),
                                            ),
                                          ],
                                    decoration: InputDecoration(
                                      labelText: 'Sélectionnez une matricule',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              if (_prixCalcule != null) SizedBox(height: 20),
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

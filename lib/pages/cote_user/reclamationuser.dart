import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationPage extends StatefulWidget {
  final String userId;

  ReclamationPage({required this.userId});

  @override
  _ReclamationPageState createState() => _ReclamationPageState();
}

class _ReclamationPageState extends State<ReclamationPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final Map<String, List<String>> typeProblemDescriptions = {
    'Place réservée non disponible': [
      "Ma place réservée est occupée.",
    ],
    'Problème de paiement': [
      "Erreur lors de la transaction de paiement.",
      "Paiement refusé sans raison apparente.",
      "Double débit sur la carte de crédit.",
      "Impossible de finaliser la transaction."
    ],
    'Problème de sécurité': [
      "Éclairage insuffisant dans le parking.",
      "Absence de caméras de surveillance.",
      "Présence de personnes suspectes dans le parking.",
      "Portes d'accès non sécurisées ou endommagées."
    ],
    'Difficulté daccès': [
      "Congestion du trafic à l'entrée du parking.",
      "Feux de signalisation défectueux.",
      "Entrée bloquée par des travaux de construction.",
      "Problèmes de circulation interne dans le parking."
    ],
    'Problème de réservation de handicap': [
      "Place de parking réservée occupée par un véhicule non autorisé.",
      "Absence de signalisation appropriée pour les places handicapées.",
      "Manque de respect des règles de stationnement pour les personnes handicapées.",
      "Difficulté à accéder aux places réservées en raison d'obstacles."
    ],
  };

  String? selectedTypeProblem;
  String? selectedDescription;
  String? otherDescription;
  String? selectedReservation;
  String? selectedMatricule;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<List<String>> getReservationsForUser(String userId) async {
    List<String> reservations = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('reservationU')
        .where('userId', isEqualTo: userId)
        .get();

    snapshot.docs.forEach((doc) {
      reservations.add(doc.id);
    });

    return reservations;
  }

  Future<String> getPlaceNumberFromReservation(String reservationId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('reservationU')
        .doc(reservationId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      if (data != null && data.containsKey('idPlace')) {
        return data['idPlace'];
      }
    }

    return 'Identifiant de place non disponible';
  }

  Future<List<String>> getMatriculesForUser(String userId) async {
    List<String> matricules = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('matricule')
        .where('userId', isEqualTo: userId)
        .get();

    snapshot.docs.forEach((doc) {
      matricules.add(doc.id);
    });

    return matricules;
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
      body: Stack(
        children: [
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
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
            child: Center(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 250, 248, 248),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Sélectionnez le type de réclamation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                                value: selectedTypeProblem,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeProblem = value;
                                    selectedDescription = null;
                                    otherDescription = null;
                                  });
                                },
                                items: typeProblemDescriptions.keys.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16),
                            AnimatedOpacity(
                              opacity: selectedTypeProblem != null ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: selectedTypeProblem != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '2. Sélectionnez une description',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child:
                                              DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            value: selectedDescription,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedDescription = value;
                                                otherDescription = null;
                                              });
                                            },
                                            items: typeProblemDescriptions[
                                                    selectedTypeProblem]!
                                                .map((description) {
                                              return DropdownMenuItem<String>(
                                                value: description,
                                                child: Text(description),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        if (selectedDescription == null)
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: TextField(
                                              onChanged: (value) {
                                                setState(() {
                                                  otherDescription = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                hintText:
                                                    'Entrez une description personnalisée',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 16),
                                        AnimatedOpacity(
                                          opacity: selectedTypeProblem ==
                                                  'Place réservée non disponible'
                                              ? 1.0
                                              : 0.0,
                                          duration: Duration(milliseconds: 300),
                                          child: selectedTypeProblem ==
                                                  'Place réservée non disponible'
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '3. Sélectionnez une réservation',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    FutureBuilder<List<String>>(
                                                      future:
                                                          getReservationsForUser(
                                                              widget.userId),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return CircularProgressIndicator();
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Erreur: ${snapshot.error}');
                                                        } else {
                                                          List<String>?
                                                              reservations =
                                                              snapshot.data;
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                child:
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                  ),
                                                                  value:
                                                                      selectedReservation,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      selectedReservation =
                                                                          value;
                                                                    });
                                                                  },
                                                                  items: reservations
                                                                          ?.map(
                                                                              (reservation) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              reservation,
                                                                          child:
                                                                              Text(reservation),
                                                                        );
                                                                      }).toList() ??
                                                                      [],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              if (selectedReservation !=
                                                                  null)
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    FutureBuilder<
                                                                        String>(
                                                                      future: getPlaceNumberFromReservation(
                                                                          selectedReservation!),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting) {
                                                                          return CircularProgressIndicator();
                                                                        } else if (snapshot
                                                                            .hasError) {
                                                                          return Text(
                                                                              'Erreur: ${snapshot.error}');
                                                                        } else {
                                                                          String
                                                                              placeNumber =
                                                                              snapshot.data!;
                                                                          return Text(
                                                                            'ID de la place : $placeNumber',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.red,
                                                                            ),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    Text(
                                                                      '4. Sélectionnez une matricule',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
                                                                    FutureBuilder<
                                                                        List<
                                                                            String>>(
                                                                      future: getMatriculesForUser(
                                                                          widget
                                                                              .userId),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting) {
                                                                          return CircularProgressIndicator();
                                                                        } else if (snapshot
                                                                            .hasError) {
                                                                          return Text(
                                                                              'Erreur: ${snapshot.error}');
                                                                        } else {
                                                                          List<String>?
                                                                              matricules =
                                                                              snapshot.data;
                                                                          return Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              border: Border.all(
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                DropdownButtonFormField<String>(
                                                                              decoration: InputDecoration(
                                                                                contentPadding: EdgeInsets.symmetric(
                                                                                  horizontal: 16,
                                                                                  vertical: 8,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                              ),
                                                                              value: selectedMatricule,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  selectedMatricule = value;
                                                                                });
                                                                              },
                                                                              items: matricules?.map((matricule) {
                                                                                    return DropdownMenuItem<String>(
                                                                                      value: matricule,
                                                                                      child: Text(matricule),
                                                                                    );
                                                                                  }).toList() ??
                                                                                  [],
                                                                            ),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
                                                                  ],
                                                                ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                        SizedBox(height: 32),
                                        ElevatedButton(
                                          onPressed: submitReclamation,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 30,
                                            ),
                                          ),
                                          child:
                                              Text('Soumettre la réclamation'),
                                        )
                                      ],
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Placeholder for the second page
                  Placeholder(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Nouvelle réclamation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mes réclamations',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }

  void submitReclamation() async {
    await FirebaseFirestore.instance.collection('reclamations').add({
      'type': selectedTypeProblem,
      'description': selectedDescription ?? otherDescription,
      'userId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'envoyé',
      'reservationId': selectedReservation,
      'idPlace': await getPlaceNumberFromReservation(selectedReservation!),
      'matricule': selectedMatricule,
    });

    setState(() {
      selectedTypeProblem = null;
      selectedDescription = null;
      otherDescription = null;
      selectedReservation = null;
      selectedMatricule = null;
      _currentIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Réclamation enregistrée avec succès'),
      ),
    );
  }
}

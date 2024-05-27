import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierReclamationPage extends StatefulWidget {
  final String userId;
  final String reclamationId;

  ModifierReclamationPage({
    required this.userId,
    required this.reclamationId,
    required typeProblem,
    required description,
  });

  @override
  _ModifierReclamationPageState createState() =>
      _ModifierReclamationPageState();
}

class _ModifierReclamationPageState extends State<ModifierReclamationPage> {
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

  String? _typeProblem;
  String? _description;
  String? selectedMatricule; // Declare selectedMatricule variable

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    fetchReclamationDetails();
  }

  Future<void> fetchReclamationDetails() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('reclamations')
        .doc(widget.reclamationId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      if (data != null) {
        setState(() {
          _typeProblem = data['type'];
          _description = data['description'];
        });
      }
    }
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
                              'Modifier le type de réclamation',
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
                                value: _typeProblem,
                                onChanged: (value) {
                                  setState(() {
                                    _typeProblem = value;
                                    _description = null;
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
                              opacity: _typeProblem != null ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: _typeProblem != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Modifier la description',
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
                                            value: _description,
                                            onChanged: (value) {
                                              setState(() {
                                                _description = value;
                                              });
                                            },
                                            items: typeProblemDescriptions[
                                                    _typeProblem]!
                                                .map((description) {
                                              return DropdownMenuItem<String>(
                                                value: description,
                                                child: Text(description),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Modifier la matricule',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        FutureBuilder<List<String>>(
                                          future: getMatriculesForUser(
                                              widget.userId),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              List<String>? matricules =
                                                  snapshot.data;
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
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
                                                  items: matricules
                                                          ?.map((matricule) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: matricule,
                                                          child:
                                                              Text(matricule),
                                                        );
                                                      }).toList() ??
                                                      [],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 32),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              // Update the complaint in Firestore
                                              await FirebaseFirestore.instance
                                                  .collection('reclamations')
                                                  .doc(widget.reclamationId)
                                                  .update({
                                                'type': _typeProblem,
                                                'description': _description,
                                                'matricule': selectedMatricule,
                                              });
                                              Navigator.pop(context);
                                            } catch (e) {
                                              // Show an error message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error updating complaint: $e'),
                                                ),
                                              );
                                            }
                                          },
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
                                          child: Text(
                                              'Enregistrer les modifications'),
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
    );
  }

  Future<List<String>> getMatriculesForUser(String userId) async {
    List<String> matricules = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('matricule').get();

    snapshot.docs.forEach((doc) {
      matricules.add(doc.id);
    });

    return matricules;
  }
}

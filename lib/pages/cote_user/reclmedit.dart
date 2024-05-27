import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierReclamationPage extends StatefulWidget {
  final String userId;
  final String reclamationId;
  final String typeProblem;
  final String description;

  ModifierReclamationPage({
    required this.userId,
    required this.reclamationId,
    required this.typeProblem,
    required this.description,
  });

  @override
  __ModifierReclamationPageState createState() =>
      __ModifierReclamationPageState();
}

class __ModifierReclamationPageState extends State<ModifierReclamationPage> {
  late String _typeProblem;
  late String _description;
  final Map<String, List<String>> typeProblemDescriptions = {
    'Place réservée non disponible': [
      "Ma place réservée est occupée.",
      "Ma place réservée est bloquée par des véhicules mal garés.",
      //"Les places de parking réservées aux personnes handicapées sont occupées par des véhicules non autorisés."
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

  @override
  void initState() {
    super.initState();
    _typeProblem = widget.typeProblem;
    _description = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier la réclamation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _typeProblem,
              onChanged: (value) {
                setState(() {
                  _typeProblem = value!;
                });
              },
              items: [
                'Place réservée non disponible',
                'Problème de paiement',
                'Problème de sécurité',
                'Difficulté daccès',
                'Problème de réservation de handicap'
              ].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _description,
              onChanged: (value) {
                setState(() {
                  _description = value!;
                });
              },
              items: typeProblemDescriptions[_typeProblem]!.map((description) {
                return DropdownMenuItem<String>(
                  value: description,
                  child: Text(description),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Mettre à jour la réclamation dans Firestore
                  await FirebaseFirestore.instance
                      .collection('reclamations')
                      .doc(widget.reclamationId)
                      .update({
                    'type': _typeProblem,
                    'description': _description,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  // Afficher un message d'erreur
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Erreur lors de la modification de la réclamation : $e'),
                    ),
                  );
                }
              },
              child: Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}

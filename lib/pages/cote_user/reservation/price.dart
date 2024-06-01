import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrixPage extends StatefulWidget {
  final String reservationId;
  final Timestamp debut;
  final Timestamp fin;

  PrixPage({
    required this.reservationId,
    required this.debut,
    required this.fin,
  });

  @override
  _PrixPageState createState() => _PrixPageState();
}

class _PrixPageState extends State<PrixPage> {
  int _prix = 0;

  @override
  void initState() {
    super.initState();
    _calculerPrix();
  }

  Future<void> _calculerPrix() async {
    final dureeTotale = widget.fin.toDate().difference(widget.debut.toDate());
    final dureeMinutes = dureeTotale.inMinutes;

    print('Durée totale en minutes: $dureeMinutes');

    // Récupérer le document de réservation à partir de l'idReservation
    final reservationDoc = await FirebaseFirestore.instance
        .collection('reservation')
        .doc(widget.reservationId)
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
          .collection('place')
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

          print('Prix calculé: $_prix');

          // Mettre à jour le prix dans le document de réservation
          await FirebaseFirestore.instance
              .collection('reservation')
              .doc(widget.reservationId)
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Retourner le prix calculé à la page précédente
        Navigator.pop(context, _prix);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Prix de la réservation'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Prix à payer :',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                '$_prix DA',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

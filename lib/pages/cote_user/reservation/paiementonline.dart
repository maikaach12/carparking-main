import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaiementOnlinePage extends StatefulWidget {
  final String reservationId;

  PaiementOnlinePage({required this.reservationId});

  @override
  _PaiementOnlinePageState createState() => _PaiementOnlinePageState();
}

class _PaiementOnlinePageState extends State<PaiementOnlinePage> {
  Map? reservationDetails;

  @override
  void initState() {
    super.initState();
    fetchReservationDetails();
  }

  Future<void> fetchReservationDetails() async {
    try {
      final reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservationU')
          .doc(widget.reservationId)
          .get();

      if (reservationSnapshot.exists) {
        setState(() {
          reservationDetails = reservationSnapshot.data();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Aucune réservation trouvée pour cet ID.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Une erreur s\'est produite : $e'),
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

  @override
  Widget build(BuildContext context) {
    _executeCurlCommands();

    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement en ligne'),
        backgroundColor: Color.fromARGB(255, 74, 172, 163),
      ),
      body: reservationDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de la réservation',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 74, 172, 163),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Début : ${DateFormat('dd/MM/yyyy HH:mm').format(reservationDetails!['debut'].toDate())}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Fin : ${DateFormat('dd/MM/yyyy HH:mm').format(reservationDetails!['fin'].toDate())}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Type de place : ${reservationDetails!['typePlace']}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Prix : ${reservationDetails!['prix']} DA',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Option de paiement',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () {
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'lib/images/gg.png',
                                  height: 50.0,
                                  width: 50.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Baridi Mob',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Implémenter la logique de paiement en ligne ici
                          // Par exemple, ouvrir un site web de paiement tiers
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 74, 172, 163),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: Text(
                          'Procéder au paiement',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _executeCurlCommands() async {
    // Execute the second cURL command
    const url2 = 'https://pay.chargily.net/test/api/v2/prices';
    const headers2 = {
      'Authorization':
          'Bearer test_sk_sZRIC6WRbCDtzhyWOuchvM7h71e69pXyBczHk6wn',
      'Content-Type': 'application/json'
    };
    final body2 =
        '{"amount": 500, "currency": "dzd", "product_id": "01hhyjnrdbc1xhgmd34hs1v3en"}';

    try {
      final response2 = await http.post(
        Uri.parse(url2),
        headers: headers2,
        body: body2,
      );

      if (response2.statusCode == 200) {
        print('Second curl command executed successfully');
      } else {
        print(
            'Failed to execute second curl command. Status code: ${response2.statusCode}');
      }
    } catch (e) {
      print('Error executing second curl command: $e');
    }
  }
}

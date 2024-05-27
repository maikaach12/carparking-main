import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReclamationAdminPage extends StatefulWidget {
  @override
  _ReclamationAdminPageState createState() => _ReclamationAdminPageState();
}

class _ReclamationAdminPageState extends State<ReclamationAdminPage> {
  String adminEmail = 'admin@example.com';

  Future<String> getUserEmail(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('email')) {
        return userData['email'];
      }
    }
    return 'Email inconnu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réclamations Admin'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email Admin: $adminEmail'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reclamations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Une erreur s\'est produite');
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final reclamations = snapshot.data!.docs;
                final userIds =
                    reclamations.map((doc) => doc.get('userId')).toSet();
                return ListView.builder(
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    final userId = userIds.elementAt(index);
                    final userReclamations = reclamations
                        .where((doc) => doc.get('userId') == userId);
                    return FutureBuilder<String>(
                      future: getUserEmail(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final userEmail = snapshot.data!;
                          return ExpansionTile(
                            title: Text(
                                'Email Utilisateur: $userEmail (${userReclamations.length} réclamations)'),
                            children: userReclamations.map((doc) {
                              final reclamationData = doc.data();
                              if (reclamationData is Map<String, dynamic>) {
                                return ListTile(
                                  title: Text(reclamationData['type'] ?? ''),
                                  subtitle: Text(
                                      reclamationData['description'] ?? ''),
                                  tileColor:
                                      reclamationData['status'] == 'terminée'
                                          ? Colors.green.withOpacity(0.3)
                                          : null,
                                  onTap: () {
                                    if (reclamationData['status'] ==
                                        'en attente') {
                                      FirebaseFirestore.instance
                                          .collection('reclamations')
                                          .doc(doc.id)
                                          .update({'status': 'en cours'});
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReclamationDetailsPage(
                                          reclamationId: doc.id,
                                          reclamationData: reclamationData,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return ListTile(
                                  title: Text('Données invalides'),
                                );
                              }
                            }).toList(),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ReclamationDetailsPage extends StatefulWidget {
  final String reclamationId;
  final Map<String, dynamic> reclamationData;

  ReclamationDetailsPage(
      {required this.reclamationId, required this.reclamationData});

  @override
  _ReclamationDetailsPageState createState() => _ReclamationDetailsPageState();
}

class _ReclamationDetailsPageState extends State<ReclamationDetailsPage> {
  String reponse = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réclamation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${widget.reclamationData['type'] ?? ''}'),
            Text('Description: ${widget.reclamationData['description'] ?? ''}'),
            Text('Statut: ${widget.reclamationData['status'] ?? ''}'),
            if (widget.reclamationData['timestamp'] != null)
              Text(
                  'Timestamp: ${(widget.reclamationData['timestamp'] as Timestamp).toDate()}'),
            Text('UserId: ${widget.reclamationData['userId'] ?? ''}'),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  reponse = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Réponse',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('reclamations')
                    .doc(widget.reclamationId)
                    .update({
                  'status': 'traitée',
                  'reponse': reponse,
                });
              },
              child: Text('Marquer comme traitée'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('reclamations')
                    .doc(widget.reclamationId)
                    .update({
                  'status': 'terminée',
                });
                Navigator.pop(context);
              },
              child: Text('Clôturer la réclamation'),
            ),
          ],
        ),
      ),
    );
  }
}

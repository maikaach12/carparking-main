import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReclamationDetailsPage extends StatefulWidget {
  final String reclamationId;
  final Map<String, dynamic> reclamationData;

  ReclamationDetailsPage({
    required this.reclamationId,
    required this.reclamationData,
  });

  @override
  _ReclamationDetailsPageState createState() => _ReclamationDetailsPageState();
}

class _ReclamationDetailsPageState extends State<ReclamationDetailsPage> {
  String reponse = '';
  TextEditingController typeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedUserId = '';
  String? userId; // userId récupéré à partir du matricule

  @override
  void initState() {
    super.initState();
    _fetchUserIdFromMatricule();
  }

  void _fetchUserIdFromMatricule() async {
    String matricule = widget.reclamationData['matricule'];

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('matricule')
        .doc(matricule)
        .get();

    if (documentSnapshot.exists) {
      setState(() {
        userId = documentSnapshot.get('userId');
      });
    }
  }

  void _signalerPersonneResponsable() async {
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        int nbrSignal = userSnapshot.get('nbrSignal') ?? 0;

        nbrSignal++;

        await userSnapshot.reference.update({'nbrSignal': nbrSignal});

        if (nbrSignal == 4) {
          await userSnapshot.reference.update({'active': false});
        }
      }
    }
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

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisir l\'utilisateur à notifier :'),
              DropdownButton<String>(
                value: selectedUserId.isNotEmpty ? selectedUserId : null,
                hint: Text('Sélectionner un utilisateur'),
                onChanged: (newValue) {
                  setState(() {
                    selectedUserId = newValue ?? '';
                  });
                },
                items: [
                  if (widget.reclamationData['userId'] != null)
                    DropdownMenuItem(
                      value: widget.reclamationData['userId'],
                      child: Text('Utilisateur ayant soumis la réclamation'),
                    ),
                  if (userId != null)
                    DropdownMenuItem(
                      value: userId,
                      child: Text('Utilisateur à signaler'),
                    ),
                ],
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Type de notification',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description de la notification',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: selectedUserId.isNotEmpty
                    ? () {
                        String type = typeController.text;
                        String description = descriptionController.text;

                        _sendNotification(selectedUserId, type, description);
                      }
                    : null,
                child: Text('Envoyer une notification'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réclamation'),
        actions: [
          IconButton(
            icon: Icon(Icons.notification_important),
            onPressed: _showNotificationBottomSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: Text('Type'),
                  subtitle: Text(widget.reclamationData['type'] ?? ''),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Description'),
                  subtitle: Text(widget.reclamationData['description'] ?? ''),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Statut'),
                  subtitle: Text(widget.reclamationData['status'] ?? ''),
                ),
              ),
              if (widget.reclamationData['timestamp'] != null)
                Card(
                  child: ListTile(
                    title: Text('Timestamp'),
                    subtitle: Text(
                      (widget.reclamationData['timestamp'] as Timestamp)
                          .toDate()
                          .toString(),
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  title: Text('UserId'),
                  subtitle: Text(widget.reclamationData['userId'] ?? ''),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Matricule de l\'autre personne'),
                  subtitle: Text(widget.reclamationData['matricule'] ?? ''),
                ),
              ),
              if (widget.reclamationData['type'] ==
                  'Place réservée non disponible')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _signalerPersonneResponsable,
                    child: Text('Signaler la personne responsable'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  setState(() {
                    reponse = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Réponse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

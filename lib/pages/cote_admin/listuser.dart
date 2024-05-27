import 'package:carparking/pages/cote_admin/reclamation_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListPage extends StatefulWidget {
  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String email = data['email'] ?? 'Email non disponible';
              return ListTile(
                title: Text(email),
                onTap: () {
                  // Navigate to ReclamationAdminPage for the selected user
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReclamationAdminPage(),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAccountsPage extends StatefulWidget {
  @override
  _ManageAccountsPageState createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _toggleAccountStatus(String userId, bool active) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      DocumentSnapshot adminSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!adminSnapshot.exists || adminSnapshot['role'] != 'admin') {
        throw Exception(
            'Error updating account status: Current user is not an admin');
      }

      await _firestore.collection('users').doc(userId).update({
        'active': active,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'User account ${active ? 'activated' : 'deactivated'} successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating account status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Accounts',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              String userId = doc.id;
              String userEmail = doc['email'];
              bool isActive = doc['active'];

              return Card(
                color: Colors.white.withOpacity(1.0),
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                elevation: 5.0,
                child: ListTile(
                  leading: Icon(
                    isActive ? Icons.check_circle : Icons.block,
                    color: isActive ? Colors.green : Colors.red,
                    size: 30.0, // Taille réduite des icônes
                  ),
                  title: Text(userEmail),
                  trailing: IconButton(
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      color: isActive ? Colors.red : Colors.blue,
                    ),
                    onPressed: () async {
                      await _toggleAccountStatus(userId, !isActive);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ManageAccountsPage(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
  ));
}

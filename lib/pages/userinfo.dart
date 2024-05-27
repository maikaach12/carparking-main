import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      _user = _auth.currentUser;
      if (_user != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: _userData != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${_userData!['email']}'),
                Text('Name: ${_userData!['name']}'),
                Text('Family Name: ${_userData!['familyName']}'),
                Text('ID Card: ${_userData!['idCard']}'),
                Text('Driver License: ${_userData!['driverLicense']}'),
                Text('Car Registration: ${_userData!['carRegistration']}'),
                Text('Age: ${_userData!['age']}'),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

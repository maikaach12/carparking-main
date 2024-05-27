import 'dart:math' as math;

import 'package:carparking/pages/login_signup/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  ProfilePage({required this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  List<String> carRegistrations = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchCarRegistrations();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchCarRegistrations() async {
    try {
      QuerySnapshot<Map<String, dynamic>> carDocs = await FirebaseFirestore
          .instance
          .collection('matricule')
          .where('userId', isEqualTo: widget.userId)
          .get();
      List<String> registrations = carDocs.docs.map((doc) => doc.id).toList();
      setState(() {
        carRegistrations = registrations;
      });
    } catch (e) {
      print('Error fetching car registrations: $e');
    }
  }

  Future<void> updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': userData!['name'],
        'email': userData!['email'],
        'familyName': userData!['familyName'],
        'phoneNumber': userData!['phoneNumber'],
        'driverLicense': userData!['driverLicense'],
        'idCard': userData!['idCard'],
        'age': userData!['age'],
        'desactiveparmoi': userData!['desactiveparmoi'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data updated successfully'),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  void _showEditDialog(String field) {
    TextEditingController controller =
        TextEditingController(text: userData![field]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter new value',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            userData![field] = controller.text;
                          });
                          updateUserData();
                          Navigator.of(context).pop();
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'desactiveparmoi': true});

      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget topWidget(double screenWidth) {
    return Positioned(
      top: -50,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.blue,
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

  void _showAddCarDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter car registration',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () async {
                          if (controller.text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('matricule')
                                .doc(controller.text)
                                .set({
                              'userId': widget.userId,
                            });
                            fetchCarRegistrations();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            bottom: -0.4 * screenHeight,
            right: -0.4 * screenWidth,
            child: bottomWidget(screenWidth),
          ),
          Stack(
            children: [
              topWidget(screenWidth),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/blue.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 250, 248, 248),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 50),
                          userData == null
                              ? Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Name: ${userData!['name']}'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog('name'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.email),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Email: ${userData!['email']}'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog('email'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.family_restroom),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Family Name: ${userData!['familyName']}'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog('familyName'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.phone),
                                                SizedBox(width: 5),
                                                Text(
                                                    'Phone Number: ${userData!['phoneNumber']}'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () => _showEditDialog(
                                                  'phoneNumber'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.credit_card),
                                                SizedBox(width: 5),
                                                Text(
                                                    'ID Card: ${userData!['idCard']}'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog('idCard'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Age: ${userData!['age']}',
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog('age'),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Car Registrations:',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            for (var carRegistration
                                                in carRegistrations)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(carRegistration),
                                                ],
                                              ),
                                            SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 16),
                                              ),
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: _showAddCarDialog,
                                              label: Text(
                                                'Add Car Registration',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Deactivate Account'),
                                            Switch(
                                              value: userData![
                                                      'desactiveparmoi'] ??
                                                  false,
                                              onChanged: (value) async {
                                                bool confirmed =
                                                    await showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'Confirm Account Deactivation',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              Text(
                                                                'Are you sure you want to deactivate your account?',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 24),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextButton(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .blue,
                                                                      textStyle:
                                                                          GoogleFonts
                                                                              .poppins(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                        'Cancel'),
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(false),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  TextButton(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      foregroundColor:
                                                                          Colors
                                                                              .blue,
                                                                      textStyle:
                                                                          GoogleFonts
                                                                              .poppins(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                        'Confirm'),
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(true),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                if (confirmed) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(widget.userId)
                                                      .update({
                                                    'desactiveparmoi': true
                                                  });

                                                  await FirebaseAuth.instance
                                                      .signOut();

                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginPage(),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.grey[200],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 16),
                                          ),
                                          icon: Icon(
                                            Icons.logout,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage(),
                                              ),
                                            );
                                          },
                                          label: Text(
                                            'Logout',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

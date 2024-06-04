import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carparking/pages/cote_user/map.dart';

class SignUpDetailsPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneNumberController;

  SignUpDetailsPage({
    required this.emailController,
    required this.passwordController,
    required this.phoneNumberController,
    required TextEditingController confirmPasswordController,
  });

  @override
  _SignUpDetailsPageState createState() => _SignUpDetailsPageState();
}

class _SignUpDetailsPageState extends State<SignUpDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController driverLicenseController = TextEditingController();
  final List<TextEditingController> carRegistrationControllers = [
    TextEditingController()
  ];

  String? signupError; // Variable pour stocker les erreurs d'inscription

  bool validateFields() {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        familyNameController.text.isEmpty ||
        idCardController.text.isEmpty ||
        driverLicenseController.text.isEmpty ||
        carRegistrationControllers
            .any((controller) => controller.text.isEmpty)) {
      setState(() {
        signupError =
            'Veuillez remplir tous les champs, y compris les immatriculations';
      });
      return false;
    }
    return true;
  }

  void reserve(BuildContext context) async {
    setState(() {
      signupError = null; // Effacer les erreurs précédentes
    });

    if (validateFields()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.emailController.text,
          password: widget.passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text,
          'age': ageController.text,
          'familyName': familyNameController.text,
          'idCard': idCardController.text,
          'driverLicense': driverLicenseController.text,
          'email': widget.emailController.text,
          'phoneNumber': widget.phoneNumberController.text,
          'role': 'user',
          'desactiveparmoi': false,
          'active': true,
          'nbrSignal': 0,
        });

        saveCarRegistrations(userCredential.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(userId: userCredential.user!.uid),
          ),
        );
      } catch (e) {
        setState(() {
          signupError = 'Erreur lors de l\'inscription: $e';
        });
      }
    }
  }

  void saveCarRegistrations(String userId) async {
    try {
      for (var controller in carRegistrationControllers) {
        await FirebaseFirestore.instance
            .collection('véhicule')
            .doc(controller.text)
            .set({'userId': userId});
      }
    } catch (e) {
      setState(() {
        signupError =
            'Erreur lors de l\'enregistrement de l\'immatriculation: $e';
      });
    }
  }

  void addCarRegistrationField() {
    setState(() {
      carRegistrationControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/blue.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 250, 248, 248),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      "Parking.dz",
                      style: GoogleFonts.montserrat(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Nom',
                        hintStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon:
                            Icon(Icons.family_restroom, color: Colors.black),
                        errorText: nameController.text.isEmpty
                            ? 'Veuillez saisir votre nom'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: familyNameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Prénom',
                        hintStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        errorText: familyNameController.text.isEmpty
                            ? 'Veuillez saisir votre prénom'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: ageController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Age',
                        hintStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon:
                            Icon(Icons.calendar_today, color: Colors.black),
                        errorText: ageController.text.isEmpty
                            ? 'Veuillez saisir votre âge'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: idCardController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'ID Card',
                        hintStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon:
                            Icon(Icons.credit_card, color: Colors.black),
                        errorText: idCardController.text.isEmpty
                            ? 'Veuillez saisir votre carte didentité'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: driverLicenseController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Driver License',
                        hintStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon: Icon(Icons.drive_eta, color: Colors.black),
                        errorText: driverLicenseController.text.isEmpty
                            ? 'Veuillez saisir votre permis de conduire'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  ...carRegistrationControllers.map((controller) {
                    int index = carRegistrationControllers.indexOf(controller);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Car Registration ${index + 1}',
                          hintStyle: TextStyle(color: Colors.black),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon:
                              Icon(Icons.car_rental, color: Colors.black),
                          errorText: controller.text.isEmpty
                              ? 'Veuillez saisir l\'immatriculation de votre voiture'
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: addCarRegistrationField,
                    child: Icon(Icons.add),
                  ),
                  SizedBox(height: 20),
                  if (signupError != null)
                    Text(
                      signupError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                    onPressed: () => reserve(context),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

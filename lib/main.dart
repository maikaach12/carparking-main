// Importations
import 'package:carparking/pages/cote_admin/AdminDashboardPage.dart';
import 'package:carparking/pages/cote_admin/gerer/reclamation_admin.dart';
import 'package:carparking/pages/cote_admin/stat/ReservationFrequencyPage.dart';
import 'package:carparking/pages/cote_admin/stat/reservationchart.dart';
import 'package:carparking/pages/cote_user/reclamlist.dart';
import 'package:carparking/pages/cote_user/reservation/listeParking.dart';
import 'package:carparking/pages/login_signup/firstPage.dart';
import 'package:carparking/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Fonction principale
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Application MyApp
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CarParking.dz',
        home: FirstPage()
        //PaiementOnlinePage(reservationId: 'rYYqO8wzkDp9Q8Qq6GAp', )
        );
  }
}

// AuthPage pour gérer l'authentification

// Page de connexion de l'administrateur




// Page d'inscription de l'utilisateur

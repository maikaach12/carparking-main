import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ParkingStatistics extends StatelessWidget {
  const ParkingStatistics({Key? key}) : super(key: key);

  Future<int> _fetchParkingCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('parkingu').get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchParkingCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitCircle(
              color: Colors.blue, // Couleur de l'indicateur de chargement
              size: 20.0, // Taille de l'indicateur de chargement
            ),
          );
        } else if (snapshot.hasError) {
          print("Error in FutureBuilder: ${snapshot.error}");
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          int parkingCount = snapshot.data ?? 0;
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "$parkingCount",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0, // Taille de police plus petite
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8.0), // Espacement plus petit
                  Text(
                    "Total Parkings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0, // Taille de police du texte plus petite
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

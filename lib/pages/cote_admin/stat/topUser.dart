import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TopUserWidget extends StatelessWidget {
  const TopUserWidget({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchTopUser() async {
    try {
      // Fetching the reservation counts for each user
      QuerySnapshot reservationSnapshot =
          await FirebaseFirestore.instance.collection('reservation').get();
      Map<String, int> userReservationCounts = {};

      // Calculating the reservation count for each user
      reservationSnapshot.docs.forEach((reservation) {
        String userId = reservation['userId'];
        // Using a ternary operator to increment the count or set it to 1
        userReservationCounts[userId] =
            userReservationCounts.containsKey(userId)
                ? userReservationCounts[userId]! + 1
                : 1;
      });

      // Finding the user with the maximum reservation count
      String topUserId = '';
      int maxReservations = 0;
      userReservationCounts.forEach((userId, count) {
        if (count > maxReservations) {
          topUserId = userId;
          maxReservations = count;
        }
      });

      // Fetching the user's name based on their ID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(topUserId)
          .get();
      String userName = userSnapshot['name'];

      // Returning the top user information
      return {'name': userName, 'reservations': maxReservations};
    } catch (e) {
      print("Error fetching top user: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchTopUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitCircle(
              color: Colors.pink,
              size: 50.0,
            ),
          );
        } else if (snapshot.hasError) {
          print("Error in FutureBuilder: ${snapshot.error}");
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          String topUserName = snapshot.data?['name'] ?? '';
          int topUserReservations = snapshot.data?['reservations'] ?? 0;
          return Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade300,
                  Color.fromARGB(255, 157, 207, 225)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 8,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conducteur VIP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('lib/images/avatar.png'),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topUserName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$topUserReservations Reservations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

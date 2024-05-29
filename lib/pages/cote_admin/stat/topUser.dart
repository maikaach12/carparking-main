import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TopUserWidget extends StatelessWidget {
  const TopUserWidget({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchTopUser() async {
    try {
      // Fetching the reservation counts for each user
      QuerySnapshot reservationSnapshot =
          await FirebaseFirestore.instance.collection('reservationU').get();
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
              size: 16.0,
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
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage('assets/images/user_avatar.png'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topUserName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '$topUserReservations Reservations',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 24,
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

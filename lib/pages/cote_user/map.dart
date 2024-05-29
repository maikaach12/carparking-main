import 'package:carparking/pages/cote_user/MesReservationsPage.dart';
import 'package:carparking/pages/cote_user/NotificationPage.dart';
import 'package:carparking/pages/cote_user/profilepage.dart';
import 'package:carparking/pages/cote_user/reclamationuser.dart';
import 'package:carparking/pages/cote_user/reservation/listeParking.dart';
import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class MapPage extends StatefulWidget {
  final String userId;

  MapPage({this.userId = ''});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late String _userId;
  int _newNotifications =
      0; // Variable to store the number of new notifications

  MapController _mapController = MapController();
  int _selectedIndex = 0;
  List<Marker> _markers = [];
  LatLng _fixedLocation =
      LatLng(36.75333078055549, 3.4708591109601565); // Fixed location
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  int _duration = 0;
  PolylineLayer? _routeLayer;
  String _appBarTitle =
      'Cliquer pour afficher tous les parkings'; // AppBar title

  @override
  void initState() {
    super.initState();
    _fetchPlacesFromFirebase();
    _userId = widget.userId;
    _getNewNotifications(); // Call method to get the number of new notifications
  }

  // Method to get the number of new notifications
  void _getNewNotifications() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: _userId)
        .where('isRead',
            isEqualTo: false) // Condition to get only unread notifications
        .get();
    setState(() {
      _newNotifications = snapshot.docs.length;
    });
  }

  void _fetchPlacesFromFirebase() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('parkingu').get();
    List<Marker> markers = [];

    snapshot.docs.forEach((doc) {
      String name = doc['nom'];
      String place = doc['place'];
      String parkingId = doc.id; // Get document ID

      GeoPoint position = doc['position'];
      LatLng latLng = LatLng(position.latitude, position.longitude);

      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: latLng,
          child: GestureDetector(
            onTap: () {
              _showPlaceInfo(name, place, latLng, parkingId); // Pass parking ID
            },
            child: Icon(
              Icons.location_on,
              color: Color.fromARGB(255, 95, 87, 182),
              size: 36,
            ),
          ),
        ),
      );
    });

    setState(() {
      _markers = markers;
    });
  }

  void _showPlaceInfo(String namePark, String place, LatLng placeLatLng,
      String parkingId) async {
    _calculateRouteAndDrawLine(placeLatLng);

    // Get parking document
    final parkingDoc = await FirebaseFirestore.instance
        .collection('parkingu')
        .doc(parkingId)
        .get();

    // Check if document exists and has a placesDisponible value
    if (parkingDoc.exists &&
        parkingDoc.data()!.containsKey('placesDisponible')) {
      int placesDisponible = parkingDoc.data()!['placesDisponible'];

      showModalBottomSheet(
        context: context,
        builder: (context) {
          final double distance = _distance / 1000;
          final int duration = _duration;
          final String address =
              'Latitude: ${placeLatLng.latitude}, Longitude: ${placeLatLng.longitude}'; // Replace with a method to convert coordinates to address

          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  namePark,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(address),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          placesDisponible
                              .toString(), // Display number of available spots
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(Icons.location_on),
                    SizedBox(width: 4.0),
                    Text('${distance.toStringAsFixed(2)} km'),
                    SizedBox(width: 16.0),
                    Icon(Icons.directions_car),
                    SizedBox(width: 4.0),
                    Text('$duration minutes'),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationPage(
                          parkingId: parkingId,
                        ),
                      ),
                    );
                  },
                  child: Text('Réserver'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _calculateRouteAndDrawLine(LatLng destination) {
    setState(() {
      _routePoints = [_fixedLocation, destination];
      _distance =
          calculateDistance(destination.latitude, destination.longitude);
      _duration = calculateDuration(_distance);
    });
  }

  void _drawRoute() {
    if (_routePoints.isNotEmpty) {
      setState(() {
        _routeLayer = PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              color: Colors.blue,
              strokeWidth: 4,
            ),
          ],
        );
      });
    }
  }

  double calculateDistance(double lat, double lon) {
    double distance = 0.0;
    distance = Geolocator.distanceBetween(
      _fixedLocation.latitude,
      _fixedLocation.longitude,
      lat,
      lon,
    );
    return distance;
  }

  int calculateDuration(double distance) {
    double averageSpeed = 50.0;
    double distanceInKm = distance / 1000.0;
    double timeInHours = distanceInKm / averageSpeed;
    int timeInMinutes = (timeInHours * 60).round();
    return timeInMinutes;
  }

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.local_parking),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListeParkingPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
                Icons.report_problem), // Add this line for the reclamation icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReclamationPage(userId: _userId),
                ), // Replace with your reclamation page
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications), // Notification icon
                if (_newNotifications > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_newNotifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              // Navigate to NotificationPage and mark all notifications as read
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(userId: _userId),
                ),
              );
              // After returning from NotificationPage, update the number of new notifications
              _getNewNotifications();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -0.2 * screenHeight,
            left: -0.2 * screenWidth,
            child: topWidget(screenWidth),
          ),
          Positioned(
            bottom: -0.4 * screenHeight,
            right: -0.4 * screenWidth,
            child: bottomWidget(screenWidth),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'lib/images/blue.png'), // Replace with your background image path
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
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _fixedLocation,
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: _markers,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: _fixedLocation,
                          child: Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                    if (_routeLayer != null) _routeLayer!,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesReservationsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfilePage(userId: _userId), // Replace with your profile page
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _mapController.move(_fixedLocation, 13.0);
  }
}

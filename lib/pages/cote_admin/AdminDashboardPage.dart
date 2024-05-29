import 'package:carparking/pages/cote_admin/gerer/Gerer_compte.dart';
import 'package:carparking/pages/cote_admin/gerer/Gerer_parking.dart';
import 'package:carparking/pages/cote_admin/stat/ReclamationStatistics.dart';
import 'package:carparking/pages/cote_admin/stat/ReservationFrequencyPage.dart';
import 'package:carparking/pages/cote_admin/stat/UserStatistics.dart';
import 'package:carparking/pages/cote_admin/gerer/gererplace.dart';
import 'package:carparking/pages/cote_admin/stat/carstat.dart';
import 'package:carparking/pages/cote_admin/stat/navbar.dart';
import 'package:carparking/pages/cote_admin/stat/parkinglistviewadmin.dart';
import 'package:carparking/pages/cote_admin/gerer/reclamation_admin.dart';
import 'package:carparking/pages/cote_admin/gerer/reservationadmin.dart';
import 'package:carparking/pages/cote_admin/stat/parkingstat.dart';
import 'package:carparking/pages/cote_admin/stat/placeStat.dart';
import 'package:carparking/pages/cote_admin/stat/reservStati.dart';
import 'package:carparking/pages/cote_admin/stat/reservationchart.dart';
import 'package:carparking/pages/cote_admin/stat/topUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  AdminDashboardPage({required this.userId, required this.userEmail});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showSidebar = false;
  Widget _currentPage = ParkingListView(
    parkingsCollection: FirebaseFirestore.instance.collection('parkingu'),
  );

  void _navigateTo(Widget page) {
    setState(() {
      _currentPage = page;
      _showSidebar = false;
    });
  }

  void _navigateToReservationFrequencyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chart(
          reservationsCollection:
              FirebaseFirestore.instance.collection('reservationU'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _showSidebar ? 250 : 0,
                child: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(widget.userEmail),
                        accountEmail: Text(widget.userId),
                        currentAccountPicture: CircleAvatar(
                          child: Icon(
                            Icons.person,
                            size: 40,
                          ),
                          backgroundColor: Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Gérer Compte'),
                        onTap: () {
                          _navigateTo(ManageAccountsPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.local_parking),
                        title: Text('Gérer Parking'),
                        onTap: () {
                          _navigateTo(GererParkingPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.error),
                        title: Text('Gérer Réclamation'),
                        onTap: () {
                          _navigateTo(ReclamationAdminPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.place),
                        title: Text('Gérer Place'),
                        onTap: () {
                          _navigateTo(GererPlacePage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.book),
                        title: Text('Réservation'),
                        onTap: () {
                          _navigateTo(reservationPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.bar_chart),
                        title: Text('Reclamation Statistics'),
                        onTap: () {
                          _navigateTo(ReclamationStatistics());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Navbar(
                      onMenuTap: () {
                        setState(() {
                          _showSidebar = !_showSidebar;
                        });
                      },
                      onHomeTap: () {
                        _navigateTo(_currentPage);
                      },
                      onStatisticsTap: () =>
                          _navigateToReservationFrequencyPage(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TopUserWidget(),
                            ),
                            Wrap(
                              spacing: 10.0, // Reduced spacing between items
                              runSpacing:
                                  10.0, // Reduced run spacing between items
                              children: [
                                UserStatistics(), // Removed extra padding
                                ReclamationStatistics(), // Removed extra padding
                                PlaceStatistics(), // Removed extra padding
                                CarStatistics(), // Removed extra padding
                                ParkingStatistics(), // Removed extra padding
                                ReservationStatistics(), // Removed extra padding
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: _currentPage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: MouseRegion(
              opaque: false,
              onHover: (_) {
                setState(() {
                  _showSidebar = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _showSidebar = false;
                });
              },
              child: Container(
                width: 10,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onHomeTap;
  final VoidCallback onStatisticsTap;

  Navbar({
    required this.onMenuTap,
    required this.onHomeTap,
    required this.onStatisticsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(Icons.menu),
          ),
          Spacer(),
          IconButton(
            onPressed: onHomeTap,
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: onStatisticsTap,
            icon: Icon(Icons.bar_chart),
          ),
        ],
      ),
    );
  }
}

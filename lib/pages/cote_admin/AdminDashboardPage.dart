import 'package:carparking/pages/cote_admin/Gerer_compte.dart';
import 'package:carparking/pages/cote_admin/Gerer_parking.dart';
import 'package:carparking/pages/cote_admin/gererplace.dart';
import 'package:carparking/pages/cote_admin/reclamation_admin.dart';
import 'package:carparking/pages/cote_admin/reservationadmin.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: _currentPage,
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

class ParkingListView extends StatelessWidget {
  final CollectionReference<Object?> parkingsCollection;

  ParkingListView({required this.parkingsCollection});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: parkingsCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final parkings = snapshot.data!.docs;
        final parkingData = parkings.map((doc) {
          final parking = doc.data() as Map<String, dynamic>;
          return ParkingData(
            nom: parking['nom'] ?? '',
            capacite: parking['capacite'] ?? 0,
            placesDisponible: parking['placesDisponible'] ?? 0,
          );
        }).toList();

        return Column(
          children: [
            ParkingChart(parkingData: parkingData),
          ],
        );
      },
    );
  }
}

class ParkingData {
  final String nom;
  final int capacite;
  final int placesDisponible;

  ParkingData({
    required this.nom,
    required this.capacite,
    required this.placesDisponible,
  });
}

class ParkingChart extends StatelessWidget {
  final List<ParkingData> parkingData;

  ParkingChart({required this.parkingData});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> groups = parkingData
        .asMap()
        .map((index, data) {
          return MapEntry(
            index,
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.capacite.toDouble(),
                  color: Colors.blue,
                  width: 8,
                ),
                BarChartRodData(
                  toY: data.placesDisponible.toDouble(),
                  color: Colors.green,
                  width: 8,
                ),
              ],
              barsSpace: 2,
            ),
          );
        })
        .values
        .toList();

    BarChartData barChartData = BarChartData(
      barGroups: groups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final parkingName = parkingData[group.x.toInt()].nom;
            final label = rodIndex == 0 ? 'Capacité' : 'Places Disponibles';
            return BarTooltipItem(
              '$parkingName\n',
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ${rod.toY}',
                  style: TextStyle(color: rod.color),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(parkingData[value.toInt()].nom);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      groupsSpace: 10,
    );

    return SizedBox(
      height: 200,
      child: BarChart(
        barChartData,
        swapAnimationDuration: Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}

class ParkingInfoCard extends StatelessWidget {
  final String nom;
  final int capacite;
  final int placesDisponible;

  ParkingInfoCard({
    required this.nom,
    required this.capacite,
    required this.placesDisponible,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nom,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Capacité: '),
                Text('$capacite'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Places disponibles: '),
                Text('$placesDisponible'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onHomeTap;

  Navbar({required this.onMenuTap, required this.onHomeTap});

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
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  toY: data.capacite.toDouble() /
                      10, // Réduire la hauteur des barres
                  color: Colors.blueAccent,
                  width: 4, // Barres plus fines
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: data.placesDisponible.toDouble() /
                      10, // Réduire la hauteur des barres
                  color: Colors.lightGreenAccent,
                  width: 4, // Barres plus fines
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              barsSpace: 8,
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
                  text:
                      '$label: ${rod.toY * 10}', // Multiplier par 10 pour afficher la valeur réelle
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
            showTitles: false, // Désactiver les titres en bas
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: false,
      ),
      groupsSpace: 12,
    );

    return SizedBox(
      height: 100, // Réduire la hauteur du conteneur
      child: BarChart(
        barChartData,
        swapAnimationDuration: Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }
}

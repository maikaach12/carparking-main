import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chart extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> reservationsCollection;

  Chart({required this.reservationsCollection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Statistiques'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: reservationsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final reservations =
              snapshot.data!.docs.map((doc) => doc.data()).toList();
          final reservationData = groupReservationsByHour(reservations);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Statistiques de Réservation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700, // Light blue color for title
                    ),
                  ),
                ),
                HourlyReservationChart(reservationData: reservationData),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Statistiques de Reclamation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700, // Light blue color for title
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<int, int> groupReservationsByHour(
      List<Map<String, dynamic>> reservations) {
    Map<int, int> hourlyReservations = {};

    for (var reservation in reservations) {
      final debut = (reservation['debut'] as Timestamp).toDate();
      final hour = debut.hour;
      hourlyReservations[hour] = (hourlyReservations[hour] ?? 0) + 1;
    }

    return hourlyReservations;
  }
}

class HourlyReservationChart extends StatelessWidget {
  final Map<int, int> reservationData;

  HourlyReservationChart({required this.reservationData});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = reservationData.entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
    }).toList();

    LineChartData lineChartData = LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.lightBlue, // Light blue color for the line
          barWidth: 2, // Line width
          belowBarData: BarAreaData(
            show: true,
            color: Colors.lightBlue.withOpacity(0.2), // Light blue area color
          ),
          dotData: FlDotData(show: false),
        ),
      ],
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}h',
                style: TextStyle(
                  color: Colors.grey.shade700, // Light blue color
                  fontSize: 8, // Smaller font size
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide left titles
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false, // Remove vertical grid lines
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2), // Light blue grid line color
            strokeWidth: 0.2, // Thinner grid line
          );
        },
      ),
      borderData: FlBorderData(
        show: false,
      ),
    );

    return SizedBox(
      height: 150, // Shorter chart height
      child: LineChart(
        lineChartData,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReservationFrequencyPage extends StatefulWidget {
  @override
  _ReservationFrequencyPageState createState() =>
      _ReservationFrequencyPageState();
}

class _ReservationFrequencyPageState extends State<ReservationFrequencyPage> {
  final CollectionReference<Object?> reservationsCollection =
      FirebaseFirestore.instance.collection('reservation');
  String _granularity = 'Week'; // Default granularity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Frequency'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _granularity,
              onChanged: (String? newValue) {
                setState(() {
                  _granularity = newValue!;
                });
              },
              items: <String>['Day', 'Week']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: reservationsCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final reservations = snapshot.data!.docs;
                final reservationData = _getReservationData(reservations);
                final reservationSpots = _getReservationSpots(reservationData);
                return ReservationChart(
                  reservationSpots: reservationSpots,
                  granularity: _granularity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> _getReservationData(List<QueryDocumentSnapshot> reservations) {
    Map<int, int> reservationCountPerHour = {};
    for (var doc in reservations) {
      final reservation = doc.data() as Map<String, dynamic>;
      final debut = (reservation['debut'] as Timestamp).toDate();
      final fin = (reservation['fin'] as Timestamp).toDate();

      if (_granularity == 'Day') {
        for (int hour = 0; hour < 24; hour++) {
          reservationCountPerHour[hour] = 0;
        }
        // Increment the count for each hour in the time range
        for (int hour = debut.hour; hour <= fin.hour; hour++) {
          reservationCountPerHour[hour] =
              (reservationCountPerHour[hour] ?? 0) + 1;
        }
      } else {
        final weekStart =
            DateTime(debut.year, debut.month, debut.day - debut.weekday + 1);
        reservationCountPerHour[weekStart.millisecondsSinceEpoch] =
            (reservationCountPerHour[weekStart.millisecondsSinceEpoch] ?? 0) +
                1;
      }
    }
    return reservationCountPerHour;
  }

  List<FlSpot> _getReservationSpots(Map<int, int> reservationData) {
    return reservationData.entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();
  }
}

class ReservationChart extends StatelessWidget {
  final List<FlSpot> reservationSpots;
  final String granularity;

  ReservationChart({required this.reservationSpots, required this.granularity});

  @override
  Widget build(BuildContext context) {
    LineChartData lineChartData = LineChartData(
      minY: 1,
      maxY: 50,
      lineBarsData: [
        LineChartBarData(
          spots: reservationSpots,
          isCurved: true,
          barWidth: 4,
          color: Colors.blue,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 16,
          axisNameWidget: Text(granularity == 'Day' ? 'Hour' : 'Week'),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              final formatter =
                  DateFormat(granularity == 'Day' ? 'HH:mm' : 'MMM dd');
              return Text(granularity == 'Day'
                  ? '${value.toInt()}:00'
                  : formatter.format(date));
            },
            interval: granularity == 'Day'
                ? 1
                : 7 *
                    24 *
                    3600 *
                    1000, // Interval in milliseconds for Day or Week
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 16,
          axisNameWidget: const Text('Number of reservations'),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
            interval: 1,
            reservedSize: 30,
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: granularity == 'Day' ? 1 : 7 * 24 * 3600 * 1000,
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
    );
    return SizedBox(
      height: 300,
      child: LineChart(lineChartData),
    );
  }
}

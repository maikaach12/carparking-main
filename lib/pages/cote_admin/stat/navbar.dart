import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onHomeTap;
  final VoidCallback onStatisticsTap; // Ajout du paramètre onStatisticsTap

  Navbar({
    required this.onMenuTap,
    required this.onHomeTap,
    required this.onStatisticsTap, // Ajout du paramètre onStatisticsTap dans le constructeur
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
            onPressed:
                onStatisticsTap, // Appel de la méthode onStatisticsTap lors du clic
            icon: Icon(Icons.bar_chart), // Icône de statistiques
          ),
        ],
      ),
    );
  }
}

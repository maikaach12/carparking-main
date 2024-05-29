import 'package:carparking/pages/cote_admin/stat/ReclamationStatistics.dart';
import 'package:carparking/pages/cote_admin/stat/UserStatistics.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  // Définissez ici la hauteur souhaitée pour la barre d'applications
  static const double appBarHeight = 80.0;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Admin Dashboard'),
      actions: [
        Row(
          children: [
            UserStatistics(),
            SizedBox(width: 16.0),
            ReclamationStatistics(),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carparking/pages/login_signup/loginPage.dart';
import 'package:carparking/pages/login_signup/sign_up.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool _isHoveringOnConnectButton = false;
  bool _isHoveringOnSignUpButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align at the top
            children: [
              SizedBox(height: 100), // Add space from the top
              // Title
              Text(
                'Bienvenue à Parking.dz',
                style: GoogleFonts.montserrat(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              // Description
              Text(
                'Réservez dès maintenant votre place de parking en toute simplicité ',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Chez Parking.dz, nous rendons le stationnement facile et pratique pour vous. Plus besoin de chercher une place pendant des heures',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  onEnter: (event) {
                    setState(() {
                      _isHoveringOnConnectButton = true;
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      _isHoveringOnConnectButton = false;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the login page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 18.0,
                      ),
                      decoration: BoxDecoration(
                        color: _isHoveringOnConnectButton
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        'Se connecter',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                MouseRegion(
                  onEnter: (event) {
                    setState(() {
                      _isHoveringOnSignUpButton = true;
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      _isHoveringOnSignUpButton = false;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the signup page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 18.0,
                      ),
                      decoration: BoxDecoration(
                        color: _isHoveringOnSignUpButton
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        "S'inscrire",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'views/sign_up_page.dart';
import 'views/login.dart';  // Make sure to import the LoginScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  bool _titleMovedUp = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _titleMovedUp = true;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            top: _titleMovedUp ? 400 : MediaQuery.of(context).size.height / 2 - 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Hedieaty',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cartoon',
                  color: Color.fromRGBO(245, 198, 82, 1.0),
                ),
              ),
            ),
          ),
          if (_titleMovedUp) ...[
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()), // Navigate to SignUpPage
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(245, 198, 82, 1.0), // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // Oval shape
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      ),
                      child: Text(
                        'New? Sign up',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginPage
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      ),
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                    },
                    child: Text(
                      "Can't sign in?",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(245, 198, 82, 1.0),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

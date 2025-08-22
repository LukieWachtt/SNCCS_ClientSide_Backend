import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:snc_cs_client/screen/auth/login.dart';
import 'package:snc_cs_client/screen/lobby/lobby.dart'; // Make sure you uncomment or create this!

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkInternetAndNavigate();
  }

  Future<void> _checkInternetAndNavigate() async {
    // 1. Check Internet Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      setState(() {
        _isConnected = true;
      });
    }

    // Wait until there's a connection
    while (!_isConnected) {
      final result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.none) {
        setState(() {
          _isConnected = true;
        });
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    // Ensure widget is still mounted before navigating
    if (!mounted) return;

    // 2. Check Firebase Authentication State after connectivity is confirmed
    final user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    Widget nextScreen;
    if (user != null) {
      // User is logged in
      nextScreen = const LobbyScreen(); // Direct to your Home Screen
    } else {
      // User is not logged in
      nextScreen = const LoginScreen(); // Direct to your Login Screen
    }

    // Add a short delay for the splash screen experience, then navigate
    await Future.delayed(const Duration(seconds: 2)); // Adjust as needed

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (or color overlay)
          Container(color: Colors.black.withOpacity(0.6)), // overlay
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SNC CUSTOMER SERVICE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/icon.png', height: 100),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 20),
              Text(
                _isConnected ? "Connected" : "Waiting for connection...",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

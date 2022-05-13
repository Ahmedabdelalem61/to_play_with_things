import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/app_router.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: ()
          async
          {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
          },
          child: const Text("Sign Out"),
        ),
      ),
    );
  }
}

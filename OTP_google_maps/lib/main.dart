import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_router.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initialRoute = '/';
  await Firebase.initializeApp();
  if(FirebaseAuth.instance.currentUser!=null){
    initialRoute = Routes.mapScreen;
  }
  runApp( MyApp(initialRoute: initialRoute,));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
   MyApp({Key? key,required this.initialRoute}) : super(key: key);
  final RouteGenerator routeGenerator = RouteGenerator();
  String initialRoute;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            title: 'Flutter Maps Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            onGenerateRoute: routeGenerator.getRoute,
            initialRoute: Routes.login,
          );
      }
}

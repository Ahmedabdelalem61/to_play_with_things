import 'package:flutter/material.dart';
import 'package:google_maps/presentation/screens/login_Screen.dart';
import 'package:google_maps/presentation/screens/maps_screen.dart';
import 'package:google_maps/presentation/screens/otp_screen.dart';
import 'package:provider/provider.dart';

import 'business_logic/phone_auth_bloc.dart';

class Routes {
  static const String login = "/";
  static const String otpScreen = "otpScreen";
  static const String mapScreen = "mapScreen";
}

class RouteGenerator {
  Route<dynamic> getRoute(RouteSettings settings) {
    PhoneAuthBloc phoneAuthBloc = PhoneAuthBloc();
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          builder: (context) => Provider<PhoneAuthBloc>.value(
            value: phoneAuthBloc,
            child: Consumer<PhoneAuthBloc>(
              builder: (_, bloc, widget) => LoginScreen(
                bloc: bloc,
              ),
            ),
          ),
        );
      case Routes.otpScreen:
        final String phoneNumber = settings.arguments.toString();
        return MaterialPageRoute(
          builder: (context) => Provider<PhoneAuthBloc>.value(
            value: phoneAuthBloc,
            child: Consumer<PhoneAuthBloc>(
              builder: (_, bloc, widget) => OtpScreen(
                bloc: bloc,
                phoneNumber: phoneNumber,
              ),
            ),
          ),
        );
      case Routes.mapScreen:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text("noRouteFound"),
        ),
        body: const Center(
          child: Text("noRouteFound"),
        ),
      ),
    );
  }
}

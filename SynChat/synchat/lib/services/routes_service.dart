import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RouteService {
  GlobalKey<NavigatorState> routerKey;
  static RouteService instance = RouteService();

  RouteService() {
    routerKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _route) {
    return routerKey.currentState.pushReplacementNamed(_route);
  }

  Future<dynamic> navigateTo(String _route) {
    return routerKey.currentState.pushNamed(_route);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _routeMaterial) {
    return routerKey.currentState.push(_routeMaterial);
  }

  void goBack() {
    return routerKey.currentState.pop();
  }
}

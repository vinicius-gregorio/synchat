import 'package:flutter/material.dart';
import 'package:synchat/pages/home_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './services/routes_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synchat',
      navigatorKey: RouteService.instance.routerKey,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF8ec6c5),
        accentColor: Color(0xFF6983aa),
        backgroundColor: Color(0xFFf4f4f4),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext context) => LoginPage(),
        "register": (BuildContext context) => RegisterPage(),
        "home": (BuildContext context) => Homepage()
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackbarService {
  BuildContext _buildContext;
  static SnackbarService instance = SnackbarService();
  SnackbarService();
  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackbarError(String _message) {
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(
        _message,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: Colors.redAccent,
    ));
  }

  void showSnackbarSuccess(String _message) {
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: Text(
        _message,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: const Color(0xFF8ec6c5),
    ));
  }
}

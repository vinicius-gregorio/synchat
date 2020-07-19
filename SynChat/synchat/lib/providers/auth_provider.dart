import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../services/snackbar_service.dart';
import '../services/routes_service.dart';
import '../services/database_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  AuthStatus status;
  FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void autoLogin() async {
    if (user != null) {
      await DatabaseService.instance.updateUserLastSeenTime(user.uid);
      return RouteService.instance.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser();
    if (user != null) {
      notifyListeners();
      await autoLogin();
    }
  }

  void loginUser(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackbarService.instance.showSnackbarSuccess('Welcome, ${user.email}');
      await DatabaseService.instance.updateUserLastSeenTime(user.uid);
      RouteService.instance.navigateToReplacement("home");
    } catch (error) {
      status = AuthStatus.Error;
      user = null;
      SnackbarService.instance.showSnackbarError('Error Authenticating $error');

      print(error);
    }
    notifyListeners();
  }

  //REGISTER
  void registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _userID)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      SnackbarService.instance.showSnackbarSuccess('Welcome, ${user.email}');
      await DatabaseService.instance.updateUserLastSeenTime(user.uid);
      RouteService.instance.goBack();
      RouteService.instance.navigateToReplacement("home");
    } catch (error) {
      status = AuthStatus.Error;
      user = null;
      SnackbarService.instance.showSnackbarError("Registering error: $error");
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await RouteService.instance.navigateToReplacement('login');
      SnackbarService.instance.showSnackbarSuccess('Logged Out');
    } catch (error) {
      SnackbarService.instance.showSnackbarError(error);
    }
    notifyListeners();
  }
}

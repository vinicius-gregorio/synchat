import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/snackbar_service.dart';
import '../services/routes_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double deviceHeight, deviceWidth;
  GlobalKey<FormState> formKey;
  String _email, _password;
  Color primaryColor = Color(0xFF8ec6c5);
  Color secundaryColor = Color(0xFF6983aa);
  Color thirdColor = Color(0xFF8566aa);
  bool _obscureText = true;
  Icon _visibility = Icon(Icons.visibility);
  Icon _visibilityOff = Icon(Icons.visibility_off);
  AuthProvider _auth;
  int indexVisible = 0;

  void toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void toggleVisible() {
    setState(() {
      if (indexVisible == 1)
        indexVisible = 0;
      else
        indexVisible = 1;
    });
  }

  _LoginPageState() {
    formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(builder: (BuildContext context) {
          SnackbarService.instance.buildContext = context;
          _auth = Provider.of<AuthProvider>(context);
          print(_auth.user);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    //Hello word
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                      child: Text(
                        'Hello',
                        style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ),
                    //THERE word
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 175, 0, 0),
                      child: Text(
                        'There',
                        style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ),
                    // DOT
                    Container(
                      padding: EdgeInsets.fromLTRB(220, 175, 0, 0),
                      child: Text(
                        '.',
                        style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: secundaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: Form(
                    key: formKey,
                    onChanged: () => formKey.currentState.save(),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: 'EMAIL',
                              labelStyle: TextStyle(
                                  fontFamily: 'MontSerrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor))),
                          validator: (value) => value.length != 0
                              ? null
                              : 'Email can\'t be empty',
                          onSaved: (value) => _email = value,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          autocorrect: false,
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    toggleObscure();
                                    toggleVisible();
                                  },
                                  child: indexVisible == 0
                                      ? _visibility
                                      : _visibilityOff),
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(
                                  fontFamily: 'MontSerrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor))),
                          validator: (value) => value.length != 0
                              ? null
                              : 'Password can\'t be empty',
                          onSaved: (value) => _password = value,
                          obscureText: _obscureText,
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          alignment: Alignment(1.0, 0.0),
                          padding: EdgeInsets.only(top: 15.0, left: 20.0),
                          child: InkWell(
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: secundaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.0),
                        InkWell(
                          onTap: () {},
                          child: _auth.status == AuthStatus.Authenticating
                              ? Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    if (formKey.currentState.validate()) {
                                      //Login user
                                      _auth.loginUser(_email, _password);
                                    }
                                  },
                                  child: Container(
                                    height: 40.0,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(20.0),
                                      shadowColor: Colors.transparent,
                                      color: primaryColor,
                                      elevation: 7.0,
                                      child: Center(
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: deviceHeight * 0.010,
                        ),
                        Container(
                          height: 40.0,
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                                style: BorderStyle.solid,
                                width: 1.0,
                              ),
                              color: Colors.blue[300], //Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: ImageIcon(
                                      AssetImage('assets/f2_logo.png')),
                                ),
                                Center(
                                  child: Text(
                                    "  LOGIN WITH FACEBOOK",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: deviceHeight * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "New to SynChat?",
                              style: TextStyle(
                                  fontFamily: 'MontSerrat',
                                  color: Colors.blueGrey),
                            ),
                            SizedBox(width: 5.0),
                            InkWell(
                              onTap: () {
                                RouteService.instance.navigateTo('register');
                              },
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                    color: secundaryColor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ],
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:synchat/providers/auth_provider.dart';
import 'package:synchat/services/cloudstore_service.dart';
import 'package:synchat/services/snackbar_service.dart';
import '../services/routes_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../services/database_service.dart';
import '../services/media_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  double deviceHeight, deviceWidth;
  GlobalKey<FormState> _formKey;
  String _email, _password, _name;
  File _image;
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

  _RegisterPageState() {
    _formKey = GlobalKey<FormState>();
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(builder: (BuildContext context) {
          SnackbarService.instance.buildContext = context;
          _auth = Provider.of<AuthProvider>(context);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      //Hello word
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                        child: Text(
                          'Create',
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
                          'Account',
                          style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      ),
                      // DOT
                      Container(
                        padding: EdgeInsets.fromLTRB(310, 175, 0, 0),
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
                      key: _formKey,
                      onChanged: () => _formKey.currentState.save(),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autocorrect: false,
                            decoration: InputDecoration(
                                labelText: 'NAME',
                                labelStyle: TextStyle(
                                    fontFamily: 'MontSerrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: primaryColor))),
                            validator: (value) => value.length != 0
                                ? null
                                : 'Name can\'t be empty',
                            onSaved: (value) => _name = value,
                          ),
                          TextFormField(
                            autocorrect: false,
                            decoration: InputDecoration(
                                labelText: 'EMAIL',
                                labelStyle: TextStyle(
                                    fontFamily: 'MontSerrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: primaryColor))),
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
                                    borderSide:
                                        BorderSide(color: primaryColor))),
                            validator: (value) => value.length != 0
                                ? null
                                : 'Password can\'t be empty',
                            onSaved: (value) => _password = value,
                            obscureText: _obscureText,
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            alignment: Alignment(1.0, 0.0),
                            padding: EdgeInsets.only(top: 20, left: 20.0),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () async {
                              print("Tapped Image");
                              File _imageFile = await MediaService.instance
                                  .getImageFromGallery();
                              setState(() {
                                _image = _imageFile;
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'IMAGE',
                                  style: TextStyle(
                                      fontFamily: 'MontSerrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                ),
                                CircleAvatar(
                                  backgroundImage: _image != null
                                      ? FileImage(_image)
                                      : AssetImage('assets/user.png'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              //para imagem no login, colocar
                              //&&  _image != null
                              if (_formKey.currentState.validate() &&
                                  _image != null) {
                                _auth.registerUserWithEmailAndPassword(
                                    _email, _password, (String _userID) async {
                                  var _result = await CloudStorageService
                                      .instance
                                      .uploadUserImage(_userID, _image);
                                  var _imageURL =
                                      await _result.ref.getDownloadURL();
                                  await DatabaseService.instance.createUser(
                                      _userID, _name, _email, _imageURL);
                                });
                              }
                            },
                            child: _auth.status != AuthStatus.Authenticating
                                ? Container(
                                    height: 40.0,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(20.0),
                                      shadowColor: Colors.transparent,
                                      color: primaryColor,
                                      elevation: 7.0,
                                      child: Center(
                                        child: Text(
                                          "CREATE ACCOUNT",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ),
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () => RouteService.instance.goBack(),
                            child: Container(
                              height: 40.0,
                              color: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  color: primaryColor, //Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Icon(Icons.arrow_back_ios),
                                    ),
                                    Center(
                                      child: Text(
                                        "GO BACK",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: deviceHeight * 0.015),
                        ],
                      )),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:synchat/models/contact.dart';
import '../models/colors.dart' as color;
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfilePage extends StatelessWidget {
  Widget _userImageWidget(String _image) {
    double _imageRadius = _deviceHeight * 0.2;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(_image),
        ),
      ),
    );
  }

  final double _deviceHeight, _deviceWidth;

  AuthProvider _auth;
  ProfilePage(this._deviceHeight, this._deviceWidth);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: Container(
        child: Builder(builder: (BuildContext context) {
          _auth = Provider.of<AuthProvider>(context);
          return StreamBuilder<Contact>(
              stream: DatabaseService.instance.getUserData(_auth.user.uid),
              builder: (BuildContext context, _snapshot) {
                var _userData = _snapshot.data;
                return _snapshot.hasData
                    ? Align(
                        child: SizedBox(
                          height: _deviceHeight * 0.4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _userImageWidget(_userData.image),
                              Container(
                                height: _deviceHeight * 0.05,
                                width: _deviceWidth,
                                child: Text(
                                  _userData.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 30),
                                ),
                              ),
                              Container(
                                height: _deviceHeight * 0.03,
                                width: _deviceWidth,
                                child: Text(
                                  _userData.email,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _auth.logoutUser(() => null);
                                },
                                child: Container(
                                  height: 40.0,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(20.0),
                                    shadowColor: Colors.transparent,
                                    color: color.primaryColor,
                                    elevation: 7.0,
                                    child: Center(
                                      child: Text(
                                        "LOGOUT",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SpinKitWanderingCubes(
                        color: color.secundaryColor,
                        size: 50,
                      );
              });
        }),
      ),
    );
  }
}

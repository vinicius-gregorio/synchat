import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:synchat/pages/conversation_page.dart';
import 'package:synchat/services/routes_service.dart';
import '../models/colors.dart' as color;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../models/contact.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  double deviceHeight, deviceWidth;

  SearchPage(this.deviceHeight, this.deviceWidth);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  AuthProvider _auth;
  String _searchText;
  _SearchPageState() {
    _searchText = '';
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(builder: (BuildContext context) {
          _auth = Provider.of<AuthProvider>(context);
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  height: this.widget.deviceHeight * 0.08,
                  width: this.widget.deviceWidth,
                  padding: EdgeInsets.symmetric(
                      vertical: this.widget.deviceHeight * 0.02),
                  child: TextField(
                    autocorrect: false,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: color.secundaryColor,
                        ),
                        labelText: 'Search',
                        labelStyle: TextStyle(
                            color: color.secundaryColor,
                            fontFamily: 'Montserrat'),
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                    onSubmitted: (_value) {
                      setState(() {
                        _searchText = _value;
                      });
                    },
                    onChanged: (_value) {
                      setState(() {
                        _searchText = _value;
                      });
                    },
                  ),
                ),
                StreamBuilder<List<Contact>>(
                    stream: DatabaseService.instance.getUsersInDB(_searchText),
                    builder: (context, snapshot) {
                      var _usersData = snapshot.data;
                      if (_usersData != null)
                        _usersData.removeWhere(
                            (element) => element.id == _auth.user.uid);

                      return snapshot.hasData
                          ? Container(
                              height: this.widget.deviceHeight * 0.7,
                              child: ListView.builder(
                                  itemCount: _usersData.length,
                                  itemBuilder:
                                      (BuildContext context, int _index) {
                                    var _userData = _usersData[_index];
                                    var _recepientID = _usersData[_index].id;
                                    var _isUserActive = !_userData.lastSeen
                                        .toDate()
                                        .isBefore(DateTime.now()
                                            .subtract(Duration(minutes: 5)));
                                    return ListTile(
                                      onTap: () {
                                        DatabaseService.instance
                                            .createOrGetConversartion(
                                                _auth.user.uid, _recepientID,
                                                (String _conversationID) {
                                          RouteService.instance.navigateToRoute(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ConversationPage(
                                                _conversationID,
                                                _userData.name,
                                                _userData.image,
                                                _recepientID);
                                          }));
                                        });
                                      },
                                      title: Text(_userData.name),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  _userData.image)),
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          _isUserActive
                                              ? Text('Active now')
                                              : Text('Last seen'),
                                          _isUserActive
                                              ? Container(
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          color.secundaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                )
                                              : Text(timeago.format(
                                                  _userData.lastSeen.toDate())),
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          : SpinKitWanderingCubes(
                              color: color.secundaryColor, size: 50);
                    }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

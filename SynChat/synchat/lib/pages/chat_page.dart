import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:synchat/models/conversation.dart';
import 'package:synchat/services/database_service.dart';
import '../models/colors.dart' as color;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatelessWidget {
  final double _deviceHeight, _deviceWidth;

  ChatPage(this._deviceHeight, this._deviceWidth);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: Builder(builder: (BuildContext context) {
        var _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: _deviceHeight,
          width: _deviceWidth,
          child: Container(
            height: _deviceHeight,
            width: _deviceWidth,
            child: StreamBuilder<List<ConversationSnippet>>(
                stream: DatabaseService.instance.getUserChat(_auth.user.uid),
                builder: (context, _snapshot) {
                  var _data = _snapshot.data;
                  if (_data != null) {
                    _data.removeWhere((_c) {
                      return _c.timestamp == null;
                    });
                    return _data.length != 0
                        ? ListView.builder(
                            itemCount: _data.length,
                            itemBuilder: (context, _index) => ListTile(
                              onTap: () {},
                              title: Text(_data[_index].name),
                              subtitle: Text(_data[_index].lastMessage),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(_data[_index].image)),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    timeago.format(
                                        _data[_index].timestamp.toDate()),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                        color: color.secundaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Align(
                            child: Text(
                              "No Conversations Yet!",
                              style: TextStyle(
                                  color: Colors.white30, fontSize: 15.0),
                            ),
                          );
                  } else {
                    return SpinKitWanderingCubes(
                      color: Colors.blue,
                      size: 50.0,
                    );
                  }
                }),
          ),
        );
      }),
    );
  }
}

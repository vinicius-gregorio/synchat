import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:synchat/models/conversation.dart';
import 'package:synchat/services/cloudstore_service.dart';
import 'package:synchat/services/database_service.dart';
import 'package:synchat/services/media_service.dart';
import '../models/colors.dart' as color;
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  String _conversationID, _revieverID, _recieverImage, _receiverName;

  ConversationPage(this._conversationID, this._receiverName,
      this._recieverImage, this._revieverID);
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  ScrollController _listViewController;
  double deviceHeight, deviceWidth;
  AuthProvider _auth;
  GlobalKey<FormState> formKey;
  String _messageText;

  _ConversationPageState() {
    formKey = GlobalKey<FormState>();
    _messageText = '';
    _listViewController = ScrollController();
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          this.widget._receiverName,
          style: TextStyle(color: color.secundaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Builder(builder: (BuildContext context) {
          _auth = Provider.of<AuthProvider>(context);
          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              _messageListview(),
              Align(
                alignment: Alignment.bottomCenter,
                child: _messageField(),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _messageListview() {
    return Container(
      height: deviceHeight * 0.75,
      width: deviceWidth,
      child: StreamBuilder<Conversation>(
          stream: DatabaseService.instance
              .getConversation(this.widget._conversationID),
          builder: (BuildContext context, _snapshot) {
            Timer(
                Duration(milliseconds: 100),
                () => {
                      _listViewController
                          .jumpTo(_listViewController.position.maxScrollExtent)
                    });
            var _conversationData = _snapshot.data;
            if (_conversationData != null) {
              if (_conversationData.messages.length != 0) {
                return ListView.builder(
                    controller: _listViewController,
                    itemCount: _conversationData.messages.length,
                    itemBuilder: (BuildContext context, int _index) {
                      var _message = _conversationData.messages[_index];
                      bool _isOwnMessage = _message.senderID == _auth.user.uid;
                      return _messageLisviewChild(_isOwnMessage, _message);
                    });
              } else {
                return Center(
                  child: Text('Start chatting ! ;)'),
                );
              }
            } else {
              return SpinKitWanderingCubes(
                color: color.secundaryColor,
                size: 50,
              );
            }
          }),
    );
  }

  Widget _messageLisviewChild(bool _isOwnMessage, Message _message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              !_isOwnMessage ? _userImageCircle() : Container(),
              SizedBox(
                width: 10,
              ),
              _message.type == MessageType.Text
                  ? textMessageContainer(
                      _isOwnMessage, _message.content, _message.timestamp)
                  : imageMessageContainer(
                      _isOwnMessage, _message.content, _message.timestamp),
            ],
          )),
    );
  }

  Widget _userImageCircle() {
    double _imageRadius = deviceHeight * 0.05;
    return Container(
        height: _imageRadius,
        width: _imageRadius,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
                image: NetworkImage(
                  this.widget._recieverImage,
                ),
                fit: BoxFit.cover)));
  }

  Widget _messageField() {
    return Container(
      height: deviceHeight * 0.08,
      decoration: BoxDecoration(
          color: color.primaryColor, borderRadius: BorderRadius.circular(100)),
      margin: EdgeInsets.symmetric(
          horizontal: deviceWidth * 0.04, vertical: deviceHeight * 0.02),
      child: Form(
          key: formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _messageTextField(),
              _imageMessageButton(),
              _sendMessageButton()
            ],
          )),
    );
  }

  Widget _messageTextField() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
          width: deviceWidth * 0.6,
          child: TextFormField(
            validator: (value) {
              if (value.length == 0)
                return "Please enter a message";
              else
                null;
            },
            onChanged: (value) {
              formKey.currentState.save();
            },
            onSaved: (value) {
              setState(() {
                _messageText = value;
              });
            },
            cursorColor: Colors.white,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: "Type a message"),
            autocorrect: false,
          )),
    );
  }

  Widget _sendMessageButton() {
    return Container(
      height: deviceHeight * 0.05,
      width: deviceWidth * 0.05,
      child: IconButton(
          icon: Icon(
            Icons.send,
            color: color.secundaryColor,
          ),
          onPressed: () {
            formKey.currentState.save();
            if (formKey.currentState.validate()) {
              DatabaseService.instance.sendMessage(
                this.widget._conversationID,
                Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    type: MessageType.Text),
              );

              formKey.currentState.reset();
              FocusScope.of(context).unfocus();
            }
          }),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: deviceHeight * 0.05,
      width: deviceWidth * 0.05,
      child: IconButton(
          icon: Icon(
            Icons.camera_alt,
            color: color.secundaryColor,
          ),
          onPressed: () async {
            var _image = await MediaService.instance.getImageFromGallery();
            if (_image != null) {
              var _result = await CloudStorageService.instance
                  .uploadMediaMessage(_auth.user.uid, _image);
              var _imageURL = await _result.ref.getDownloadURL();
              await DatabaseService.instance.sendMessage(
                this.widget._conversationID,
                Message(
                    content: _imageURL,
                    senderID: _auth.user.uid,
                    timestamp: Timestamp.now(),
                    type: MessageType.Image),
              );
            }
          }),
    );
  }

  Widget textMessageContainer(
      bool _isOwnMessage, String _message, Timestamp _timeStamp) {
    List<Color> _colorList = _isOwnMessage
        ? [color.primaryColor, color.primarygradient]
        : [color.secundaryGradient, color.thirdGradient];

    return Container(
      height: deviceHeight * 0.08 + (_message.length / 20 * 5),
      width: deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
              colors: _colorList,
              stops: [0.3, 0.7],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_message), //_message
          Text(
            timeago.format(_timeStamp.toDate()),
            style: TextStyle(color: color.secundaryColor),
          )
        ],
      ),
    );
  }

  Widget imageMessageContainer(
      bool _isOwnMessage, String _imageURL, Timestamp _timeStamp) {
    List<Color> _colorList = _isOwnMessage
        ? [color.primaryColor, color.primarygradient]
        : [color.secundaryGradient, color.thirdGradient];
    DecorationImage _image =
        DecorationImage(image: NetworkImage(_imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
              colors: _colorList,
              stops: [0.3, 0.7],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: deviceHeight * 0.3,
            width: deviceWidth * 0.4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), image: _image),
          ), //_message
          Text(
            timeago.format(_timeStamp.toDate()),
            style: TextStyle(color: color.secundaryColor),
          )
        ],
      ),
    );
  }
}

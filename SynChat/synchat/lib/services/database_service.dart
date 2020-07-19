import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchat/models/contact.dart';
import 'package:synchat/models/conversation.dart';
import '../models/message.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();
  Firestore _database;

  DatabaseService() {
    _database = Firestore.instance;
  }

  Stream<Contact> getUserData(String _userID) {
    var _reference = _database.collection(_userCollection).document(_userID);
    return _reference
        .get()
        .asStream()
        .map((_snapshot) => Contact.fromFirestore(_snapshot));
  }

  String _userCollection = "Users";
  String _chatCollection = "Conversations";
  Future<void> createUser(
      String _userID, String _name, String _email, String _imageURL) async {
    try {
      return await _database
          .collection(_userCollection)
          .document(_userID)
          .setData({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> updateUserLastSeenTime(String _userID) {
    var _ref = _database.collection(_userCollection).document(_userID);
    return _ref.updateData({"lastSeen": Timestamp.now()});
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref = _database.collection(_chatCollection).document(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
      default:
    }
    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _messageType,
          },
        ],
      ),
    });
  }

  Future<void> createOrGetConversartion(String _currentID, String _recepientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _database.collection(_chatCollection);
    var _userConversationRef = _database
        .collection(_userCollection)
        .document(_currentID)
        .collection(_chatCollection);
    try {
      var conversation =
          await _userConversationRef.document(_recepientID).get();
      if (conversation.data != null) {
        return _onSuccess(conversation.data["conversationID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            'messages': [],
          },
        );
        return _onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<List<ConversationSnippet>> getUserChat(String _userID) {
    var _ref = _database
        .collection(_userCollection)
        .document(_userID)
        .collection(_chatCollection);
    return _ref.snapshots().map((_snapshot) => _snapshot.documents
        .map((_document) => ConversationSnippet.fromFirestore(_document))
        .toList());
  }

  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _database
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');
    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String _conversationID) {
    var _ref = _database.collection(_chatCollection).document(_conversationID);
    return _ref.snapshots().map(
      (_doc) {
        return Conversation.fromFirestore(_doc);
      },
    );
  }
}

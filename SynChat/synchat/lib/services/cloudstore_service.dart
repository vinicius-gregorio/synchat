import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage _storage;
  StorageReference _baseReference;
  String _profileImages = "Profile Images";
  String _messages = 'messages';
  String _images = 'images';
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseReference = _storage.ref();
  }

  Future<StorageTaskSnapshot> uploadUserImage(String _userID, File _image) {
    try {
      return _baseReference
          .child(_profileImages)
          .child(_userID)
          .putFile(_image)
          .onComplete;
    } catch (error) {
      print(error);
    }
  }

  Future<StorageTaskSnapshot> uploadMediaMessage(String _uid, File _file) {
    var _timeStamp = DateTime.now();
    var _fileName = basename(_file.path);
    _fileName += '_${_timeStamp.toString()}';
    try {
      return _baseReference
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file)
          .onComplete;
    } catch (error) {
      print(error);
    }
  }
}

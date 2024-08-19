import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String _accessToken = '';

  String get accessToken => _accessToken;

  void updateToken(String newToken) {
    _accessToken = newToken;
    notifyListeners();
  }
}

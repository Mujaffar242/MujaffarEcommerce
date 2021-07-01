import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exeption.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuthanticate {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  Future<void> _authanticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBZs1iJF81aWlSosRRXosIa9By21TzEm64';

    try {
      final reponce = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final responceData = jsonDecode(reponce.body);

      if (responceData['error'] != null)
        throw HttpExeption(responceData['error']['message']);

      _token = responceData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responceData['expiresIn'])));
      _userId = responceData['localId'];

      autoLogout();
      notifyListeners();

      //store data in shared_prefrences for auto login
      var prefrences = await SharedPreferences.getInstance();
      final userData = json.encode(
          {'userId': userId, 'token': token, 'expiryDate': _expiryDate.toIso8601String()});
      prefrences.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> tryAutoLogin() async {
    var prefrences = await SharedPreferences.getInstance();
    if (!prefrences.containsKey('userData')) return false;

    final extractedUserData = json.decode(prefrences.getString('userData'));
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _expiryDate = expiryDate;
    _userId = extractedUserData['userId'];
    _token = extractedUserData['token'];

    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authanticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authanticate(email, password, 'signInWithPassword');
  }

  void logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
    }

    notifyListeners();

    var prefrences = await SharedPreferences.getInstance();
    prefrences.clear();


  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';

class UserProvider with ChangeNotifier {
  static const String _userKey = 'currentUser';
  User? _user;
  final Box<User> _userBox = Hive.box<User>('user_box');

  User? get user => _user;

  UserProvider() {
    loadUser(); // Use the public method
  }

  // Now public, so it can be called from other parts of the app
  void loadUser() {
    if (_userBox.containsKey(_userKey)) {
      _user = _userBox.get(_userKey);
    } else {
      _user = null;
    }
    notifyListeners();
  }

  // Sets or creates a user
  void setUser(User user) {
    _user = user;
    _userBox.put(_userKey, user);
    notifyListeners();
  }

  // Updates the current user
  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _userBox.put(_userKey, updatedUser);
    notifyListeners();
  }

  void setGuestUser() {
    final guestUser = User(
      id: 'guest',
      name: 'Invitado',
      gender: 'No especificado',
      age: 0,
      height: 0,
      weight: 0,
      isGuest: true,
    );
    _user = guestUser;
    _userBox.put(_userKey, guestUser);
    notifyListeners();
  }

  void logout() {
    _user = null;
    if (_userBox.containsKey(_userKey)) {
      _userBox.delete(_userKey);
    }
    notifyListeners();
  }
}

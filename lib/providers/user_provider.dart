import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';

class UserProvider with ChangeNotifier {
  static const String _userKey = 'currentUser';
  User? _user;
  final Box<User> _userBox = Hive.box<User>('user_box');

  User? get user => _user;

  UserProvider() {
    loadUser(); // Load user on initialization
  }

  // Load user from Hive
  void loadUser() {
    if (_userBox.containsKey(_userKey)) {
      final storedUser = _userBox.get(_userKey);
      // If the stored user is a guest, reflect that, otherwise set the user
      if (storedUser != null) {
        _user = storedUser;
      } else {
        setGuestUser(); // If for some reason the user is null, set to guest
      }
    } else {
      setGuestUser(); // If no user is stored, set to guest
    }
    notifyListeners();
  }

  // Sets or creates a user
  Future<void> setUser(User user) async {
    _user = user;
    await _userBox.put(_userKey, user);
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
      activityLevel: 'sedentary', 
    );
    _user = guestUser;
    _userBox.put(_userKey, guestUser); // Also save guest status
    notifyListeners();
  }

  void logout() {
    _userBox.delete(_userKey); // Remove the user from storage
    setGuestUser(); // Set the user to guest after logout
  }
}

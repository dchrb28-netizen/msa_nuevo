import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  static const String _activeUserKey = 'activeUserId';
  User? _user;
  final Box<User> _userBox = Hive.box<User>('user_box');
  final Box _settingsBox = Hive.box('settings');
  List<User> _users = [];

  User? get user => _user;
  List<User> get users => _users;

  UserProvider() {
    loadUsers();
  }

  void loadUsers() {
    _users = _userBox.values.where((user) => !user.isGuest).toList();
    final activeUserId = _settingsBox.get(_activeUserKey);

    if (activeUserId != null) {
      try {
        _user = _users.firstWhere((u) => u.id == activeUserId);
      } catch (e) {
        _user = null;
        _settingsBox.delete(_activeUserKey);
      }
    } else {
      _user = null;
    }
    
    notifyListeners();
  }

  Future<void> setUser(User user) async {
    var userToSave = user;
    if (user.id == 'guest' || user.id.isEmpty) {
      userToSave = user.copyWith(id: const Uuid().v4());
    }
    _user = userToSave;
    await _userBox.put(userToSave.id, userToSave);
    await _settingsBox.put(_activeUserKey, userToSave.id);
    loadUsers();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _userBox.put(updatedUser.id, updatedUser);
    loadUsers();
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
    notifyListeners();
  }

  void logout() {
    _settingsBox.delete(_activeUserKey);
    _user = null;
    loadUsers(); // Recargar la lista de usuarios
  }

  Future<void> switchUser(String userId) async {
    final userToSwitch = _users.firstWhere((u) => u.id == userId);
    _user = userToSwitch;
    await _settingsBox.put(_activeUserKey, userId);
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    final activeUserId = _settingsBox.get(_activeUserKey);
    if (activeUserId == userId) {
      await _settingsBox.delete(_activeUserKey);
      _user = null;
    }
    await _userBox.delete(userId);
    loadUsers();
  }
}

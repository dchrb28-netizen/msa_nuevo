import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/services/achievement_service.dart';
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

    await _userBox.put(userToSave.id, userToSave);
    await _settingsBox.put(_activeUserKey, userToSave.id);

    _user = userToSave;

    final index = _users.indexWhere((u) => u.id == userToSave.id);
    if (index != -1) {
      _users[index] = userToSave;
    } else {
      _users.add(userToSave);
    }

    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    if (_user?.id == updatedUser.id) {
      await _userBox.put(updatedUser.id, updatedUser);
      _user = updatedUser;

      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      notifyListeners(); // THIS IS THE FIX
    }
  }

  Future<bool> addFavoriteRecipe(Recipe recipe) async {
    if (_user != null && !_user!.isGuest) {
      final updatedFavorites = List<Recipe>.from(_user!.favoriteRecipes)..add(recipe);
      final updatedUser = _user!.copyWith(favoriteRecipes: updatedFavorites);
      await updateUser(updatedUser);

      // Update achievement
      AchievementService().updateProgress('exp_add_favorite', 1, cumulative: true);
      return true;
    } else {
      return false;
    }
  }

  Future<void> removeFavoriteRecipe(Recipe recipe) async {
    if (_user != null && !_user!.isGuest) {
      final updatedFavorites = List<Recipe>.from(_user!.favoriteRecipes)
        ..removeWhere((r) => r.title == recipe.title);
      final updatedUser = _user!.copyWith(favoriteRecipes: updatedFavorites);
      await updateUser(updatedUser);
    }
  }

  void loginAsGuest() {
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
    notifyListeners();
  }

  Future<void> switchUser(String userId) async {
    final userToSwitch = _users.firstWhere((u) => u.id == userId);
    _user = userToSwitch;
    await _settingsBox.put(_activeUserKey, userId);
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    final activeUserId = _settingsBox.get(_activeUserKey);

    await _userBox.delete(userId);

    if (activeUserId == userId) {
      await _settingsBox.delete(_activeUserKey);
      _user = null;
    }

    _users.removeWhere((u) => u.id == userId);

    notifyListeners();
  }
}

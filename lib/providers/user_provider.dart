import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/recipe.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  static const String _activeUserKey = 'activeUserId';
  User? _user;
  Box<User>? _userBox;
  Box? _settingsBox;
  List<User> _users = [];
  bool _isInitialized = false;

  User? get user => _user;
  List<User> get users => _users;
  bool get isInitialized => _isInitialized;

  UserProvider() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    try {
      // Verificar si ya están abiertas antes de intentar abrirlas
      if (Hive.isBoxOpen('user_box')) {
        _userBox = Hive.box<User>('user_box');
      } else {
        _userBox = await Hive.openBox<User>('user_box');
      }
      
      if (Hive.isBoxOpen('settings')) {
        _settingsBox = Hive.box('settings');
      } else {
        _settingsBox = await Hive.openBox('settings');
      }
      
      _isInitialized = true;
      await loadUsers();
    } catch (e) {
      print('❌ Error inicializando UserProvider: $e');
      _isInitialized = false;
    }
  }

  Future<void> _ensureBoxesOpen() async {
    if (!_isInitialized || _userBox == null || !_userBox!.isOpen || _settingsBox == null || !_settingsBox!.isOpen) {
      print('🔄 Reabriendo cajas en UserProvider...');
      await _initBoxes();
    }
  }

  Future<void> loadUsers() async {
    await _ensureBoxesOpen();
    
    print('📖 loadUsers: Leyendo de user_box...');
    print('📦 user_box está abierta: ${_userBox!.isOpen}');
    print('📦 user_box total valores: ${_userBox!.length}');
    
    _users = _userBox!.values.where((user) => !user.isGuest).toList();
    print('👥 Usuarios cargados (sin invitados): ${_users.length}');
    
    final activeUserId = _settingsBox!.get(_activeUserKey);

    if (activeUserId != null) {
      try {
        _user = _users.firstWhere((u) => u.id == activeUserId);
        print('✅ Usuario activo encontrado: ${_user?.name}');
      } catch (e) {
        print('⚠️ Usuario activo no encontrado: $e');
        _user = null;
        _settingsBox!.delete(_activeUserKey);
      }
    } else {
      print('ℹ️ No hay usuario activo configurado');
      _user = null;
    }

    notifyListeners();
  }

  Future<void> setUsers(List<User> users) async {
    print('🔄 setUsers llamado con ${users.length} usuarios');
    // Después de una restauración, recargar usuarios desde Hive
    // Los usuarios ya fueron guardados en Hive por importBackup()
    await loadUsers();
    print('📋 Después de loadUsers: ${_users.length} usuarios en memoria');
  }

  Future<void> setUser(User user) async {
    await _ensureBoxesOpen();
    
    var userToSave = user;
    if (user.id == 'guest' || user.id.isEmpty) {
      userToSave = user.copyWith(id: const Uuid().v4());
    }

    await _userBox!.put(userToSave.id, userToSave);
    await _settingsBox!.put(_activeUserKey, userToSave.id);

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
    await _ensureBoxesOpen();
    
    if (_user?.id == updatedUser.id) {
      await _userBox!.put(updatedUser.id, updatedUser);
      _user = updatedUser;

      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      notifyListeners();
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
    _settingsBox?.delete(_activeUserKey);
    _user = null;
    notifyListeners();
  }

  Future<void> switchUser(String userId) async {
    await _ensureBoxesOpen();
    
    final userToSwitch = _users.firstWhere((u) => u.id == userId);
    _user = userToSwitch;
    await _settingsBox!.put(_activeUserKey, userId);
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    await _ensureBoxesOpen();
    
    final activeUserId = _settingsBox!.get(_activeUserKey);

    await _userBox!.delete(userId);

    if (activeUserId == userId) {
      await _settingsBox!.delete(_activeUserKey);
      _user = null;
    }

    _users.removeWhere((u) => u.id == userId);

    notifyListeners();
  }
}

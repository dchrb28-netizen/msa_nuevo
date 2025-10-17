import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/models/user.dart';

class UserProvider with ChangeNotifier {
  static const String _userKey = 'currentUser'; // Clave única y fija
  User? _user;
  final Box<User> _userBox = Hive.box<User>('user_box');

  User? get user => _user;

  UserProvider() {
    _loadUser();
  }

  // Carga al usuario desde Hive usando la clave fija.
  void _loadUser() {
    if (_userBox.containsKey(_userKey)) {
      _user = _userBox.get(_userKey);
    } else {
      _user = null;
    }
    notifyListeners();
  }

  // Guarda o actualiza al usuario en Hive usando la clave fija.
  void setUser(User user) {
    _user = user;
    _userBox.put(_userKey, user);
    notifyListeners();
  }

  // Crea un usuario invitado y LO GUARDA en la base de datos.
  void setGuestUser() {
    final guestUser = User(
        id: 'guest',
        name: 'Invitado',
        gender: 'No especificado',
        age: 0,
        height: 0,
        weight: 0,
        isGuest: true, // Marcar explícitamente como invitado
    );
    _user = guestUser;
    _userBox.put(_userKey, guestUser); // Guardar el invitado
    notifyListeners();
  }

  // Elimina al usuario actual de la base de datos.
  void logout() {
    _user = null;
    if (_userBox.containsKey(_userKey)) {
      _userBox.delete(_userKey);
    }
    notifyListeners();
  }
}

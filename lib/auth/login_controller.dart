// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'dart:async';
import 'package:flutter/foundation.dart';

class LoginController {
  final Map<String, String> _users = {
    "admin": "123",
    "qlio": "087",
    "dosen": "koding",
  };

  int _attemptCount = 0;
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  final ValueNotifier<int> remainingTime = ValueNotifier(0);

  bool login(String username, String password) {
    if (isLocked.value) return false;
    if (_users.containsKey(username) && _users[username] == password) {
      _attemptCount = 0; 
      return true;
    } else {
      _handleFailedAttempt();
      return false;
    }
  }

  // Menentukan Role (Ketua/Anggota)
  String getUserRole(String username) {
    if (username == 'admin') return 'Ketua';
    return 'Anggota'; 
  }

  // --- Menentukan Kelompok (Team ID) ---
  String getUserTeam(String username) {
    // Untuk simulasi kolaborasi, semua user masukkan ke kelompok yang sama
    return 'KLP_01'; 
  }

  void _handleFailedAttempt() {
    _attemptCount++;
    if (_attemptCount >= 3) _lockLogin();
  }

  void _lockLogin() {
    isLocked.value = true;
    remainingTime.value = 10;
    _attemptCount = 0; 

    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime.value--;
      if (remainingTime.value <= 0) {
        isLocked.value = false;
        timer.cancel();
      }
    });
  }

  void dispose() {
    isLocked.dispose();
    remainingTime.dispose();
  }
}
// Nama : Qlio Amanda Febriany
// Nim : 241511087
// Kelas : 2C
// Catatan: Logika dasar multi-user dan timer dibantu oleh saran AI (Gemini), 
// namun dimodifikasi (Twist) secara mandiri menggunakan ValueNotifier agar tetap 
// mematuhi prinsip SRP, menjaga View tetap bersih dari logika bisnis.

import 'dart:async';
import 'package:flutter/foundation.dart';

class LoginController {
  // 1. Database sederhana menggunakan Map (Multiple Users)
  final Map<String, String> _users = {
    "admin": "123",
    "qlio": "087",
    "dosen": "koding",
  };

  int _attemptCount = 0;
  
  // 2. Reactive State (ValueNotifier) agar View otomatis update tanpa setState manual
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  final ValueNotifier<int> remainingTime = ValueNotifier(0);

  // Fungsi pengecekan utama
  bool login(String username, String password) {
    // Jika sedang terkunci, langsung tolak
    if (isLocked.value) return false;

    // Validasi User & Pass
    if (_users.containsKey(username) && _users[username] == password) {
      _attemptCount = 0; // Reset percobaan jika sukses masuk
      return true;
    } else {
      _handleFailedAttempt();
      return false;
    }
  }

  // Logika pembatasan percobaan
  void _handleFailedAttempt() {
    _attemptCount++;
    if (_attemptCount >= 3) {
      _lockLogin();
    }
  }

  // Logika Timer 10 Detik
  void _lockLogin() {
    isLocked.value = true;
    remainingTime.value = 10;
    _attemptCount = 0; // Reset counter agar nanti bisa coba 3x lagi

    // Countdown Timer (Twist UX)
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime.value--;
      if (remainingTime.value <= 0) {
        isLocked.value = false;
        timer.cancel();
      }
    });
  }

  // Praktik baik Clean Code: Membersihkan memori
  void dispose() {
    isLocked.dispose();
    remainingTime.dispose();
  }
}
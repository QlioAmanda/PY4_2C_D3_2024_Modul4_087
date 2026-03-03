// Nama : Qlio Amanda Febriany
// Nim : 241511087
// Kelas : 2C

import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  List<String> _history = [];
  
  // Identitas user untuk memisahkan database (Persistence per User)
  final String username;

  CounterController(this.username);

  // Getter
  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // --- LOGIKA PERSISTENCE (TASK 3) ---

  // Memuat data saat aplikasi dibuka
  Future<void> loadData(Function onUpdate) async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan Key unik per user
    _counter = prefs.getInt('counter_$username') ?? 0;
    _history = prefs.getStringList('history_$username') ?? [];
    onUpdate(); // Beritahu UI untuk refresh
  }

  // Menyimpan data setiap kali ada perubahan
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_$username', _counter);
    await prefs.setStringList('history_$username', _history);
  }

  // --- LOGIKA HITUNGAN ---

  void setStep(int value) {
    _step = value;
  }

  void _addHistory(String message) {
    String timestamp = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    _history.insert(0, "[$timestamp] $message oleh $username");

    if (_history.length > 5) _history.removeLast();
    _saveData(); // Simpan otomatis
  }

  bool increment() {
    if (_counter + _step > 300) return false; // Inovasi Batas Maksimal
    _counter += _step;
    _addHistory("Ditambah $_step");
    return true;
  }

  bool decrement() {
    if (_counter - _step < 0) return false; // Inovasi Anti-Minus
    _counter -= _step;
    _addHistory("Dikurang $_step");
    return true;
  }

  void reset() {
    _counter = 0;
    _addHistory("Data di-reset");
  }
}